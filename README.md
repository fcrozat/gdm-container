GDM Container

The purpose of this container is to deploy and start GDM in a container, independant of the root file system
(this might be useful when using a read-only root installation, like openSUSE MicroOS).

To deploy the container, 
* install podman
* run create-container-podman.sh locally as root.

This will download gdm container from Open Build Service registry (it is a openSUSE Tumbleweed container with bare minimum to start GNOME), 
recreate a container locally and deploy a systemd service which is replacing display-manager.service systemd service (used on openSUSE / SLE).

Security notice:
this container is NOT SECURED at all: it is running privileged and can access host system. The purpose of this container is to have
another way to deploy gdm, not to try to secure it at all.

Work in progress:
move the container creation / setup from a manual podman command to a Kubernetes YAML file
