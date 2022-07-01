#!/bin/sh

echo downloading systemd service
curl https://raw.githubusercontent.com/fcrozat/gdm-container/main/container/systemd/gdm.service >  /etc/systemd/system/display-manager.service
systemctl daemon-reload

echo deploying container
# kubernetes yaml deployement doesn't work yet with our specific container
#curl https://raw.githubusercontent.com/fcrozat/gdm-container/main/gdm.yml > gdm.yml
#podman pod rm --ignore --force gdm_pod
#podman play kube --start=false ./gdm.yml

podman container create --replace --hostname gdm-container --name gdm_pod-gdm --network host --privileged \
 --security-opt label=disable --userns=keep-id --pid host --user root:root --tz=local -v /dev:/dev:rslave \
 -v /etc/passwd:/etc/passwd:ro -v /etc/group:/etc/group:ro -v /etc/shadow:/etc/shadow:ro \
 -v /home:/home -v /run:/run:rslave -v /proc:/proc -v /sys/fs/cgroup:/sys/fs/cgroup -v /var/log:/var/log \
 -v /etc/vconsole.conf:/etc/vconsole.conf:ro -v /etc/machine-id:/etc/machine-id:ro \
 -v /etc/sysconfig:/etc/sysconfig:ro -v /etc/X11/xorg.conf.d:/etc/X11/xorg.conf.d:ro -v /tmp:/tmp \
 -v /etc/locale.conf:/etc/locale.conf:ro \
 registry.opensuse.org/home/fcrozat/branches/opensuse/templates/images/tumbleweed/containers/gdm-container:latest


echo ready, you can start gdm using
echo systemctl start display-manager.service
