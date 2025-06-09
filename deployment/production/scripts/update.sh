#!/bin/bash
# WayMaker AI Update Script
# Usage: ./update.sh

set -e

echo "Starting WayMaker AI update at $(date)"

# Backup before update
echo "Creating backup..."
./backup.sh

# Pull latest code
echo "Pulling latest code..."
git fetch origin
git pull origin production-deployment-2025-06

# Pull latest Docker images
echo "Pulling latest Docker images..."
docker compose pull

# Stop services
echo "Stopping services..."
docker compose down

# Start services with new images
echo "Starting services..."
docker compose up -d

# Wait for services to be ready
echo "Waiting for services to start..."
sleep 30

# Check health
echo "Checking service health..."
docker compose ps

# Test API
echo "Testing API..."
curl -f http://localhost/health || echo "Warning: Health check failed"

# Clean up old images
echo "Cleaning up old images..."
docker image prune -f

echo "Update completed at $(date)"
echo "Services status:"
docker compose ps