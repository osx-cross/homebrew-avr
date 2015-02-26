#!/bin/bash

set -e

PACKAGE="$1"

log_filter () {
    sed \
       -e 'h;s/.\[[0-9;]*m//g' \
       -e 's/^==> Installing \(.*\) dependency: \(.*\)/travis_fold:start:\2/p' \
       -e 'x;/^(.\[[0-9;]*m)\?==>/p;x' \
       -e '/^==> Summary/{N;s/.*Cellar\/\([^\/]*\)\/\([^\/]*\):.*/travis_fold:end:\1/p;}' \
       -e 'd'
}

run_brew () {
    local heartbeat=0
    local pid=""
    echo "travis_fold:start:$1"
    echo "\$ brew $@"
    brew "$@" > >(tee "travis.log" | log_filter) &
    pid="$!"

    while ps -p "$pid" >/dev/null ; do
        let heartbeat=$heartbeat+1

        if test "$heartbeat" -ge 120 ; then
            heartbeat=0
            echo "still running..."
        fi
        sleep 1
    done

    rc="$(wait "$pid" ; echo "$?")"
    echo "travis_fold:end:$1"

    if test "$rc" -ne 0 ; then
        tail -50 "travis.log"
        return "$rc"
    fi
}

run_brew audit "$PACKAGE" || true
run_brew install -v "$PACKAGE"
if grep -q "test do" "$PACKAGE.rb" ; then
    run_brew test "$PACKAGE"
fi
