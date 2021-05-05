"""
Memcached Backends
------------------

Provides backends for talking to `memcached <http://memcached.org>`_.

"""

import random
import threading
import time
import typing
from typing import Any
from typing import Mapping

from ..api import CacheBackend
from ..api import NO_VALUE
from ... import util

if typing.TYPE_CHECKING:
    import memcache
    import pylibmc
    import bmemcached
    import pymemcache
else:
    # delayed import
    memcache = None
    pylibmc = None
    bmemcached = None
    pymemcache = None

__all__ = (
    "GenericMemcachedBackend",
    "MemcachedBackend",
    "PylibmcBackend",
    "PyMemcacheBackend",
    "BMemcachedBackend",
    "MemcachedLock",
)


class MemcachedLock(object):
    """Simple distributed lock using memcached."""

    def __init__(self, client_fn, key, timeout=0):
        self.client_fn = client_fn
        self.key = "_lock" + key
        self.timeout = timeout

    def acquire(self, wait=True):
        client = self.client_fn()
        i = 0
        while True:
            if client.add(self.key, 1, self.timeout):
                return True
            elif not wait:
                return False
            else:
                sleep_time = (((i + 1) * random.random()) + 2 ** i) / 2.5
                time.sleep(sleep_time)
            if i < 15:
                i += 1

    def locked(self):
        client = self.client_fn()
        return client.get(self.key) is not None

    def release(self):
        client = self.client_fn()
        client.delete(self.key)


class GenericMemcachedBackend(CacheBackend):
    """Base class for memcached backends.

    This base class accepts a number of paramters
    common to all backends.

    :param url: the string URL to connect to.  Can be a single
     string or a list of strings.  This is the only argument
     that's required.
    :param distributed_lock: boolean, when True, will use a
     memcached-lock as the dogpile lock (see :class:`.MemcachedLock`).
     Use this when multiple
     processes will be talking to the same memcached instance.
     When left at False, dogpile will coordinate on a regular
     threading mutex.
    :param lock_timeout: integer, number of seconds after acquiring a lock that
     memcached should expire it.  This argument is only valid when
     ``distributed_lock`` is ``True``.

     .. versionadded:: 0.5.7

    :param memcached_expire_time: integer, when present will
     be passed as the ``time`` parameter to ``pylibmc.Client.set``.
     This is used to set the memcached expiry time for a value.

     .. note::

         This parameter is **different** from Dogpile's own
         ``expiration_time``, which is the number of seconds after
         which Dogpile will consider the value to be expired.
         When Dogpile considers a value to be expired,
         it **continues to use the value** until generation
         of a new value is complete, when using
         :meth:`.CacheRegion.get_or_create`.
         Therefore, if you are setting ``memcached_expire_time``, you'll
         want to make sure it is greater than ``expiration_time``
         by at least enough seconds for new values to be generated,
         else the value won't be available during a regeneration,
         forcing all threads to wait for a regeneration each time
         a value expires.

    The :class:`.GenericMemachedBackend` uses a ``threading.local()``
    object to store individual client objects per thread,
    as most modern memcached clients do not appear to be inherently
    threadsafe.

    In particular, ``threading.local()`` has the advantage over pylibmc's
    built-in thread pool in that it automatically discards objects
    associated with a particular thread when that thread ends.

    """

    set_arguments: Mapping[str, Any] = {}
    """Additional arguments which will be passed
    to the :meth:`set` method."""

    # No need to override serializer, as all the memcached libraries
    # handles that themselves. Still, we support customizing the
    # serializer/deserializer to use better default pickle protocol
    # or completely different serialization mechanism
    serializer = None
    deserializer = None

    def __init__(self, arguments):
        self._imports()
        # using a plain threading.local here.   threading.local
        # automatically deletes the __dict__ when a thread ends,
        # so the idea is that this is superior to pylibmc's
        # own ThreadMappedPool which doesn't handle this
        # automatically.
        self.url = util.to_list(arguments["url"])
        self.distributed_lock = arguments.get("distributed_lock", False)
        self.lock_timeout = arguments.get("lock_timeout", 0)
        self.memcached_expire_time = arguments.get("memcached_expire_time", 0)

    def has_lock_timeout(self):
        return self.lock_timeout != 0

    def _imports(self):
        """client library imports go here."""
        raise NotImplementedError()

    def _create_client(self):
        """Creation of a Client instance goes here."""
        raise NotImplementedError()

    @util.memoized_property
    def _clients(self):
        backend = self

        class ClientPool(threading.local):
            def __init__(self):
                self.memcached = backend._create_client()

        return ClientPool()

    @property
    def client(self):
        """Return the memcached client.

        This uses a threading.local by
        default as it appears most modern
        memcached libs aren't inherently
        threadsafe.

        """
        return self._clients.memcached

    def get_mutex(self, key):
        if self.distributed_lock:
            return MemcachedLock(
                lambda: self.client, key, timeout=self.lock_timeout
            )
        else:
            return None

    def get(self, key):
        value = self.client.get(key)
        if value is None:
            return NO_VALUE
        else:
            return value

    def get_multi(self, keys):
        values = self.client.get_multi(keys)

        return [
            NO_VALUE if val is None else val
            for val in [values.get(key, NO_VALUE) for key in keys]
        ]

    def set(self, key, value):
        self.client.set(key, value, **self.set_arguments)

    def set_multi(self, mapping):
        mapping = {key: value for key, value in mapping.items()}
        self.client.set_multi(mapping, **self.set_arguments)

    def delete(self, key):
        self.client.delete(key)

    def delete_multi(self, keys):
        self.client.delete_multi(keys)


class MemcacheArgs(GenericMemcachedBackend):
    """Mixin which provides support for the 'time' argument to set(),
    'min_compress_len' to other methods.

    """

    def __init__(self, arguments):
        self.min_compress_len = arguments.get("min_compress_len", 0)

        self.set_arguments = {}
        if "memcached_expire_time" in arguments:
            self.set_arguments["time"] = arguments["memcached_expire_time"]
        if "min_compress_len" in arguments:
            self.set_arguments["min_compress_len"] = arguments[
                "min_compress_len"
            ]
        super(MemcacheArgs, self).__init__(arguments)


pylibmc = None


class PylibmcBackend(MemcacheArgs, GenericMemcachedBackend):
    """A backend for the
    `pylibmc <http://sendapatch.se/projects/pylibmc/index.html>`_
    memcached client.

    A configuration illustrating several of the optional
    arguments described in the pylibmc documentation::

        from dogpile.cache import make_region

        region = make_region().configure(
            'dogpile.cache.pylibmc',
            expiration_time = 3600,
            arguments = {
                'url':["127.0.0.1"],
                'binary':True,
                'behaviors':{"tcp_nodelay": True,"ketama":True}
            }
        )

    Arguments accepted here include those of
    :class:`.GenericMemcachedBackend`, as well as
    those below.

    :param binary: sets the ``binary`` flag understood by
     ``pylibmc.Client``.
    :param behaviors: a dictionary which will be passed to
     ``pylibmc.Client`` as the ``behaviors`` parameter.
    :param min_compress_len: Integer, will be passed as the
     ``min_compress_len`` parameter to the ``pylibmc.Client.set``
     method.

    """

    def __init__(self, arguments):
        self.binary = arguments.get("binary", False)
        self.behaviors = arguments.get("behaviors", {})
        super(PylibmcBackend, self).__init__(arguments)

    def _imports(self):
        global pylibmc
        import pylibmc  # noqa

    def _create_client(self):
        return pylibmc.Client(
            self.url, binary=self.binary, behaviors=self.behaviors
        )


memcache = None


class MemcachedBackend(MemcacheArgs, GenericMemcachedBackend):
    """A backend using the standard
    `Python-memcached <http://www.tummy.com/Community/software/\
    python-memcached/>`_
    library.

    Example::

        from dogpile.cache import make_region

        region = make_region().configure(
            'dogpile.cache.memcached',
            expiration_time = 3600,
            arguments = {
                'url':"127.0.0.1:11211"
            }
        )

    """

    def _imports(self):
        global memcache
        import memcache  # noqa

    def _create_client(self):
        return memcache.Client(self.url)


bmemcached = None


class BMemcachedBackend(GenericMemcachedBackend):
    """A backend for the
    `python-binary-memcached <https://github.com/jaysonsantos/\
    python-binary-memcached>`_
    memcached client.

    This is a pure Python memcached client which includes
    security features like SASL and SSL/TLS.

    SASL is a standard for adding authentication mechanisms
    to protocols in a way that is protocol independent.

    SSL/TLS is a security layer on end-to-end communication.
    It provides following benefits:

    * Encryption: Data is encrypted on the wire between
      Memcached client and server.
    * Authentication: Optionally, both server and client
      authenticate each other.
    * Integrity: Data is not tampered or altered when
      transmitted between client and server

    A typical configuration using username/password::

        from dogpile.cache import make_region

        region = make_region().configure(
            'dogpile.cache.bmemcached',
            expiration_time = 3600,
            arguments = {
                'url':["127.0.0.1"],
                'username':'scott',
                'password':'tiger'
            }
        )

    A typical configuration using tls_context::

        import ssl
        from dogpile.cache import make_region

        ctx = ssl.create_default_context(cafile="/path/to/my-ca.pem")

        region = make_region().configure(
            'dogpile.cache.bmemcached',
            expiration_time = 3600,
            arguments = {
                'url':["127.0.0.1"],
                'tls_context':ctx,
            }
        )

    For advanced ways to configure TLS creating a more complex
    tls_context visit https://docs.python.org/3/library/ssl.html

    Arguments which can be passed to the ``arguments``
    dictionary include:

    :param username: optional username, will be used for
     SASL authentication.
    :param password: optional password, will be used for
     SASL authentication.
    :param tls_context: optional TLS context, will be used for
     TLS connections.

     .. versionadded:: 1.0.2

    """

    def __init__(self, arguments):
        self.username = arguments.get("username", None)
        self.password = arguments.get("password", None)
        self.tls_context = arguments.get("tls_context", None)
        super(BMemcachedBackend, self).__init__(arguments)

    def _imports(self):
        global bmemcached
        import bmemcached

        class RepairBMemcachedAPI(bmemcached.Client):
            """Repairs BMemcached's non-standard method
            signatures, which was fixed in BMemcached
            ef206ed4473fec3b639e.

            """

            def add(self, key, value, timeout=0):
                try:
                    return super(RepairBMemcachedAPI, self).add(
                        key, value, timeout
                    )
                except ValueError:
                    return False

        self.Client = RepairBMemcachedAPI

    def _create_client(self):
        return self.Client(
            self.url,
            username=self.username,
            password=self.password,
            tls_context=self.tls_context,
        )

    def delete_multi(self, keys):
        """python-binary-memcached api does not implements delete_multi"""
        for key in keys:
            self.delete(key)


pymemcache = None


class PyMemcacheBackend(GenericMemcachedBackend):
    """A backend for the
    `pymemcache <https://github.com/pinterest/pymemcache>`_
    memcached client.

    A comprehensive, fast, pure Python memcached client

    .. versionadded:: 1.1.2

    pymemcache supports the following features:

    * Complete implementation of the memcached text protocol.
    * Configurable timeouts for socket connect and send/recv calls.
    * Access to the "noreply" flag, which can significantly increase
      the speed of writes.
    * Flexible, simple approach to serialization and deserialization.
    * The (optional) ability to treat network and memcached errors as
      cache misses.

    dogpile.cache uses the ``HashClient`` from pymemcache in order to reduce
    API differences when compared to other memcached client drivers. In short,
    this allows the user to provide a single server or a list of memcached
    servers.

    The ``serde`` param defaults to ``pymemcache.serde.pickle_serde`` as the
    legacy ``serde`` would always convert the stored data to binary.

    The ``default_noreply`` param defaults to False, otherwise the add command
    would always return True causing the mutex not to work.

    SSL/TLS is a security layer on end-to-end communication.
    It provides following benefits:

    * Encryption: Data is encrypted on the wire between
      Memcached client and server.
    * Authentication: Optionally, both server and client
      authenticate each other.
    * Integrity: Data is not tampered or altered when
      transmitted between client and server

    A typical configuration using tls_context::

        import ssl
        from dogpile.cache import make_region

        ctx = ssl.create_default_context(cafile="/path/to/my-ca.pem")

        region = make_region().configure(
            'dogpile.cache.pymemcache',
            expiration_time = 3600,
            arguments = {
                'url':["127.0.0.1"],
                'tls_context':ctx,
            }
        )

    For advanced ways to configure TLS creating a more complex
    tls_context visit https://docs.python.org/3/library/ssl.html

    Arguments which can be passed to the ``arguments``
    dictionary include:

    :param tls_context: optional TLS context, will be used for
     TLS connections.
    :param serde: optional "serde". Defaults to
     ``pymemcache.serde.pickle_serde``
    :param default_noreply: Defaults to False

    """

    def __init__(self, arguments):
        super().__init__(arguments)

        self.serde = arguments.get("serde", pymemcache.serde.pickle_serde)
        self.default_noreply = arguments.get("default_noreply", False)
        self.tls_context = arguments.get("tls_context", None)

    def _imports(self):
        global pymemcache
        import pymemcache

    def _create_client(self):
        return pymemcache.client.hash.HashClient(
            self.url,
            serde=self.serde,
            default_noreply=self.default_noreply,
            tls_context=self.tls_context,
        )
