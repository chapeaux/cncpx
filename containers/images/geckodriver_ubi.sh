#!/bin/sh
ctrimg=geckodriver-ubi
ctr=$(buildah from --add-host localhost:127.0.0.1 --add-host localhost:0.0.0.0 --net "" registry.access.redhat.com/ubi9/ubi-minimal)

GECKODRIVER_VER="0.33.0"
GECKODRIVER_URL="https://github.com/mozilla/geckodriver/releases/download/v$GECKODRIVER_VER/geckodriver-v$GECKODRIVER_VER-linux64.tar.gz"

# FROM https://github.com/scheib/chromium-latest-linux

buildah run --no-hosts --isolation rootless $ctr /bin/sh -c "microdnf -y update; \
microdnf -y --nodocs install wget tar gzip bzip2 shadow-utils gtk3 dbus-glib; \
microdnf clean all; \
useradd -m -g root geckousr; \
wget -qO- \"https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US\" | tar -jx -C /usr/local/; \
ln -s /usr/local/firefox/firefox /usr/bin/firefox; \
wget -qO- $GECKODRIVER_URL | tar xvz -C /usr/local/firefox/; \
ln -s /usr/local/firefox/geckodriver /usr/bin/geckodriver; \
firefox -headless -CreateProfile "geckousr /home/geckousr/ffprofile"; \
echo \"127.0.0.1    localhost\n0.0.0.0 localhost\" > /etc/hosts;"

buildah config --user geckousr --workingdir /home/geckousr  $ctr

buildah commit --squash $ctr $ctrimg
buildah config --author "Luke Dary" --created-by "kamiquasi" --label name="${ctrimg}" $ctr
# buildah push $ctrimg docker://quay.io/chapeaux/chromedriver-ubi:$REVISION
# buildah push $ctrimg docker://quay.io/chapeaux/chromedriver-ubi:latest
buildah unmount $ctr
buildah rm $ctr
