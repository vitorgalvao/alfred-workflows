# -*- coding: utf-8 -*-
from __future__ import division
from datetime import datetime, timedelta
import logging
import os

from guessit import guessit
from rebulk.loose import ensure_list

from subliminal.utils import matches_title

logger = logging.getLogger(__name__)

#: Video extensions
VIDEO_EXTENSIONS = ('.3g2', '.3gp', '.3gp2', '.3gpp', '.60d', '.ajp', '.asf', '.asx', '.avchd', '.avi', '.bik',
                    '.bix', '.box', '.cam', '.dat', '.divx', '.dmf', '.dv', '.dvr-ms', '.evo', '.flc', '.fli',
                    '.flic', '.flv', '.flx', '.gvi', '.gvp', '.h264', '.m1v', '.m2p', '.m2ts', '.m2v', '.m4e',
                    '.m4v', '.mjp', '.mjpeg', '.mjpg', '.mk3d', '.mkv', '.moov', '.mov', '.movhd', '.movie', '.movx',
                    '.mp4', '.mpe', '.mpeg', '.mpg', '.mpv', '.mpv2', '.mxf', '.nsv', '.nut', '.ogg', '.ogm', '.ogv',
                    '.omf', '.ps', '.qt', '.ram', '.rm', '.rmvb', '.swf', '.ts', '.vfw', '.vid', '.video', '.viv',
                    '.vivo', '.vob', '.vro', '.webm', '.wm', '.wmv', '.wmx', '.wrap', '.wvx', '.wx', '.x264', '.xvid')


class Video(object):
    """Base class for videos.

    Represent a video, existing or not.

    :param str name: name or path of the video.
    :param str source: source of the video (HDTV, Web, Blu-ray, ...).
    :param str release_group: release group of the video.
    :param str streaming_service: streaming_service of the video.
    :param str resolution: resolution of the video stream (480p, 720p, 1080p or 1080i).
    :param str video_codec: codec of the video stream.
    :param str audio_codec: codec of the main audio stream.
    :param str imdb_id: IMDb id of the video.
    :param dict hashes: hashes of the video file by provider names.
    :param int size: size of the video file in bytes.
    :param set subtitle_languages: existing subtitle languages.

    """
    def __init__(self, name, source=None, release_group=None, resolution=None, streaming_service=None,
                 video_codec=None, audio_codec=None, imdb_id=None, hashes=None, size=None, subtitle_languages=None):
        #: Name or path of the video
        self.name = name

        #: Source of the video (HDTV, Web, Blu-ray, ...)
        self.source = source

        #: Release group of the video
        self.release_group = release_group

        #: Streaming service of the video
        self.streaming_service = streaming_service

        #: Resolution of the video stream (480p, 720p, 1080p or 1080i)
        self.resolution = resolution

        #: Codec of the video stream
        self.video_codec = video_codec

        #: Codec of the main audio stream
        self.audio_codec = audio_codec

        #: IMDb id of the video
        self.imdb_id = imdb_id

        #: Hashes of the video file by provider names
        self.hashes = hashes or {}

        #: Size of the video file in bytes
        self.size = size

        #: Existing subtitle languages
        self.subtitle_languages = subtitle_languages or set()

    @property
    def exists(self):
        """Test whether the video exists"""
        return os.path.exists(self.name)

    @property
    def age(self):
        """Age of the video"""
        if self.exists:
            return datetime.utcnow() - datetime.utcfromtimestamp(os.path.getmtime(self.name))

        return timedelta()

    @classmethod
    def fromguess(cls, name, guess):
        """Create an :class:`Episode` or a :class:`Movie` with the given `name` based on the `guess`.

        :param str name: name of the video.
        :param dict guess: guessed data.
        :raise: :class:`ValueError` if the `type` of the `guess` is invalid

        """
        if guess['type'] == 'episode':
            return Episode.fromguess(name, guess)

        if guess['type'] == 'movie':
            return Movie.fromguess(name, guess)

        raise ValueError('The guess must be an episode or a movie guess')

    @classmethod
    def fromname(cls, name):
        """Shortcut for :meth:`fromguess` with a `guess` guessed from the `name`.

        :param str name: name of the video.

        """
        return cls.fromguess(name, guessit(name))

    def __repr__(self):
        return '<%s [%r]>' % (self.__class__.__name__, self.name)

    def __hash__(self):
        return hash(self.name)


class Episode(Video):
    """Episode :class:`Video`.

    :param str series: series of the episode.
    :param int season: season number of the episode.
    :param int or list episodes: episode numbers of the episode.
    :param str title: title of the episode.
    :param int year: year of the series.
    :param country: Country of the series.
    :type country: :class:`~babelfish.country.Country`
    :param bool original_series: whether the series is the first with this name.
    :param int tvdb_id: TVDB id of the episode.
    :param list alternative_series: alternative names of the series
    :param \*\*kwargs: additional parameters for the :class:`Video` constructor.

    """
    def __init__(self, name, series, season, episodes, title=None, year=None, country=None, original_series=True,
                 tvdb_id=None, series_tvdb_id=None, series_imdb_id=None, alternative_series=None, **kwargs):
        super(Episode, self).__init__(name, **kwargs)

        #: Series of the episode
        self.series = series

        #: Season number of the episode
        self.season = season

        #: Episode numbers of the episode
        self.episodes = ensure_list(episodes)

        #: Title of the episode
        self.title = title

        #: Year of series
        self.year = year

        #: The series is the first with this name
        self.original_series = original_series

        #: Country of the series
        self.country = country

        #: TVDB id of the episode
        self.tvdb_id = tvdb_id

        #: TVDB id of the series
        self.series_tvdb_id = series_tvdb_id

        #: IMDb id of the series
        self.series_imdb_id = series_imdb_id

        #: Alternative names of the series
        self.alternative_series = alternative_series or []

    @property
    def episode(self):
        return min(self.episodes) if self.episodes else None

    def matches(self, series):
        return matches_title(series, self.series, self.alternative_series)

    @classmethod
    def fromguess(cls, name, guess):
        if guess['type'] != 'episode':
            raise ValueError('The guess must be an episode guess')

        if 'title' not in guess or 'episode' not in guess:
            raise ValueError('Insufficient data to process the guess')

        return cls(name, guess['title'], guess.get('season', 1), guess.get('episode'), title=guess.get('episode_title'),
                   year=guess.get('year'), country=guess.get('country'),
                   original_series='year' not in guess and 'country' not in guess,
                   source=guess.get('source'), alternative_series=ensure_list(guess.get('alternative_title')),
                   release_group=guess.get('release_group'), streaming_service=guess.get('streaming_service'),
                   resolution=guess.get('screen_size'),
                   video_codec=guess.get('video_codec'), audio_codec=guess.get('audio_codec'))

    @classmethod
    def fromname(cls, name):
        return cls.fromguess(name, guessit(name, {'type': 'episode'}))

    def __repr__(self):
        return '<{cn} [{series}{open}{country}{sep}{year}{close} s{season:02d}e{episodes}]>'.format(
            cn=self.__class__.__name__, series=self.series, year=self.year or '', country=self.country or '',
            season=self.season, episodes='-'.join(map(lambda v: '{:02d}'.format(v), self.episodes)),
            open=' (' if not self.original_series else '',
            sep=') (' if self.year and self.country else '',
            close=')' if not self.original_series else ''
        )


class Movie(Video):
    """Movie :class:`Video`.

    :param str title: title of the movie.
    :param int year: year of the movie.
    :param country: Country of the movie.
    :type country: :class:`~babelfish.country.Country`
    :param list alternative_titles: alternative titles of the movie
    :param \*\*kwargs: additional parameters for the :class:`Video` constructor.

    """
    def __init__(self, name, title, year=None, country=None, alternative_titles=None, **kwargs):
        super(Movie, self).__init__(name, **kwargs)

        #: Title of the movie
        self.title = title

        #: Year of the movie
        self.year = year

        #: Country of the movie
        self.country = country

        #: Alternative titles of the movie
        self.alternative_titles = alternative_titles or []

    def matches(self, title):
        return matches_title(title, self.title, self.alternative_titles)

    @classmethod
    def fromguess(cls, name, guess):
        if guess['type'] != 'movie':
            raise ValueError('The guess must be a movie guess')

        if 'title' not in guess:
            raise ValueError('Insufficient data to process the guess')

        return cls(name, guess['title'], source=guess.get('source'), release_group=guess.get('release_group'),
                   streaming_service=guess.get('streaming_service'),
                   resolution=guess.get('screen_size'), video_codec=guess.get('video_codec'),
                   alternative_titles=ensure_list(guess.get('alternative_title')),
                   audio_codec=guess.get('audio_codec'), year=guess.get('year'), country=guess.get('country'))

    @classmethod
    def fromname(cls, name):
        return cls.fromguess(name, guessit(name, {'type': 'movie'}))

    def __repr__(self):
        return '<{cn} [{title}{open}{country}{sep}{year}{close}]>'.format(
            cn=self.__class__.__name__, title=self.title, year=self.year or '', country=self.country or '',
            open=' (' if self.year or self.country else '',
            sep=') (' if self.year and self.country else '',
            close=')' if self.year or self.country else ''
        )
