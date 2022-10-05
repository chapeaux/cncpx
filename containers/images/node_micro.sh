#!/bin/sh
ctrimg=nodejs
ctr=$(buildah from registry.access.redhat.com/ubi8/ubi-minimal)
mountpoint=$(buildah mount $ctr)
#mkdir -p $mountpoint/nodejs/
buildah run --isolation rootless $ctr /bin/sh -c "microdnf update; \
microdnf -y install curl tar gzip libgcc libstdc++; \
microdnf clean all;"
#dnf install --installroot $mountpoint \
#--releasever 8 \
#--setopt install_weak_deps=false \
#--nodocs -y libgcc libstdc++
#unzip glib2 nss libxcb atk at-spi2-atk cups libdrm libXcomposite libXdamage mesa-libgbm \
#libxkbcommon pango alsa-lib
buildah config --env PATH=$PATH:/node/bin: $ctr

# NODE INSTALLATION
NODE_VER=14.20.0
NODE_URL="https://nodejs.org/download/release/v$NODE_VER/node-v$NODE_VER-linux-x64.tar.gz"
NODE_FILE="node-v$NODE_VER.tar.gz"

#echo "fetching $NODE_URL"
curl -# $NODE_URL > $mountpoint/$NODE_FILE
tar -xvzf $mountpoint/$NODE_FILE -C $mountpoint/usr/src/
rm -R $mountpoint/$NODE_FILE
mv $mountpoint/usr/src/node-v$NODE_VER-linux-x64 $mountpoint/usr/src/node

buildah commit --squash $ctr $ctrimg
buildah config --author "Luke Dary" --created-by "kamiquasi" --label name="${ctrimg}" $ctr
#buildah push $ctrimg docker://quay.io/chapeaux/node-ubi:$NODE_VER
#buildah push $ctrimg docker://quay.io/chapeaux/node-ubi:latest
buildah unmount $ctr
buildah rm $ctr
