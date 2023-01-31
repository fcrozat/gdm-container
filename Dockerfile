# SPDX-License-Identifier: MIT
# Defines the tag for OBS and build script builds:
#!BuildTag: suse/alp/workloads/gdm:0.2
#!BuildTag: suse/alp/workloads/gdm:0.2-%RELEASE%
#!BuildTag: suse/alp/workloads/gdm:latest

FROM opensuse/tumbleweed

LABEL maintainer="Frederic Crozat <fcrozat@suse.com>"

# Define labels according to https://en.opensuse.org/Building_derived_containers
# labelprefix=com.suse.alp.workloads.gdm
LABEL org.opencontainers.image.title="GDM Desktop Container Image"
LABEL org.opencontainers.image.description="GDM container based on Tumbleweed"
LABEL org.opencontainers.image.version="0.2"
LABEL org.opencontainers.image.url="https://github.com/fcrozat/gdm-container/"
LABEL org.opencontainers.image.created="%BUILDTIME%"
LABEL org.opensuse.reference="registry.opensuse.org/suse/alp/workloads/tumbleweed_containerfiles/suse/alp/workloads/gdm:0.2-%RELEASE%"
LABEL org.openbuildservice.disturl="%DISTURL%"
LABEL com.suse.eula="beta"
LABEL com.suse.image-type="application"
LABEL com.suse.release-stage="prototype"
# endlabelprefix

RUN zypper -n in patterns-base-basesystem openSUSE-release-appliance-docker systemd patterns-gnome-gnome_basic gtk3-branding-openSUSE  adwaita-icon-theme  desktop-data-openSUSE  gnome-session-wayland vim-small less flatpak gnome-terminal gvfs-backends noto-sans-fonts noto-coloremoji-fonts google-roboto-fonts adobe-sourcecodepro-fonts fuse nss-systemd patch xterm systemd-icon-branding skopeo tar gjs glibc-locale systemd-portable

COPY container /container
COPY systemd-sysext /systemd-sysext
COPY entrypoint.sh /entrypoint.sh
# embed PODMAN_RUN_GDM_*_OPTIONS into label-install
ARG PODMAN_RUN_GDM_COMMON_OPTIONS="--rm -d -v /dev:/dev:rslave -v /etc/passwd:/etc/passwd:ro -v /etc/group:/etc/group:ro -v /etc/shadow:/etc/shadow:ro -v /etc/userdb:/etc/userdb:ro -v /home:/home -v /etc/vconsole.conf:/etc/vconsole.conf:ro -v /etc/sysconfig:/etc/sysconfig:ro -v /etc/X11/xorg.conf.d:/etc/X11/xorg.conf.d:ro -v /etc/locale.conf:/etc/locale.conf:ro -v /etc/gdm:/etc/gdm:ro -v /var/cache:/var/cache -v /var/lib:/var/lib -v /:/run/host:rslave --network host --privileged --security-opt label=disable --tz=local"
ARG PODMAN_RUN_GDM_STANDALONE_OPTIONS="$PODMAN_RUN_GDM_COMMON_OPTIONS -v /run:/run:rslave -v /proc:/proc -v /sys/fs/cgroup:/sys/fs/cgroup -v /var/log:/var/log -v /etc/machine-id:/etc/machine-id:ro -v /tmp:/tmp --pid host"
ARG PODMAN_RUN_GDM_SYSTEMD_OPTIONS="$PODMAN_RUN_GDM_COMMON_OPTIONS --systemd=always --entrypoint /usr/lib/systemd/systemd"
RUN chmod 755 /entrypoint.sh &&  sed -i -e "s@_PODMAN_RUN_GDM_STANDALONE_OPTIONS_@${PODMAN_RUN_GDM_STANDALONE_OPTIONS}@g;s@_PODMAN_RUN_GDM_SYSTEMD_OPTIONS_@${PODMAN_RUN_GDM_SYSTEMD_OPTIONS}@g"   /container/label-install

RUN mkdir -p /etc/userdb && cp -avr /container/userdb/* /etc/userdb && cp /usr/etc/nsswitch.conf /etc/nsswitch.conf && cd /etc && patch -p0 -i /container/nsswitch-systemd-first.conf.patch



# setup the system
RUN systemd-sysusers && systemd-tmpfiles --create

RUN container/passwd-to-userdb && rm /etc/passwd

# cleanup systemd setup
RUN ln -f -s /dev/null /etc/systemd/system/getty@tty1.service

#RUN flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
#RUN flatpak install --noninteractive org.gnome.Nautilus
# avoid this script, best to run gdm directly
#ENTRYPOINT [ "/usr/lib/X11/display-manager", "start" ]

ENV SYSTEMD_IGNORE_CHROOT=1
#ENTRYPOINT ["/usr/bin/gdm"]
ENTRYPOINT ["/entrypoint.sh"]
CMD ["gdm"]

LABEL INSTALL="/usr/bin/docker run --env IMAGE=IMAGE --rm --privileged --pid host -v /:/host -v /run:/run:rslave IMAGE /bin/bash /container/label-install"
LABEL UNINSTALL="/usr/bin/docker run --rm --privileged --pid host -v /run:/run:rslave -v /:/host -v /va/lib/portables:/var/lib/portables -v /var/lib/extensions:/var/lib/extensions IMAGE /bin/bash /container/label-uninstall"
LABEL RUN="/usr/bin/docker run --replace --name NAME ${PODMAN_RUN_GDM_STANDALONE_OPTIONS} IMAGE /usr/bin/gdm"
LABEL RUN-SYSTEMD="/usr/bin/docker run --replace --name NAME ${PODMAN_RUN_GDM_SYSTEMD_OPTIONS} IMAGE"
LABEL INSTALL-SYSEXT="/usr/bin/docker run --env IMAGE=IMAGE --env TARGET=/var/lib/extensions/gdm --rm --privileged --pid host -v /run:/run:rslave -v /etc/os-release:/etc/os-release:ro -v /:/host -v /var/lib/extensions:/var/lib/extensions -v /var/lib/containers:/var/lib/containers IMAGE  /bin/bash /systemd-sysext/import-from-oci.sh"
LABEL INSTALL-PORTABLE="/usr/bin/docker run --env IMAGE=IMAGE --env TARGET=/var/lib/portables/gdm --env PORTABLE=1 --rm --privileged --pid host -v /var/lib/portables:/var/lib/portables -v /run:/run:rslave -v /:/host -v /var/lib/containers:/var/lib/containers IMAGE  /bin/bash /systemd-sysext/import-from-oci.sh"
