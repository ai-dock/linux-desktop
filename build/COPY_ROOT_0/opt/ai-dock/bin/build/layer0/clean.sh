#!/bin/false

# Tidy up and keep image small
apt-get clean -y

fix-permissions.sh -o container

rm -rf /tmp/*

rm /etc/ld.so.cache
ldconfig
