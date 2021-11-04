#!/bin/sh
ctrimg=deno
denover=1.15.3
ctr=$(buildah from registry.access.redhat.com/ubi9-beta/ubi-minimal)
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
buildah config --author "Luke Dary" --created-by "kamiquasi" --label name="${ctrimg}" $ctr
buildah commit --squash $ctr $ctrimg
buildah push $ctrimg docker://quay.io/chapeaux/deno:$denover-ubi9
buildah push $ctrimg docker://quay.io/chapeaux/deno:latest-ubi9
buildah config --entrypoint "sleep infinity" $ctr
buildah unmount $ctr
buildah commit --squash $ctr $ctrimg
buildah push $ctrimg docker://quay.io/chapeaux/deno-che:$denover-ubi9
buildah push $ctrimg docker://quay.io/chapeaux/deno-che:latest-ubi9
buildah rm $ctr
