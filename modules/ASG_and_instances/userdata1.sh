#!/bin/bash

# Clean and update
rm -rf /var/lib/apt/lists/*
apt-get update --allow-releaseinfo-change -y

mkfs -t ext4 /dev/xvdh
mkdir /data
mount /dev/xvdh /data
echo "/dev/xvdh /data ext4 defaults,nofail 0 2" >> /etc/fstab



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
  "metrics": {
    "append_dimensions": {
      "InstanceId": "\${aws:InstanceId}"
    },
    "metrics_collected": {
      "mem": {
        "measurement": [
          "mem_used_percent"
        ],
        "metrics_collection_interval": 60
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