#!/usr/bin/env bash
# build_godot_ubi8.sh
#
godotver='3.2.3'
ctr=$(buildah from registry.access.redhat.com/ubi8/ubi)
#mountpoint=$(buildah mount $ctr)
#mkdir $mountpoint/var/www
buildah config --workingdir /usr/bin $ctr
buildah config --env PATH=$PATH:/usr/bin $ctr
buildah copy $ctr . /usr/local/games/
buildah run --isolation rootless $ctr /bin/sh -c "microdnf update; \
microdnf -y install unzip; \
curl -sSL https://downloads.tuxfamily.org/godotengine/$godotver/Godot_v$godotver-stable_linux_headless.64.zip | tar -xf - -C /usr/bin/; \
mv /usr/bin/Godot_v$godotver-stable_linux_headless.64 /usr/bin/godot"
#buildah run --isolation rootless $ctr /bin/sh -c "curl -sSL https://downloads.tuxfamily.org/godotengine/$godotver/Godot_v$godotver-stable_export_templates.tpz -o godot_templates.zip  | tar -xf - -C /usr/local/games;"
buildah config --entrypoint "godot /usr/local/games/project.godot --export \"Linux/X11\"" $ctr
buildah commit --squash $ctr godot-app
buildah unmount $ctr
buildah rm $ctr