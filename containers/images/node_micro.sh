#!/bin/sh

# NODE INSTALLATION
NODE_VER=20.0.0
NODE_URL="https://nodejs.org/download/release/v$NODE_VER/node-v$NODE_VER-linux-x64.tar.gz"
NODE_FILE="node-v$NODE_VER.tar.gz"

ctrimg=nodejs-micro
ctr=$(buildah from registry.access.redhat.com/ubi9/ubi-micro)
mountpoint=$(buildah mount $ctr)
dnf install --installroot $mountpoint \
--releasever 9 \
--setopt install_weak_deps=false \
--nodocs -y libgcc libstdc++
curl -o $mountpoint/tmp/$NODE_FILE $NODE_URL;
tar -xzf $mountpoint/tmp/$NODE_FILE -C $mountpoint/usr/local/lib;
rm -R $mountpoint/tmp/$NODE_FILE;
#ln -sf $mountpoint/usr/local/lib/node-v$NODE_VER-linux-x64/bin/node $mountpoint/usr/local/bin;
cp $mountpoint/usr/local/lib/node-v$NODE_VER-linux-x64/bin/* $mountpoint/usr/local/bin;

# mkdir -p $mountpoint/nodejs/
# buildah run --isolation rootless $ctr /bin/sh -c "microdnf -y update; \
# microdnf -y install curl-minimal tar gzip libgcc libstdc++ git make; \
# microdnf clean all; 
# useradd -m -g root nodeusr;"
# buildah run --user nodeusr --isolation rootless $ctr /bin/sh -c "cd ~; \
# curl -sL https://bit.ly/n-install | N_PREFIX=~/.local bash -s -- -y $NODE_VER;"

# buildah config --user nodeusr --workingdir /home/nodeusr $ctr
# curl -# $NODE_URL > ~/$NODE_FILE; \
# tar -xvzf ~/$NODE_FILE -C ~; \
# rm -R ~/$NODE_FILE; \
# mv ~/node-v$NODE_VER-linux-x64 ~/node; \
# chown -R root:root 
# ln -sf ~/node/bin/node /usr/local/bin; \
# mkdir ~/.npm-global; \
# npm config set prefix '~/.npm-global';

#echo "fetching $NODE_URL"
#dnf install --installroot $mountpoint \
#--releasever 8 \
#--setopt install_weak_deps=false \
#--nodocs -y libgcc libstdc++
#unzip glib2 nss libxcb atk at-spi2-atk cups libdrm libXcomposite libXdamage mesa-libgbm \
#libxkbcommon pango alsa-lib
#buildah config --env PATH=$PATH:~/node/bin $ctr

buildah commit --squash $ctr $ctrimg
buildah config --author "Luke Dary" --created-by "kamiquasi" --label name="${ctrimg}" $ctr
buildah push $ctrimg docker://quay.io/chapeaux/node-ubi:$NODE_VER
buildah push $ctrimg docker://quay.io/chapeaux/node-ubi:latest
buildah unmount $ctr
buildah rm $ctr
