#!/bin/sh

echo downloading systemd service
curl https://raw.githubusercontent.com/fcrozat/gdm-container/main/gdm.service >  /etc/systemd/system/display-manager.service
systemctl daemon-reload

echo deploying container
podman play kube --start=false https://raw.githubusercontent.com/fcrozat/gdm-container/main/gdm.yml

echo ready, you can start gdm using
echo systemctl start display-manager.service
