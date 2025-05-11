#!/bin/bash

# Clean and update
rm -rf /var/lib/apt/lists/*
apt-get update --allow-releaseinfo-change -y

mkfs -t ext4 /dev/xvdh
mkdir -p /data
mount /dev/xvdh /data
echo "/dev/xvdh /data ext4 defaults,nofail 0 2" >> /etc/fstab