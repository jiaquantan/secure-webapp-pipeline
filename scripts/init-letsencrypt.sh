#!/bin/bash

###############################################################################
# Let's Encrypt SSL Certificate Initialization Script
# This script sets up SSL certificates for the first time
###############################################################################

set -e

# Check if domain name is provided
if [ -z "$1" ]; then
    echo "Error: Domain name is required"
    echo "Usage: $0 <domain-name> <email>"
    echo "Example: $0 example.com admin@example.com"
    exit 1
fi

if [ -z "$2" ]; then
    echo "Error: Email is required"
    echo "Usage: $0 <domain-name> <email>"
    echo "Example: $0 example.com admin@example.com"
    exit 1
fi

DOMAIN=$1
EMAIL=$2
STAGING=${3:-0} # Set to 1 for staging, 0 for production

echo "==================================="
echo "Let's Encrypt SSL Setup"
echo "==================================="
echo "Domain: $DOMAIN"
echo "Email: $EMAIL"
echo "Mode: $([ $STAGING -eq 1 ] && echo 'STAGING' || echo 'PRODUCTION')"
echo "==================================="
echo ""

# Create required directories
echo "Creating required directories..."
mkdir -p ./certbot/conf
mkdir -p ./certbot/www
mkdir -p ./certbot/logs
mkdir -p ./certbot/dhparam

# Download recommended TLS parameters
echo "Downloading recommended TLS parameters..."
if [ ! -f "./certbot/dhparam/ssl-dhparams.pem" ]; then
    curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "./certbot/conf/options-ssl-nginx.conf"
    curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "./certbot/dhparam/ssl-dhparams.pem"
fi

# Update nginx configuration with actual domain name
echo "Updating nginx configuration with domain name..."
sed -i "s/DOMAIN_NAME/$DOMAIN/g" ./nginx/nginx.conf

# Create temporary nginx config for ACME challenge
echo "Creating temporary nginx configuration..."
cat > ./nginx/nginx-temp.conf <<EOF
events {
    worker_connections 1024;
}

http {
    server {
        listen 80;
        listen [::]:80;
        server_name $DOMAIN;

        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
        }

        location / {
            return 200 'Let\'s Encrypt ACME challenge';
            add_header Content-Type text/plain;
        }
    }
}
EOF

# Start nginx with temporary config
echo "Starting nginx for ACME challenge..."
docker run -d --name nginx-temp \
    -p 80:80 \
    -v $(pwd)/nginx/nginx-temp.conf:/etc/nginx/nginx.conf:ro \
    -v $(pwd)/certbot/www:/var/www/certbot:ro \
    nginx:1.25-alpine

# Wait for nginx to start
sleep 5

# Request SSL certificate
echo "Requesting SSL certificate from Let's Encrypt..."
STAGING_ARG=""
if [ $STAGING -eq 1 ]; then
    STAGING_ARG="--staging"
fi

docker run --rm \
    -v $(pwd)/certbot/conf:/etc/letsencrypt \
    -v $(pwd)/certbot/www:/var/www/certbot \
    -v $(pwd)/certbot/logs:/var/log/letsencrypt \
    certbot/certbot \
    certonly --webroot \
    -w /var/www/certbot \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    -d $DOMAIN \
    $STAGING_ARG

# Stop temporary nginx
echo "Stopping temporary nginx..."
docker stop nginx-temp
docker rm nginx-temp

# Create symbolic link for easier access
if [ -d "./certbot/conf/live/$DOMAIN" ]; then
    echo "SSL certificate obtained successfully!"
    echo ""
    echo "Certificate location: ./certbot/conf/live/$DOMAIN/"
    echo "Fullchain: ./certbot/conf/live/$DOMAIN/fullchain.pem"
    echo "Private key: ./certbot/conf/live/$DOMAIN/privkey.pem"
    echo ""
    echo "==================================="
    echo "✅ SSL Setup Complete!"
    echo "==================================="
    echo ""
    echo "Next steps:"
    echo "1. Start the services: docker-compose -f docker-compose.prod.yml up -d"
    echo "2. Verify HTTPS: curl -I https://$DOMAIN"
    echo "3. Check certificate: openssl s_client -connect $DOMAIN:443 -servername $DOMAIN"
    echo ""
else
    echo "==================================="
    echo "❌ SSL Setup Failed!"
    echo "==================================="
    echo "Check logs at: ./certbot/logs/"
    exit 1
fi
