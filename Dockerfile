# SPDX-License-Identifier: MIT
# Defines the tag for OBS and build script builds:
#!BuildTag: suse/alp/workloads/gdm-container:0.1
#!BuildTag: suse/alp/workloads/gdm-container:0.1-%RELEASE%
#!BuildTag: suse/alp/workloads/gdm-container:latest

FROM opensuse/tumbleweed

LABEL maintainer="Frederic Crozat <fcrozat@suse.com>"
ARG GDM_IMAGE_URL="registry.opensuse.org/suse/alp/workloads/tumbleweed_containerfiles/suse/alp/workloads/gdm-container:latest"

# Define labels according to https://en.opensuse.org/Building_derived_containers
# labelprefix=com.suse.alp.workloads.gdm
LABEL org.opencontainers.image.title="GDM Desktop Container Image"
LABEL org.opencontainers.image.description="GDM container based on Tumbleweed"
LABEL org.opencontainers.image.version="0.1"
LABEL org.opencontainers.image.url="https://github.com/fcrozat/gdm-container/"
LABEL org.opencontainers.image.created="%BUILDTIME%"
LABEL org.opensuse.reference="registry.opensuse.org/suse/alp/workloads/tumbleweed_containerfiles/suse/alp/workloads/gdm-container:0.1-%RELEASE%"
LABEL org.openbuildservice.disturl="%DISTURL%"
LABEL com.suse.supportlevel="techpreview"
LABEL com.suse.eula="beta"
LABEL com.suse.image-type="application"
LABEL com.suse.release-stage="alpha"
# endlabelprefix

RUN zypper -n in patterns-base-basesystem openSUSE-release-appliance-docker systemd patterns-gnome-gnome_basic gtk3-branding-openSUSE  adwaita-icon-theme  desktop-data-openSUSE  gnome-session-wayland vim-small less flatpak gnome-terminal gvfs-backends noto-sans-fonts noto-coloremoji-fonts google-roboto-fonts adobe-sourcecodepro-fonts fuse nss-systemd patch

COPY container /container
COPY entrypoint.sh /entrypoint.sh
# embed PODMAN_RUN_GDM_*_OPTIONS into label-install
ARG PODMAN_RUN_GDM_COMMON_OPTIONS="--rm -d -v /dev:/dev:rslave -v /etc/passwd:/etc/passwd:ro -v /etc/group:/etc/group:ro -v /etc/shadow:/etc/shadow:ro  -v /home:/home -v /etc/vconsole.conf:/etc/vconsole.conf:ro -v /etc/sysconfig:/etc/sysconfig:ro -v /etc/X11/xorg.conf.d:/etc/X11/xorg.conf.d:ro -v /etc/locale.conf:/etc/locale.conf:ro -v /etc/gdm:/etc/gdm:ro -v /var/cache:/var/cache -v /var/lib:/var/lib -v /:/run/host:rslave --network host --privileged --security-opt label=disable --tz=local"
ARG PODMAN_RUN_GDM_STANDALONE_OPTIONS="$PODMAN_RUN_GDM_COMMON_OPTIONS -v /run:/run:rslave -v /proc:/proc -v /sys/fs/cgroup:/sys/fs/cgroup -v /var/log:/var/log -v /etc/machine-id:/etc/machine-id:ro -v /tmp:/tmp --pid host"
ARG PODMAN_RUN_GDM_SYSTEMD_OPTIONS="$PODMAN_RUN_GDM_COMMON_OPTIONS --systemd=always --entrypoint /usr/lib/systemd/systemd"
RUN chmod 755 /entrypoint.sh &&  sed -i -e "s@_PODMAN_RUN_GDM_STANDALONE_OPTIONS_@${PODMAN_RUN_GDM_STANDALONE_OPTIONS}@g;s@_PODMAN_RUN_GDM_SYSTEMD_OPTIONS_@${PODMAN_RUN_GDM_SYSTEMD_OPTIONS}@g"   /container/label-install

RUN mkdir -p /etc/userdb && cp -avr /container/userdb/* /etc/userdb && cp /usr/etc/nsswitch.conf /etc/nsswitch.conf && cd /etc && patch -p0 -i /container/nsswitch.conf.patch


# setup the system
RUN systemd-sysusers && systemd-tmpfiles --create

# cleanup systemd setup
RUN rm -f /etc/systemd/system/getty.target.wants/getty@tty1.service
# gnome-menus-branding-openSUSE
#RUN flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
#RUN flatpak install --noninteractive org.gnome.Nautilus
# avoid this script, best to run gdm directly
#ENTRYPOINT [ "/usr/lib/X11/display-manager", "start" ]

ENV SYSTEMD_IGNORE_CHROOT=1
#ENTRYPOINT ["/usr/bin/gdm"]
ENTRYPOINT ["/entrypoint.sh"]
CMD ["gdm"]

ENV IMAGE=$GDM_IMAGE_URL
ENV NAME="gdm"

LABEL INSTALL="/usr/bin/docker run --env IMAGE=${IMAGE} --rm --privileged -v /:/host \${IMAGE} /bin/bash /container/label-install"
LABEL UNINSTALL="/usr/bin/docker run --rm --privileged -v /:/host ${IMAGE} /bin/bash /container/label-uninstall"
LABEL RUN="/usr/bin/docker run --replace --name ${NAME} ${PODMAN_RUN_GDM_STANDALONE_OPTIONS} ${IMAGE} /usr/bin/gdm"
LABEL RUN_SYSTEMD="/usr/bin/docker run --replace --name ${NAME} ${PODMAN_RUN_GDM_SYSTEMD_OPTIONS} ${IMAGE} /usr/lib/systemd/systemd"
