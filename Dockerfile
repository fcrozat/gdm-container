# Defines the tag for OBS and build script builds:
#!BuildTag: gdm-container:latest

FROM opensuse/tumbleweed
ENV IMAGE="registry.opensuse.org/home/fcrozat/branches/opensuse/templates/images/tumbleweed/containers/gdm-container:latest"
ENV NAME="gdm"

LABEL maintainer="Frederic Crozat <fcrozat@suse.com>"
COPY entrypoint.sh /entrypoint.sh
COPY container /container
RUN chmod 755 /entrypoint.sh && zypper -n in patterns-base-basesystem openSUSE-release-appliance-docker systemd patterns-gnome-gnome_basic gtk3-branding-openSUSE  adwaita-icon-theme  desktop-data-openSUSE  gnome-session-wayland vim-small less flatpak gnome-terminal gvfs-backends noto-sans-fonts noto-coloremoji-fonts google-roboto-fonts adobe-sourcecodepro-fonts fuse nss-systemd patch

RUN mkdir -p /etc/userdb && cp -avr /container/userdb/* /etc/userdb && cp /usr/etc/nsswitch.conf /etc/nsswitch.conf && cd /etc && patch -p0 -i /container/nsswitch.conf.patch


# setup the system
RUN systemd-sysusers && systemd-tmpfiles --create
# util-linux 
#&& zypper -n in aaa_base bash filesystem openSUSE-release-ftp systemd glibc-locale gdm zypper ca-certificates ca-certificates-mozilla patterns-gnome-gnome_basic less util-linux vim gnome-session-wayland gtk3-branding-openSUSE adwaita-icon-theme 
# gnome-menus-branding-openSUSE
#RUN flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
#RUN flatpak install --noninteractive org.gnome.Nautilus
#no need to run systemd
#ENTRYPOINT [ "/usr/lib/systemd/systemd" ]
# avoid this script, best to run gdm directly
#ENTRYPOINT [ "/usr/lib/X11/display-manager", "start" ]

ENV SYSTEMD_IGNORE_CHROOT=1
#ENTRYPOINT ["/usr/bin/gdm"]
ENTRYPOINT ["/entrypoint.sh"]
CMD ["gdm"]

LABEL INSTALL="/usr/bin/docker run --env IMAGE=${IMAGE} --rm --privileged -v /:/host \${IMAGE} /container/label-install"
LABEL UNINSTALL="/usr/bin/docker run --rm --privileged -v /:/host ${IMAGE} /container/label-uninstall"
LABEL RUN="/usr/bin/docker run -d --name ${NAME} --privileged --net=host -v /dev:/dev:rslave -v /etc/passwd:/etc/passwd:ro -v /etc/group:/etc/group:ro -v /etc/shadow:/etc/shadow:ro  -v /home:/home -v /run:/run:rslave -v /proc:/proc -v /sys/fs/cgroup:/sys/fs/cgroup -v /var/log:/var/log  -v /etc/vconsole.conf:/etc/vconsole.conf:ro -v /etc/machine-id:/etc/machine-id:ro  -v /etc/sysconfig:/etc/sysconfig:ro -v /etc/X11/xorg.conf.d:/etc/X11/xorg.conf.d:ro -v /tmp:/tmp  -v /etc/locale.conf:/etc/locale.conf:ro  ${IMAGE} /usr/bin/gdm"
