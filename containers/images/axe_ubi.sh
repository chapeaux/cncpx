#!/bin/sh
ctrimg=axe-ubi
ctr=$(buildah from registry.access.redhat.com/ubi9/ubi-minimal)
NODE_VER=14.20.0
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
useradd -m -g root nodeusr;"

buildah run --user nodeusr --isolation rootless $ctr /bin/sh -c "cd ~; \
rm -rf ~/src/$REVISION; \
mkdir -p ~/src/$REVISION; \
curl -# $ZIP_URL > ~/src/$REVISION/$ZIP_FILE; \
unzip ~/src/$REVISION/$ZIP_FILE -d ~/src; \
curl -# $CR_ZIP_URL > ~/src/$REVISION/$CR_ZIP_FILE; \
unzip ~/src/$REVISION/$CR_ZIP_FILE -d ~/src; \
rm -rf ~/src/$REVISION; \
mkdir -p ~/bin; \
ln -s ~/src/chrome-linux/chrome ~/bin/chrome; \
ln -s ~/src/chromedriver_linux64/chromedriver ~/bin/chromedriver; \
curl -sL https://bit.ly/n-install | bash -s -- -y $NODE_VER; \
echo 'alias axe=\"axe --chromedriver-path='/home/nodeusr/bin/chromedriver'\"' >> ~/.bashrc; \
source ~/.bashrc; \
npm install -g @axe-core/cli;"

buildah config --user nodeusr --workingdir /home/nodeusr $ctr

buildah commit --squash $ctr $ctrimg
buildah config --author "Luke Dary" --created-by "kamiquasi" --label name="${ctrimg}" $ctr
buildah push $ctrimg docker://quay.io/chapeaux/axe-ubi:$NODE_VER
buildah push $ctrimg docker://quay.io/chapeaux/axe-ubi:latest
buildah unmount $ctr
buildah rm $ctr