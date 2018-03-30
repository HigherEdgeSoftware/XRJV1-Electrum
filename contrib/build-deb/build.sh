#!/bin/bash
# Lucky number
export PYTHONHASHSEED=22

if [ ! -z "$1" ]; then
    to_build="$1"
fi

here=$(dirname "$0")
test -n "$here" -a -d "$here" || exit

echo "Clearing $here/build and $here/dist..."
rm "$here"/build/* -rf
rm "$here"/dist/* -rf

$here/build-electrum-git.sh $to_build && \
echo "Done."
