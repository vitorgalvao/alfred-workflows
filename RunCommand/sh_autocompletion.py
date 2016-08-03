#!/usr/bin/env python

# TUTORIAL
# http://www.deanishe.net/alfred-workflow/tutorial_1.html#adding-a-script-filter

import os
import sys
import re
from subprocess import check_output, CalledProcessError, PIPE

from workflow import (Workflow, ICON_INFO, web)

API_KEY = 'com.vitorgalvao.alfred.runcommand'


def uniq_list(l):
    used = []
    return [x for x in l if x not in used and (used.append(x) or True)]


def get_stdout_lines(qu, suppress=True):
    """Calls command and returns standard output in list as lines"""
    if suppress:
        try:
            ls_output = check_output(qu, shell=True, stderr=PIPE).decode('utf-8').splitlines()
            # return [s.strip().replace('\x08', '') for s in ls_output]
        except CalledProcessError:
            ls_output = []
    else:
        ls_output = check_output(qu, shell=True).decode('utf-8').splitlines()
    rx = '(\x08)..(\x08)'
    return [re.subn(rx, '', s.strip())[0].replace('\x08', '') for s in ls_output if s]


def main(wf):
    # Get query from Alfred

    qu = r"osascript -e 'tell application" + r'"Finder"' + r"to return (quoted form of POSIX path of (target of window 1 as alias))'"
    out = get_stdout_lines(qu)
    if out:
        os.chdir(out[0].replace("'", ""))

    res = list()

    if wf.args:     # len(wf.args) != 0?
        query = wf.args[0]
        query = query.replace(r'\ ', r' ')

        if not query.endswith(' '):
            words = query.split(' ')
            wm1 = words[-1]
            wm1_fc = wm1[0]
            if wm1_fc in ['-', '+']:
                if len(words) > 1:
                    wm2 = words[-2]

                    # OPTIONS from man
                    # TODO: sort out multiline grep!
                    # qu = r"man -P cat {wm2} | pcregrep -M '^ *{pm}.*\n.*\n'".format(wm2=wm2, pm=wm1_fc)
                    qu = "man -P cat {wm2} | grep -E '^ *{pm}'".format(wm2=wm2, pm=wm1_fc)
                    res += get_stdout_lines(qu)

                    # OPTIONS from help
                    qu = r"help {wm2} | grep -E '^ *{pm}'".format(wm2=wm2, pm=wm1_fc)
                    res += get_stdout_lines(qu)

                    # OPTIONS from --help
                    qu = r"{wm2} --help | grep -E '^ *{pm}'".format(wm2=wm2, pm=wm1_fc)
                    res += get_stdout_lines(qu)
                    if len(wm1) != 1:
                        res = [s for s in res if re.search(wm1, s, flags=0) is not None]

            else:
                # Get directory
                qu = r"compgen -d {wm1}".format(wm1=wm1) # k
                res += [s + '/' for s in get_stdout_lines(qu)]
                # Get commands (beginning first)
                qu = r"compgen -A function -abc {wm1}".format(wm1=wm1) # k
                res += get_stdout_lines(qu)
                # Get commands (any place)
                qu = r"compgen -A function -abc | grep {wm1}".format(wm1=wm1) # k
                res += get_stdout_lines(qu)

    if not len(res):
        res.append('Empty')

    # PRINT
    for item in uniq_list(res):
        wf.add_item(title=item,        # title
                    subtitle='',     # subtitle
                    # icon=ICON_INFO,    # icon
                    arg=query,             # {query} output
                    valid=True)         # valid argument!

    wf.send_feedback()         # Send the results to Alfred as XML


if (__name__ == "__main__"):
    wf = Workflow()
    sys.exit(wf.run(main))
