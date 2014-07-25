#!/bin/bash

# This script creates a B2G-compatible version of xre.zip for use in buildbot.

set -e

DL_DIR="xregen_downloads"
XRE_DIR="xre"
BIN_DIR="bin"
rm -rf $DL_DIR
mkdir $DL_DIR
rm -rf $XRE_DIR
mkdir $XRE_DIR

echo "Enter Gecko version for which to generate an xre.zip (e.g. 30.0)"
read -p "> " GECKO_VERSION

echo "Enter platform for which to generate an xre.zip, one of: "
echo "   linux"
echo "   linux64"
echo "   osx"
echo "   win32"
read -p "> " PLATFORM

case "$PLATFORM" in
    linux) PLATSTRING="linux-i686";
           XULRUNNER_FILE="xulrunner-$GECKO_VERSION.en-US.$PLATSTRING.sdk.tar.bz2";
           TESTS_FILE="$PLATSTRING/en-US/firefox-$GECKO_VERSION.tests.zip";;
    linux64) PLATSTRING="linux-x86_64";
             XULRUNNER_FILE="xulrunner-$GECKO_VERSION.en-US.$PLATSTRING.sdk.tar.bz2";
             TESTS_FILE="$PLATSTRING/en-US/firefox-$GECKO_VERSION.tests.zip";;
    osx) PLATSTRING="mac";
         XULRUNNER_FILE="xulrunner-$GECKO_VERSION.en-US.mac-x86_64.sdk.tar.bz2";
         BIN_DIR="bin/XUL.framework/Versions/Current";
         TESTS_FILE="$PLATSTRING/en-US/Firefox%20$GECKO_VERSION.tests.zip";;
    win32) PLATSTRING="win32";
           XULRUNNER_FILE="xulrunner-$GECKO_VERSION.en-US.$PLATSTRING.sdk.zip";
           TESTS_FILE="$PLATSTRING/en-US/firefox-$GECKO_VERSION.tests.zip";;
    *) echo "invalid platform"; exit -1;;
esac
XULRUNNER_URL="http://ftp.mozilla.org/pub/mozilla.org/xulrunner/releases/$GECKO_VERSION/sdk/$XULRUNNER_FILE"
TESTS_FILE="http://ftp.mozilla.org/pub/mozilla.org/firefox/nightly/$GECKO_VERSION-candidates/build1/$TESTS_FILE"

cd $DL_DIR
wget $XULRUNNER_URL

wget -O tests.zip $TESTS_FILE

if [ "$PLATFORM" != "win32" ]; then
    tar -xvjf $XULRUNNER_FILE
else
    unzip $XULRUNNER_FILE
fi

unzip tests.zip

cd ..
cp -R $DL_DIR/xulrunner-sdk/bin $XRE_DIR
cp $DL_DIR/bin/ssltunnel* $XRE_DIR/$BIN_DIR
cp -R $DL_DIR/bin/components $XRE_DIR/$BIN_DIR

cd $XRE_DIR
XRE_FILE="xre.$PLATSTRING.zip"
zip -r $XRE_FILE bin/
mv $XRE_FILE ..
cd ..
rm -rf $DL_DIR
rm -rf $XRE_DIR

echo "$XRE_FILE created"
