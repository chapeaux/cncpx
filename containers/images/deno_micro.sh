#!/bin/sh
ctrimg=deno-micro
denover=1.21.0
ctr=$(buildah from registry.access.redhat.com/ubi8/ubi-micro)
mountpoint=$(buildah mount $ctr)
dnf install --installroot $mountpoint \
--releasever 8 \
--setopt install_weak_deps=false \
--nodocs -y unzip libgcc
curl -fsSL https://deno.land/x/install/install.sh | DENO_INSTALL=$mountpoint/usr/local sh
buildah commit --squash $ctr $ctrimg
buildah config --author "Luke Dary" --created-by "kamiquasi" --label name="${ctrimg}" $ctr
buildah push $ctrimg docker://quay.io/chapeaux/deno:$denover
buildah push $ctrimg docker://quay.io/chapeaux/deno:latest
buildah unmount $ctr