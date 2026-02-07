#!/bin/bash
# User Data Script for EC2 Instance
# This script runs on first boot to set up the environment

set -e

# Update system
echo "Updating system packages..."
yum update -y

# Install Docker
echo "Installing Docker..."
yum install -y docker
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group
usermod -a -G docker ec2-user

# Install Docker Compose
echo "Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install Git
echo "Installing Git..."
yum install -y git

# Create application directory
mkdir -p /home/ec2-user/app
chown ec2-user:ec2-user /home/ec2-user/app

# Environment variables
echo "Setting up environment..."
cat > /home/ec2-user/.env << EOF
ENVIRONMENT=${environment}
APP_VERSION=${app_version}
PORT=5000
EOF

chown ec2-user:ec2-user /home/ec2-user/.env

# Create systemd service for Docker container
cat > /etc/systemd/system/webapp.service << 'EOF'
[Unit]
Description=Secure Web Application
After=docker.service
Requires=docker.service

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user/app
ExecStartPre=/usr/bin/docker pull YOUR_DOCKERHUB_USERNAME/secure-webapp:latest
ExecStart=/usr/bin/docker run --rm --name webapp -p 5000:5000 --env-file /home/ec2-user/.env YOUR_DOCKERHUB_USERNAME/secure-webapp:latest
ExecStop=/usr/bin/docker stop webapp
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable but don't start the service (will be started after first deployment)
systemctl daemon-reload
systemctl enable webapp.service

# Install CloudWatch agent (optional)
echo "Installing CloudWatch agent..."
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm
rm -f ./amazon-cloudwatch-agent.rpm

# Setup complete
echo "Setup complete! Instance is ready."
echo "Environment: ${environment}"
echo "App Version: ${app_version}"
