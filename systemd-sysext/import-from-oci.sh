#!/bin/sh

TARGET=/var/lib/extensions/gdm
ORIGIN=/var/tmp/gdm-layers

systemd-sysext unmerge

if [ ! -f /usr/bin/skopeo ]; then
    echo "skopeo package must be installed on host system"
    exit 1
fi
if [ ! -f /usr/bin/patch ]; then
    echo "patch package must be installed on host system"
    exit 1
fi

echo fetching container from registry
rm -fr $TARGET
mkdir -p $TARGET
rm -fr $ORIGIN
mkdir -p $ORIGIN
skopeo copy docker://registry.opensuse.org/suse/alp/workloads/tumbleweed_containerfiles/suse/alp/workloads/gdm:latest dir:$ORIGIN

cd $TARGET
echo converting container layer to system extension
tar xf $ORIGIN/$(skopeo inspect dir:/$ORIGIN --format '{{ index .Layers 1 }}' | sed -e 's/sha256://g')
mkdir -p $TARGET/usr/lib/extension-release.d
grep -E '^ID=|^VERSION_ID=' /etc/os-release > $TARGET/usr/lib/extension-release.d/extension-release.gdm
echo "SYSEXT_LEVEL=1" >> $TARGET/usr/lib/extension-release.d/extension-release.gdm
mkdir -p $TARGET/usr/etc/xdg/autostart
mv $TARGET/etc/xdg/autostart/* $TARGET/usr/etc/xdg/autostart/
HOST=/ ORIGIN=$TARGET sh -x /root/label-install 

# workaround for update-alternative not being present
mkdir -p /etc/alternatives
cp -a $TARGET/etc/alternatives/* /etc/alternatives
# workaround until xdm is fixed in Factory
mkdir -p /etc/X11/xinit
# move away rpmdb, it will hide HostOS one
mv $TARGET/usr/lib/sysimage/rpm $TARGET/usr/liv/sysimage/rpm.extension-gdm
# move dbus files to usr 
mv $TARGET/etc/dbus-1/systemd.d/* $TARGET/usr/share/dbus-1/system.d/

systemd-sysext merge
