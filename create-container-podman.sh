#!/bin/sh

cat  << EOF > /root/gdm.Containerfile
FROM registry.opensuse.org/opensuse/tumbleweed:latest
RUN zypper refresh \
&& zypper -n in openSUSE-release-appliance-docker systemd patterns-gnome-gnome_basic gtk3-branding-openSUSE  adwaita-icon-theme  desktop-data-openSUSE  gnome-session-wayland vim less flatpak gnome-terminal gvfs-backends noto-sans-fonts noto-coloremoji-fonts google-roboto-fonts adobe-sourcecodepro-fonts fuse
# gdm ca-certificates-mozilla util-linux gnome-session-wayland 
#&& zypper -n in aaa_base bash filesystem openSUSE-release-ftp systemd glibc-locale gdm zypper ca-certificates ca-certificates-mozilla patterns-gnome-gnome_basic less util-linux vim gnome-session-wayland gtk3-branding-openSUSE adwaita-icon-theme desktop-data-openSUSE
# gnome-menus-branding-openSUSE
RUN flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
RUN flatpak install --noninteractive org.gnome.Nautilus
ENTRYPOINT [ "/usr/lib/systemd/systemd" ]
EOF

#podman build --pull -t localhost/gdm -f /root/gdm.Containerfile
podman pull registry.opensuse.org/home/fcrozat/branches/opensuse/templates/images/tumbleweed/containers/my_container:latest

echo podman run -ti --replace --hostname "gdm-container" --name "gdm" --network host --privileged --security-opt label=disable --userns=keep-id --user root:root --tz=local --volume /dev:/dev:rslave --volume /etc/passwd:/etc/passwd:ro --volume /etc/group:/etc/group:ro --volume /etc/shadow:/etc/shadow:ro --volume /home:/home --volume /run/udev/data:/run/udev/data registry.opensuse.org/home/fcrozat/branches/opensuse/templates/images/tumbleweed/containers/my_container:latest
#localhost/gdm

# podman run  -ti  --network host --replace --name gdm --privileged --device /dev/tty0 --device /dev/tty1  --device /dev/tty2 --device '/dev/dri':'/dev/dri':rw --device '/dev/vga_arbiter':'/dev/vga_arbiter':rw --volume /run/udev/data --device /dev/shm --device /dev/console  localhost/gdm

#podman run  -ti  --replace --name gdm --privileged --network host --volume /dev:/dev:rslave --volume /etc:/etc:ro --volume /home --volume /run/udev/data localhost/gdm
#podman run  -ti  --replace --name gdm --privileged --network host --volume /dev:/dev:rslave --volume /etc/passwd:/etc/passwd:ro -v /etc/group:/etc/group:ro -v /etc/shadow:/etc/shadow:ro --volume /home --volume /run/udev/data localhost/gdm
