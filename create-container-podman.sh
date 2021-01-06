#!/bin/sh

echo downloading systemd service
curl https://raw.githubusercontent.com/fcrozat/gdm-container/main/gdm.service >  /etc/systemd/system/display-manager.service
systemctl daemon-reload

echo deploying container
curl https://raw.githubusercontent.com/fcrozat/gdm-container/main/gdm.yml > gdm.yml
podman pod rm --ignore --force gdm_pod
podman play kube --start=false ./gdm.yml

echo ready, you can start gdm using
echo systemctl start display-manager.service
