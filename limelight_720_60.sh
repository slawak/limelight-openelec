#!/bin/bash

#systemctl disable kodi.service
systemctl stop kodi.service &

sleep 3

/storage/downloads/limelight/limelight.sh -720 &> /storage/downloads/limelight/limelight.log

sleep 2

systemctl start kodi.service
#systemctl enable kodi.service

