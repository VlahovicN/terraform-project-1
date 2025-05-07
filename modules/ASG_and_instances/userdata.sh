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


# Install curl
apt-get install -y curl


# Cloudwatch installation

curl -O https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i amazon-cloudwatch-agent.deb
apt-get install -f -y
mkdir -p /opt/aws/amazon-cloudwatch-agent/bin



# Take the instance_id
instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# CloudWatch config
cat > /opt/aws/amazon-cloudwatch-agent/bin/config.json <<EOF
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/syslog",
            "log_group_name": "/terraform/nginx-efs",
            "log_stream_name": "\$${instance_id}",
            "timestamp_format": "%Y-%m-%d %H:%M:%S"
          }
        ]
      }
    }
  }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json \
  -s