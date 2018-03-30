#!/bin/bash

NAME_ROOT=xrjv1-electrum
PYTHON_VERSION=3.5

# These settings probably don't need any change
export BUILDPREFIX=./build-temp
export PYTHONDONTWRITEBYTECODE=1
export PYTHONHASHSEED=22

PYHOME=/usr/lib/python$PYTHON_VERSION
PYTHON="python3 -OO -B"


# Let's begin!
cd `dirname $0`
set -e

mkdir -p tmp
cd tmp

for repo in xrjv1-electrum xrjv1-electrum-locale xrjv1-electrum-icons; do
    if [ -d $repo ]; then
	cd $repo
	git pull
	git checkout master
	cd ..
    else
	URL=https://github.com/higheredgesoftware/$repo.git
	git clone -b master $URL $repo
    fi
done

pushd xrjv1-electrum-locale
for i in ./locale/*; do
    dir=$i/LC_MESSAGES
    mkdir -p $dir
    msgfmt --output-file=$dir/electrum.mo $i/electrum.po || true
done
popd

pushd xrjv1-electrum
if [ ! -z "$1" ]; then
    git checkout $1
fi

VERSION=`git describe --tags`
echo "Last commit: $VERSION"
find -exec touch -d '2000-11-11T11:11:11+00:00' {} +
popd

mkdir -p $BUILDPREFIX/electrum
rm -rf $BUILDPREFIX/electrum
cp -r xrjv1-electrum $BUILDPREFIX/electrum
cp xrjv1-electrum/LICENCE .
cp -r xrjv1-electrum-locale/locale $BUILDPREFIX/electrum/lib/
cp xrjv1-electrum-icons/icons_rc.py $BUILDPREFIX/electrum/gui/qt/

# Install frozen dependencies
$PYTHON -m pip install -r ../../deterministic-build/requirements.txt

$PYTHON -m pip install -r ../../deterministic-build/requirements-hw.txt

pushd $BUILDPREFIX/electrum
$PYTHON setup.py install
popd

cd ..

rm -rf dist/

# set timestamps in dist, in order to make the installer reproducible
pushd dist
find -exec touch -d '2000-11-11T11:11:11+00:00' {} +
popd


echo "Done."
