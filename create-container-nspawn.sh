#!/bin/sh

#rm -rf /var/lib/machines/tumbleweed
#mkdir -p /var/lib/machines/tumbleweed 
#zypper --root=/var/lib/machines/tumbleweed ar https://download.opensuse.org/tumbleweed/repo/oss tumbleweed
zypper --root=/var/lib/machines/tumbleweed --non-interactive --gpg-auto-import-keys in --no-recommends aaa_base bash filesystem openSUSE-release-ftp systemd glibc-locale gdm zypper ca-certificates ca-certificates-mozilla patterns-gnome-gnome_basic less util-linux vim gnome-session-wayland gtk3-branding-openSUSE adwaita-icon-theme desktop-data-openSUSE

#cd /var/lib/machines/tumbleweed/etc/sysconfig/
#
#vi displaymanager
#1607449068
#systemd-nspawn -M tumbleweed
#1607499721
#systemd-nspawn -M tumbleweed passwd root

mkdir -p /etc/systemd/nspawn
cat << EOF > /etc/systemd/nspawn/tumbleweed.nspawn
[Exec]
Boot=1
Capability=all
PrivateUsers=off

[Files]
Bind=/dev/dri
Bind=/dev/vga_arbiter
Bind=/dev/shm
Bind=/dev/input
Bind=/dev/snd
Bind=/dev/tty7
Bind=/dev/tty0
Bind=/dev/tty1
Bind=/dev/tty2
Bind=/dev/tty3
Bind=/run/udev/data
#Bind=/run/dbus/system_bus_socket
Bind-ro=/etc/vconsole.conf
EOF

mkdir -p /etc/systemd/systemd-nspawn@tumbleweed.service.d/
cat << EOF >  /etc/systemd/systemd-nspawn@tumbleweed.service.d/override.conf
[Service]
DeviceAllow=/dev/shm rw
DeviceAllow=/dev/dri rwmx
DeviceAllow=/dev/dri/card0 rwmx
DeviceAllow=/dev/dri/renderD128 rwmx
DeviceAllow=char-usb_device rwm
DeviceAllow=char-input rwm
DeviceAllow=char-alsa rwm
DeviceAllow=char-drm rwmx
DeviceAllow=/dev/tty7 rwm
DeviceAllow=/dev/tty0 rwm
DeviceAllow=/dev/tty1 rwm
DeviceAllow=/dev/tty2 rwm
DeviceAllow=/dev/tty3 rwm
ExecStartPost=/bin/sh -c 'echo a > /sys/fs/cgroup/devices/machine.slice/machine-tumbleweed.scope/devices.allow'
EOF

systemctl daemon-reload
