#!/bin/sh
ctrimg=deno
ctr=$(buildah from registry.access.redhat.com/ubi8/ubi-minimal)
mountpoint=$(buildah mount $ctr)
mkdir -p $mountpoint/projects/.deno
buildah config --workingdir /projects $ctr
buildah config --env DENO_INSTALL=/usr/local $ctr
buildah config --env DENO_DIR=/projects/.deno $ctr
buildah config --env PATH=$PATH:/usr/local/bin $ctr
#buildah run --isolation rootless $ctr /bin/sh -c "curl -fsSL https://deno.land/x/install/install.sh | bash;"
buildah run --isolation rootless $ctr /bin/sh -c "microdnf update; \
microdnf -y install unzip; \
curl -fsSL https://deno.land/x/install/install.sh | sh; \
microdnf clean all;"
#buildah config --entrypoint "tail -f /dev/null" $ctr
buildah config --author "Luke Dary" --created-by "ldary" --label name="${ctrimg}" $ctr
buildah unmount $ctr
buildah commit --squash $ctr $ctrimg
buildah push $ctrimg docker://quay.io/ldary/deno
buildah rm $ctr
