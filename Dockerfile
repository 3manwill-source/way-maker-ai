# Multi-stage Dockerfile for WayMaker AI
FROM node:18-alpine AS web-builder

# Build frontend
WORKDIR /app/web
COPY web/package.json web/pnpm-lock.yaml ./
RUN npm install -g pnpm && pnpm install --frozen-lockfile

COPY web/ ./
RUN pnpm build

# Python API stage
FROM python:3.11-slim AS api-base

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    nginx \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy and install Python dependencies
COPY api/pyproject.toml api/uv.lock ./
RUN pip install uv && uv pip install --system --no-cache-dir -r uv.lock

# Copy API code
COPY api/ ./api/

# Copy built frontend
COPY --from=web-builder /app/web/.next ./web/.next
COPY --from=web-builder /app/web/public ./web/public
COPY --from=web-builder /app/web/package.json ./web/

# Copy nginx configuration
COPY nginx/ ./nginx/

# Configure nginx
RUN rm /etc/nginx/sites-enabled/default
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Configure supervisor
COPY <<EOF /etc/supervisor/conf.d/waymaker.conf
[supervisord]
nodaemon=true
user=root

[program:api]
command=python -m gunicorn --bind 0.0.0.0:8000 --workers 2 api.app:app
directory=/app
autostart=true
autorestart=true
stderr_logfile=/var/log/api.err.log
stdout_logfile=/var/log/api.out.log

[program:web]
command=node server.js
directory=/app/web
autostart=true
autorestart=true
stderr_logfile=/var/log/web.err.log
stdout_logfile=/var/log/web.out.log

[program:nginx]
command=/usr/sbin/nginx -g "daemon off;"
autostart=true
autorestart=true
stderr_logfile=/var/log/nginx.err.log
stdout_logfile=/var/log/nginx.out.log
EOF

# Create startup script
COPY <<EOF /app/start.sh
#!/bin/bash
set -e

# Initialize database if needed
cd /app/api
python -c "
import os
from app_factory import create_app
app = create_app()
with app.app_context():
    from extensions.ext_database import db
    db.create_all()
    print('Database initialized')
"

# Start supervisor
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/waymaker.conf
EOF

RUN chmod +x /app/start.sh

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

# Start services
CMD ["/app/start.sh"]
