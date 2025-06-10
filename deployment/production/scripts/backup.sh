#!/bin/bash
# WayMaker AI Backup Script
# Usage: ./backup.sh

set -e

BACKUP_DIR="/opt/waymaker-ai/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="waymaker_backup_${DATE}"

# Create backup directory
mkdir -p $BACKUP_DIR

echo "Starting WayMaker AI backup at $(date)"

# Database backup
echo "Backing up database..."
docker compose exec -T db pg_dump -U waymaker_user waymaker_ai > $BACKUP_DIR/${BACKUP_NAME}_database.sql

# Volumes backup
echo "Backing up volumes..."
sudo tar -czf $BACKUP_DIR/${BACKUP_NAME}_volumes.tar.gz volumes/

# Configuration backup
echo "Backing up configuration..."
cp .env $BACKUP_DIR/${BACKUP_NAME}_env.txt
cp docker-compose.yml $BACKUP_DIR/${BACKUP_NAME}_compose.yml

# Compress everything
echo "Creating final backup archive..."
tar -czf $BACKUP_DIR/${BACKUP_NAME}.tar.gz -C $BACKUP_DIR ${BACKUP_NAME}_*

# Clean up individual files
rm $BACKUP_DIR/${BACKUP_NAME}_*

# Keep only last 7 backups
ls -t $BACKUP_DIR/waymaker_backup_*.tar.gz | tail -n +8 | xargs -r rm

echo "Backup completed: $BACKUP_DIR/${BACKUP_NAME}.tar.gz"
echo "Backup finished at $(date)"