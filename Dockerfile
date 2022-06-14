# Defines the tag for OBS and build script builds:
#!BuildTag: gdm-container

FROM opensuse/tumbleweed
RUN zypper -n in patterns-base-basesystem openSUSE-release-appliance-docker systemd patterns-gnome-gnome_basic gtk3-branding-openSUSE  adwaita-icon-theme  desktop-data-openSUSE  gnome-session-wayland vim-small less flatpak gnome-terminal gvfs-backends noto-sans-fonts noto-coloremoji-fonts google-roboto-fonts adobe-sourcecodepro-fonts fuse

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

COPY entrypoint.sh /entrypoint.sh
COPY container /container
ENV SYSTEMD_IGNORE_CHROOT=1
#ENTRYPOINT ["/usr/bin/gdm"]
ENTRYPOINT ["sh" ,"/entrypoint.sh"]

LABEL INSTALL="/usr/bin/docker run --rm --privileged -v /:/host ${IMAGE} /container/label-install"
LABEL UNINSTALL="/usr/bin/docker run --rm --privileged -v /:/host ${IMAGE} /container/label-uninstall"
