#!/bin/bash
# WayMaker AI SSL Setup Script
# Usage: sudo ./setup-ssl.sh

set -e

DOMAIN="waymaker.4children.3manwill.com"
EMAIL="admin@3manwill.com"

echo "Setting up SSL for WayMaker AI..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (use sudo)"
  exit 1
fi

# Install certbot if not present
if ! command -v certbot &> /dev/null; then
    echo "Installing certbot..."
    apt update
    apt install -y certbot python3-certbot-nginx
fi

# Stop nginx temporarily
echo "Stopping nginx temporarily..."
docker compose stop nginx

# Get certificate
echo "Obtaining SSL certificate for $DOMAIN..."
certbot certonly --standalone \
    --non-interactive \
    --agree-tos \
    --email $EMAIL \
    -d $DOMAIN

# Create SSL directory
echo "Setting up SSL certificates..."
mkdir -p nginx/ssl

# Copy certificates
cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem nginx/ssl/cert.pem
cp /etc/letsencrypt/live/$DOMAIN/privkey.pem nginx/ssl/key.pem

# Set permissions
chown -R 1000:1000 nginx/ssl
chmod 644 nginx/ssl/cert.pem
chmod 600 nginx/ssl/key.pem

# Update nginx configuration to enable SSL
echo "Updating nginx configuration..."
sed -i 's/# ssl_certificate /ssl_certificate /' nginx/nginx.conf
sed -i 's/# ssl_certificate_key /ssl_certificate_key /' nginx/nginx.conf

# Start nginx with SSL
echo "Starting nginx with SSL..."
docker compose up -d nginx

# Test SSL
echo "Testing SSL configuration..."
sleep 5
curl -I https://$DOMAIN || echo "Warning: SSL test failed"

# Setup auto-renewal
echo "Setting up SSL auto-renewal..."
(crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet && docker compose restart nginx") | crontab -

echo "SSL setup completed for $DOMAIN"
echo "Your WayMaker AI deployment is now secured with HTTPS"