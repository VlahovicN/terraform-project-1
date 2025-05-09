#!/bin/bash

# Clean and update
rm -rf /var/lib/apt/lists/*
apt-get update --allow-releaseinfo-change -y

# Install nginx
apt-get install -y nginx

# Setup nginx page
echo "Hello from Nikola's Terraform Server 🚀 with EFS" > /var/www/html/index.html

# Enable nginx
systemctl start nginx
systemctl enable nginx

# Install NFS utils
apt-get install -y nfs-common

# Create mount point
mkdir -p /mnt/efs

# Mount EFS
mount -t nfs4 -o nfsvers=4.1 ${efs_id}.efs.${region}.amazonaws.com:/ /mnt/efs

# Make mount persistent
echo "${efs_id}.efs.${region}.amazonaws.com:/ /mnt/efs nfs4 defaults,_netdev 0 0" >> /etc/fstab
