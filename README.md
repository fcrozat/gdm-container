# GDM Container #

The purpose of this container is to deploy and start GDM in a container, independant of the root file system
(this might be useful when using a read-only root installation, like openSUSE MicroOS).

## To deploy the container
* on host, install the following packages: podman, accountsservice, nss-systemd, systemd-experimental
* ensure SELinux is configured in Permissive mode
* run as root: podman container runlabel install registry.opensuse.org/home/fcrozat/branches/opensuse/templates/images/tumbleweed/containers/gdm-container
* systemctl daemon-reload
* systemctl reload dbus
* systemctl restart accounts-daemon (ensure it uses nss-systemd)


This will download gdm container from Open Build Service registry (it is a openSUSE Tumbleweed container with bare minimum to start GNOME), recreate a container locally and deploy a systemd service which is replacing display-manager.service systemd service (used on openSUSE / SLE).

## To run gdm
* as standalone process in container
** beware there is still some dbus activation issue after login in gdm
** either use: podman container runlabel run registry.opensuse.org/home/fcrozat/branches/opensuse/templates/images/tumbleweed/containers/gdm-container
** or systemctl start gdm
* with systemd running in container
** podman container runlabel run-systemd registry.opensuse.org/home/fcrozat/branches/opensuse/templates/images/tumbleweed/containers/gdm-container
** or systemctl start gdm-systemd (still a bit buggy)


## To uninstall the deployed files:
* run as root: podman container runlabel uninstall registry.opensuse.org/home/fcrozat/branches/opensuse/templates/images/tumbleweed/containers/gdm-container

## Security notice
This container is NOT SECURED at all: it is running privileged and can access host system. The purpose of this container is to have another way to deploy gdm, not to try to secure it at all.

