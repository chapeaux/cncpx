#!/bin/sh
ctrimg=deno
denover=1.11.2
ctr=$(buildah from registry.access.redhat.com/ubi8/ubi-minimal)
mountpoint=$(buildah mount $ctr)
mkdir -p $mountpoint/projects/.deno
buildah config --workingdir /projects $ctr
buildah config --env DENO_INSTALL=/usr/local $ctr
buildah config --env DENO_DIR=/projects/.deno $ctr
buildah config --env PATH=$PATH:/usr/local/bin $ctr
buildah run --isolation rootless $ctr /bin/sh -c "microdnf update; \
microdnf -y install unzip; \
curl -fsSL https://deno.land/x/install/install.sh | sh -s v${denover}; \
microdnf clean all;"
buildah config --entrypoint "sleep infinity" $ctr
buildah config --author "Luke Dary" --created-by "ldary" --label name="${ctrimg}" $ctr
buildah commit --squash $ctr $ctrimg
buildah unmount $ctr
buildah commit --squash $ctr $ctrimg
buildah push $ctrimg docker://quay.io/ldary/deno-crw:$denover
buildah push $ctrimg docker://quay.io/ldary/deno-crw:latest
buildah rm $ctr
