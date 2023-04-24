#!/bin/sh
ctrimg=deno-micro
denover=1.32.5
ctr=$(buildah from registry.access.redhat.com/ubi9/ubi-micro)
mountpoint=$(buildah mount $ctr)
dnf install --installroot $mountpoint \
--releasever 9 \
--setopt install_weak_deps=false \
--nodocs -y unzip libgcc
curl -fsSL https://deno.land/x/install/install.sh | DENO_INSTALL=$mountpoint/usr/local sh
buildah commit --squash $ctr $ctrimg
buildah config --author "Luke Dary" --created-by "kamiquasi" --label name="${ctrimg}" $ctr
buildah push $ctrimg docker://quay.io/chapeaux/deno:$denover
buildah push $ctrimg docker://quay.io/chapeaux/deno:latest
buildah config --entrypoint "sleep infinity" $ctr
buildah unmount $ctr
buildah commit --squash $ctr $ctrimg
buildah push $ctrimg docker://quay.io/chapeaux/deno-che:$denover
buildah push $ctrimg docker://quay.io/chapeaux/deno-che:latest
buildah rm $ctr
