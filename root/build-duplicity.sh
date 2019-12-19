#!/usr/bin/env bash

# build-duplicity.sh is used to build and rebuild duplicity
# backup software after Glibc or Python changes. The latest
# stable duplicity is 0.7.19, and it resides in root's
# home folder.

# Run in a subshell to preserve PWD
(
    if ! cd duplicity-0.7.19
    then
        echo "duplicity-0.7.19/ does not exist"
        exit 1
    fi

    python setup.py clean 2>/dev/null

    if ! python setup.py build
    then
        echo "setup.py build failed"
        exit 1
    fi

    if ! python setup.py install --prefix=/usr/local
    then
        echo "setup.py install failed"
        exit 1
    fi

    echo "Duplicity has been built and installed."
    echo "Run 'hash -r' to clear Bash program cache."

    exit 0
)
