#!/bin/sh

# NODE INSTALLATION
NODE_VER=14.20.0
NODE_URL="https://nodejs.org/download/release/v$NODE_VER/node-v$NODE_VER-linux-x64.tar.gz"
NODE_FILE="node-v$NODE_VER.tar.gz"

ctrimg=nodejs
ctr=$(buildah from registry.access.redhat.com/ubi9/ubi-minimal)
# mountpoint=$(buildah mount $ctr)
#mkdir -p $mountpoint/nodejs/
buildah run --isolation rootless $ctr /bin/sh -c "microdnf -y update; \
microdnf -y install curl-minimal tar gzip libgcc libstdc++ git make; \
microdnf clean all; 
useradd -m -g root nodeusr;"
buildah run --user nodeusr --isolation rootless $ctr /bin/sh -c "cd ~; \
curl -sL https://bit.ly/n-install | bash -s -- -y $NODE_VER;"

buildah config --user nodeusr --workingdir /home/nodeusr
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
#buildah push $ctrimg docker://quay.io/chapeaux/node-ubi:$NODE_VER
#buildah push $ctrimg docker://quay.io/chapeaux/node-ubi:latest
buildah unmount $ctr
buildah rm $ctr
