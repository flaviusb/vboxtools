#!/bin/bash

sudo emerge x11-apps/xdm x11-misc/lightdm
sudo rc-update add xdm default

echo "exec startxfce4" > ~/.xinitrc

sudo sed -e 's/^DISPLAYMANAGER="xdm"$/DISPLAYMANAGER="lightdm"/' -i /etc/conf.d/xdm
