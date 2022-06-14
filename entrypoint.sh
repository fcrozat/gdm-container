#!/bin/bash -eu

DEBUG=${DEBUG:-"0"}
DBUS=${DBUS:-"0"}
GDM_ARGS=""

if [ "${DEBUG}" = "1" ]; then
    set -x
    GDM_ARGS="$FIREWALLD_ARGS --debug"
fi

export PATH=/usr/sbin:/sbin:${PATH}

start_dbus() {
    if [ "${DBUS}" = "1" ]; then
        mkdir -p /run/dbus
        /usr/bin/dbus-daemon --system --fork
    fi
}

#
# Main
#

# shortcut for podman runlabel calls
if [ $(basename "$1") = 'label-install' ] ||
       [ $(basename "$1") = 'label-uninstall' ]; then
    exec "$@"
fi


# If no gdm config is provided, use default one
if [ ! "$(ls -A /etc/gdm)" ]; then
    cp -av /usr/share/factory/etc/gdm/* /etc/gdm/
fi

if [ $(basename "$1") = 'gdm' ]; then
#    start_dbus
    # shellcheck disable=SC2086
    set -- "$@" $GDM_ARGS
fi

exec "$@"
