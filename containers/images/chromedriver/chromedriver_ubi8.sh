#!/bin/sh
ctrimg=chromedriver-ubi
ctr=$(buildah from registry.access.redhat.com/ubi8/ubi-micro)
mountpoint=$(buildah mount $ctr)
#rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf install --installroot $mountpoint \
--releasever 8 \
--setopt install_weak_deps=false \
--nodocs -y unzip
NODE_VER=14.20.0
NODE_URL="https://nodejs.org/download/release/v$NODE_VER/node-v$NODE_VER-linux-x64.tar.gz"
NODE_FILE="node-v$NODE_VER.tar.gz"
mkdir $mountpoint/usr/src/node
echo "fetching $NODE_URL"
curl -# $NODE_URL > $mountpoint/$NODE_FILE
tar -xvzf $mountpoint/$NODE_FILE -C $mountpoint/usr/src/
rm -R $mountpoint/$NODE_FILE
cp -R $mountpoint/usr/src/node-v$NODE_VER-linux-x64/bin/* $mountpoint/usr/local/bin
cp -R $mountpoint/usr/src/node-v$NODE_VER-linux-x64/lib/* $mountpoint/usr/local/lib
cp -R $mountpoint/usr/src/node-v$NODE_VER-linux-x64/share/* $mountpoint/usr/local/share
cp -R $mountpoint/usr/src/node-v$NODE_VER-linux-x64/include/* $mountpoint/usr/local/include

# FROM https://github.com/scheib/chromium-latest-linux
LASTCHANGE_URL="https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2FLAST_CHANGE?alt=media"
REVISION=$(curl -s -S $LASTCHANGE_URL)
echo "latest revision is $REVISION"
ZIP_URL="https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F$REVISION%2Fchrome-linux.zip?alt=media"
ZIP_FILE="${REVISION}-chrome-linux.zip"
CR_ZIP_URL="https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F$REVISION%2Fchromedriver-linux64.zip?alt=media"
CR_ZIP_FILE="${REVISION}-chromedriver-linux64.zip"
echo "fetching $ZIP_URL"
echo "fetching $CR_ZIP_URL"
rm -rf $mountpoint/$REVISION
mkdir $mountpoint/$REVISION
pushd $mountpoint/$REVISION
curl -# $ZIP_URL > $ZIP_FILE
curl -# $CR_ZIP_URL > $CR_ZIP_FILE
echo "unzipping.."
unzip $ZIP_FILE -d $mountpoint/usr/src
unzip $CR_ZIP_FILE -d $mountpoint/usr/src
popd
rm -rf $mountpoint/$REVISION
ln -s $mountpoint/usr/src/chrome-linux/chrome $mountpoint/usr/local/bin/chrome
ln -s $mountpoint/usr/src/chromedriver_linux64/chromedriver $mountpoint/usr/local/bin/chromedriver
buildah commit --squash $ctr $ctrimg
buildah config --author "Luke Dary" --created-by "kamiquasi" --label name="${ctrimg}" $ctr
#buildah push $ctrimg docker://quay.io/chapeaux/chromedriver-ubi:$NODE_VER
#buildah push $ctrimg docker://quay.io/chapeaux/chromedriver-ubi:latest
buildah unmount $ctr
buildah rm $ctr
