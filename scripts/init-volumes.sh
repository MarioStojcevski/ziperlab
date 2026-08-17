#!/usr/bin/env bash
set -e
sudo mkdir -p /srv/ziperlab/immich/library
sudo mkdir -p /srv/ziperlab/immich/postgres
sudo mkdir -p /srv/ziperlab/navidrome/data
sudo mkdir -p /srv/ziperlab/navidrome/music
sudo chown -R $USER:$USER /srv/ziperlab
echo "Volumes ready under /srv/ziperlab"
