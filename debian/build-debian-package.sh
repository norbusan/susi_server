#!/bin/bash

if [ ! -r src/ai/susi/DAO.java ] ; then
  echo "Are you in the susi_server root directory?" >&2
  exit 1
fi

source bin/preload.sh

JARFILE="build/libs/susi_server-all.jar"
GITHASH=`git log -n 1 --pretty=format:"%h"`
DATESTR=`date +%Y%m%d`
VERSION=${DATESTR}+git${GITHASH}

DDIR=susi-server-$VERSION
if [ -r $DDIR ] ; then
  echo "Already existing $DDIR, exiting." >&2
  exit 1
fi

SSERVER_BASE=/usr/share/susi-server
SSERVER_VAR=/var/lib/susi-server
mkdir -p $DDIR/DEBIAN
mkdir -p $DDIR$SSERVER_BASE/bin
mkdir -p $DDIR$SSERVER_BASE/release
mkdir -p $DDIR$SSERVER_BASE/build/libs
mkdir -p $DDIR$SSERVER_VAR
cp -R conf $DDIR$SSERVER_BASE
cp -R html $DDIR$SSERVER_BASE
cp $JARFILE $DDIR$SSERVER_BASE/build/libs
cp bin/*.sh $DDIR$SSERVER_BASE/bin

mkdir $DDIR$SSERVER_VAR/data
ln -s $SSERVER_VAR/data $DDIR$SSERVER_BASE/data

# now for debian necessary files
mkdir -p $DDIR/usr/share/doc/susi-server
# TODO update the control/changelog file for current version number!
cp debian/changelog $DDIR/usr/share/doc/susi-server/changelog.Debian
gzip -9 $DDIR/usr/share/doc/susi-server/changelog.Debian
cp debian/copyright $DDIR/usr/share/doc/susi-server/
cp debian/control $DDIR/DEBIAN

# TODO install systemd files!!!
# TODO starter script?



#
# do some cleanup
chmod -R ugo-x `find $DDIR$SSERVER_BASE/ -type f`
chmod ugo+x $DDIR$SSERVER_BASE/bin/*.sh


fakeroot dpkg-deb --build $DDIR .

