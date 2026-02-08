#!/bin/bash

###############################################################################
# Let's Encrypt SSL Certificate Renewal Script
# This script renews SSL certificates and reloads nginx
# Add to cron: 0 0 * * 0 /path/to/renew-certs.sh >> /var/log/cert-renew.log 2>&1
###############################################################################

set -e

echo "======================================"
echo "SSL Certificate Renewal - $(date)"
echo "======================================"

# Navigate to project directory
cd "$(dirname "$0")/.." || exit 1

# Attempt to renew certificates
echo "Attempting to renew certificates..."
docker-compose -f docker-compose.prod.yml run --rm certbot renew

# Reload nginx to pick up new certificates
echo "Reloading nginx..."
docker-compose -f docker-compose.prod.yml exec nginx nginx -s reload

echo "Certificate renewal process completed!"
echo "======================================"
echo ""
