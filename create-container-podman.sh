#!/bin/sh


#podman build --pull -t localhost/gdm -f /root/gdm.Containerfile
podman pull registry.opensuse.org/home/fcrozat/branches/opensuse/templates/images/tumbleweed/containers/gdm-container:latest

echo podman run -ti --replace --hostname "gdm-container" --name "gdm" --network host --privileged --security-opt label=disable --userns=keep-id --user root:root --tz=local --volume /dev:/dev:rslave --volume /etc/passwd:/etc/passwd:ro --volume /etc/group:/etc/group:ro --volume /etc/shadow:/etc/shadow:ro --volume /home:/home --volume /run/udev/data:/run/udev/data registry.opensuse.org/home/fcrozat/branches/opensuse/templates/images/tumbleweed/containers/gdm-container:latest
#localhost/gdm

# podman run  -ti  --network host --replace --name gdm --privileged --device /dev/tty0 --device /dev/tty1  --device /dev/tty2 --device '/dev/dri':'/dev/dri':rw --device '/dev/vga_arbiter':'/dev/vga_arbiter':rw --volume /run/udev/data --device /dev/shm --device /dev/console  localhost/gdm

#podman run  -ti  --replace --name gdm --privileged --network host --volume /dev:/dev:rslave --volume /etc:/etc:ro --volume /home --volume /run/udev/data localhost/gdm
#podman run  -ti  --replace --name gdm --privileged --network host --volume /dev:/dev:rslave --volume /etc/passwd:/etc/passwd:ro -v /etc/group:/etc/group:ro -v /etc/shadow:/etc/shadow:ro --volume /home --volume /run/udev/data localhost/gdm
