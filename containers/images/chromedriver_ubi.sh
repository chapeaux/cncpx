#!/bin/sh
ctrimg=chromedriver-ubi
ctr=$(buildah from registry.access.redhat.com/ubi9/ubi-minimal)
# mountpoint=$(buildah mount $ctr)
#mkdir -p $mountpoint/nodejs/

# CHROME AND CHROMEDRIVER INSTALLATION
# FROM https://github.com/scheib/chromium-latest-linux
LASTCHANGE_URL="https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2FLAST_CHANGE?alt=media"
REVISION=$(curl -s -S $LASTCHANGE_URL)
# echo "latest revision is $REVISION"
ZIP_URL="https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F$REVISION%2Fchrome-linux.zip?alt=media"
ZIP_FILE="${REVISION}-chrome-linux.zip"
CR_ZIP_URL="https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F$REVISION%2Fchromedriver_linux64.zip?alt=media"
CR_ZIP_FILE="${REVISION}-chromedriver-linux64.zip"

buildah run --isolation rootless $ctr /bin/sh -c "microdnf -y update; \
microdnf -y --nodocs install curl-minimal tar gzip unzip libgcc libstdc++ glib2 nss libxcb \
atk at-spi2-atk cups libdrm libXcomposite libXdamage libXrandr mesa-libgbm \
libxkbcommon pango alsa-lib git make; \
microdnf clean all; \
useradd -m -g root cruser;"

buildah run --user cruser --isolation rootless $ctr /bin/sh -c "cd ~; \
rm -rf ~/src/$REVISION; \
mkdir -p ~/src/$REVISION; \
curl -# $ZIP_URL > ~/src/$REVISION/$ZIP_FILE; \
unzip ~/src/$REVISION/$ZIP_FILE -d ~/src; \
curl -# $CR_ZIP_URL > ~/src/$REVISION/$CR_ZIP_FILE; \
unzip ~/src/$REVISION/$CR_ZIP_FILE -d ~/src; \
rm -rf ~/src/$REVISION; \
mkdir -p ~/bin; \
ln -s ~/src/chrome-linux/chrome ~/bin/chrome; \
ln -s ~/src/chromedriver_linux64/chromedriver ~/bin/chromedriver;"

buildah config --user cruser --workingdir /home/cruser $ctr

# ctr=$(buildah from registry.access.redhat.com/ubi9/ubi-micro)
# mountpoint=$(buildah mount $ctr)
#rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
# dnf install --installroot $mountpoint \
# --releasever 8 \
# --setopt install_weak_deps=false \
# --nodocs -y unzip libgcc libstdc++ glib2 nss libxcb \
# atk at-spi2-atk cups libdrm libXcomposite libXdamage mesa-libgbm \
# libxkbcommon pango alsa-lib
# buildah config --env PATH=$PATH:/usr/src/chrome-linux:/usr/src/chromedriver_linux64:$ctr
# buildah config --env PATH=$PATH:/usr/src/chrome-linux:/usr/src/chromedriver_linux64:/usr/src/node/bin: $ctr
# # NODE INSTALLATION
# NODE_VER=14.20.0
# NODE_URL="https://nodejs.org/download/release/v$NODE_VER/node-v$NODE_VER-linux-x64.tar.gz"
# NODE_FILE="node-v$NODE_VER.tar.gz"
# echo "fetching $NODE_URL"
# curl -# $NODE_URL > $mountpoint/$NODE_FILE
# tar -xvzf $mountpoint/$NODE_FILE -C $mountpoint/usr/src/
# rm -R $mountpoint/$NODE_FILE
# mv $mountpoint/usr/src/node-v$NODE_VER-linux-x64 $mountpoint/usr/src/node

buildah commit --squash $ctr $ctrimg
buildah config --author "Luke Dary" --created-by "kamiquasi" --label name="${ctrimg}" $ctr
# buildah push $ctrimg docker://quay.io/chapeaux/chromedriver-ubi:$REVISION
# buildah push $ctrimg docker://quay.io/chapeaux/chromedriver-ubi:latest
buildah unmount $ctr
buildah rm $ctr
