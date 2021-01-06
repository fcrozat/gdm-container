#!/bin/sh


curl https://raw.githubusercontent.com/fcrozat/gdm-container/main/gdm.service >  /etc/systemd/system/display-manager.service
systemctl daemon-reload

podman play kube gdm.yml

echo systemctl start display-manager.service
