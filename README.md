# GDM Container #

The purpose of this container is to deploy and start GDM in a container, independant of the root file system
(this might be useful when using a read-only root installation, like openSUSE MicroOS).

## To deploy the container
* on host, install the following packages: `podman accountsservice systemd-experimental`
* ensure SELinux is configured in Permissive mode:
    * Edit `/etc/selinux/config`
    * Make sure there is a line with `SELINUX=permissive` in it
    * reboot
* AppArmor should be disabled (due to https://bugzilla.opensuse.org/show_bug.cgi?id=1207698 )
* run as root: 
    * `podman container runlabel install registry.opensuse.org/suse/alp/workloads/tumbleweed_containerfiles/suse/alp/workloads/gdm:latest`
    * `systemctl daemon-reload`
    * `systemctl reload dbus`
    * `systemctl restart accounts-daemon` (ensure it uses nss-systemd)


This will download gdm container from Open Build Service registry (it is a openSUSE Tumbleweed container with bare minimum to start GNOME), recreate a container locally and deploy a systemd service which is replacing display-manager.service systemd service (used on openSUSE / SLE).

## To run gdm
as standalone process in container

beware there is still some dbus activation issues after login in gdm
* either use: `podman container runlabel --name gdm run registry.opensuse.org/suse/alp/workloads/tumbleweed_containerfiles/suse/alp/workloads/gdm:latest`
* or `systemctl start gdm`

Other option: with systemd running in container
* `podman container runlabel run-systemd --name gdm registry.opensuse.org/suse/alp/workloads/tumbleweed_containerfiles/suse/alp/workloads/gdm:latest`
* or `systemctl start gdm-systemd` (still a bit buggy)


## To uninstall the deployed files:
* run as root: `podman container runlabel uninstall registry.opensuse.org/suse/alp/workloads/tumbleweed_containerfiles/suse/alp/workloads/gdm:latest`

## Security notice
This container is NOT SECURED at all: it is running privileged and can access host system. The purpose of this container is to have another way to deploy gdm, not to try to secure it at all.


## Experiment: systemd system extension

A systemd system extension can be created on hostOS, by unpacking OCI container and some adaptation.

* Pro of system extension:
    * system acts as if everything was part of hostOS
    * no issue with dbus
    * no change to hostOS, except a few config files in /etc to install

* Con of system extension:
    * system extension is tied to hostOS
    * everything in system extension /usr will overlay the same files from hostOS in /usr, for all applications
    * no sandboxing


* On host, install the following packages: `podman systemd-experimental`
* ensure SELinux is configured in Permissive mode:
    * Edit `/etc/selinux/config`
    * Make sure there is a line with `SELINUX=permissive` in it
    * reboot
* run as root: 
    * `podman container runlabel install-sysext registry.opensuse.org/suse/alp/workloads/tumbleweed_containerfiles/suse/alp/workloads/gdm:latest` (this will fetch OCI container and convert it to a local systemd system extension)
    * `systemd-sysext merge`
    * `systemctl daemon-reload`
    * `systemctl reload dbus`
    * `systemctl start accounts-daemon`
    * `systemctl start display-manager`

The system will act as if gdm and its dependencies were installed on the hostOS.
Beware, those addons are not visible in hostOS rpmdb, you need to use `rpm --dbpath /usr/lib/sysimage/rpm.extension-gdm/` to check the alternative rpmdb.

## Experiment: systemd portable service

A systemd portable extension can be created on hostOS, by unpacking OCI container and some adaptation.

* Pro of portable service:
    * system acts as if everything was part of hostOS
    * no issue with dbus
    * no change to hostOS, except a few config files in /etc to install
    * portable extension is independant of the hostOS
    * only service exported by portable service is visible on hostOS, nothing else

Con of portable service:
    * very light sandboxing, need to punch holes to get access to files



* On host, install the following packages: `podman systemd-experimental systemd-portable`
* ensure SELinux is configured in Permissive mode:
    * Edit `/etc/selinux/config`
    * Make sure there is a line with `SELINUX=permissive` in it
    * reboot
* run as root: 
    * `podman container runlabel install-portable registry.opensuse.org/suse/alp/workloads/tumbleweed_containerfiles/suse/alp/workloads/gdm:latest` (this will fetch OCI container and convert it to a local systemd portable service
    * `portablectl attach --profile gdm gdm`
    * `systemctl reload dbus`
    * `systemctl start gdm-accounts-daemon`
    * `systemctl start gdm-display-manager`
