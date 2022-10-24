#!/bin/bash

: "${TARGET:=/var/lib/extensions/gdm}"
ORIGIN=/var/tmp/gdm-layers

if [ ${IMAGE}x != x ]; then
	SERVER=${IMAGE%%/*}
	if [ ${SERVER} = localhost -o ${SERVER} = ${IMAGE} ]; then
		CONTAINER=containers-storage:${IMAGE}
	else
		CONTAINER=docker://${IMAGE}
	fi
else
	CONTAINER=${1:-docker://registry.opensuse.org/suse/alp/workloads/tumbleweed_containerfiles/suse/alp/workloads/gdm:latest}
fi


if [ "${container:-}" = podman ]; then
	echo ""
else
	systemd-sysext unmerge
fi

if [ ! -f /usr/bin/skopeo ]; then
    echo "skopeo package must be installed on host system"
    exit 1
fi
if [ ! -f /usr/bin/patch ]; then
    echo "patch package must be installed on host system"
    exit 1
fi

echo fetching container
rm -fr $TARGET
mkdir -p $TARGET
rm -fr $ORIGIN
mkdir -p $ORIGIN
skopeo copy $CONTAINER dir:$ORIGIN

cd $TARGET
echo converting container layer to system extension
LAYERS=$(skopeo inspect dir:/$ORIGIN --format '{{ len .Layers }}')
i=1
while [ $i -ne $LAYERS ]
do
  tar xf $ORIGIN/$(skopeo inspect dir:/$ORIGIN --format "{{ index .Layers $i }}" | sed -e 's/sha256://g')
  i=$(($i+1))
done
mkdir -p $TARGET/usr/lib/extension-release.d
# ugly tricky, we mimic the host
if [ "${container:-}" = podman ]; then
	grep -E '^ID=|^VERSION_ID=' /host/etc/os-release > $TARGET/usr/lib/extension-release.d/extension-release.gdm
else
	grep -E '^ID=|^VERSION_ID=' /etc/os-release > $TARGET/usr/lib/extension-release.d/extension-release.gdm
fi
echo "SYSEXT_LEVEL=1" >> $TARGET/usr/lib/extension-release.d/extension-release.gdm
mkdir -p $TARGET/usr/etc/xdg/autostart
mv $TARGET/etc/xdg/autostart/* $TARGET/usr/etc/xdg/autostart/

ORIGIN=$TARGET INSTALL_SYSTEM_EXT=1 sh $TARGET/container/label-install

# workaround for update-alternative not being present
[ ! -d /etc/alternatives ] && mkdir -p /etc/alternatives
cp -a $TARGET/etc/alternatives/* /etc/alternatives
# move away rpmdb, it will hide HostOS one
mv $TARGET/usr/lib/sysimage/rpm $TARGET/usr/lib/sysimage/rpm.extension-gdm
#

if [ "${container:-}" = podman ]; then
	echo please run the following commands on host:
	echo systemd-sysext merge
	echo systemctl daemon-reload
	echo systemctl reload dbus
	echo systemctl start accounts-daemon
	echo systemctl start display-manager

else
	systemd-sysext merge
fi
