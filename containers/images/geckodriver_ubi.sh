#!/bin/sh
ctrimg=geckodriver-ubi
ctr=$(buildah from registry.access.redhat.com/ubi9/ubi-minimal)

GECKODRIVER_VER="0.32.0"
GECKODRIVER_URL="https://github.com/mozilla/geckodriver/releases/download/v$GECKODRIVER_VER/geckodriver-v$GECKODRIVER_VER-linux64.tar.gz"

# FROM https://github.com/scheib/chromium-latest-linux

buildah run --isolation rootless $ctr /bin/sh -c "microdnf -y update; \
microdnf -y --nodocs install wget tar; \
microdnf clean all; \
useradd -m -g root geckousr;"

buildah run --user geckousr --isolation rootless $ctr /bin/sh -c "cd ~; \
wget -qO- \"https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US\" | tar -jx -C /usr/local/; \
ln -s /usr/local/firefox/firefox /usr/bin/firefox; \
wget -qO- $GECKODRIVER_URL | tar xvz -C /usr/local/firefox/
ln -s /usr/local/firefox/geckodriver /usr/bin/geckodriver;"

buildah config --user geckousr --workingdir /home/geckousr $ctr

buildah commit --squash $ctr $ctrimg
buildah config --author "Luke Dary" --created-by "kamiquasi" --label name="${ctrimg}" $ctr
# buildah push $ctrimg docker://quay.io/chapeaux/chromedriver-ubi:$REVISION
# buildah push $ctrimg docker://quay.io/chapeaux/chromedriver-ubi:latest
buildah unmount $ctr
buildah rm $ctr
