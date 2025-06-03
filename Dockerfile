# Simplified Dockerfile for WayMaker AI (Dify-based)
FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install Python dependencies
COPY api/pyproject.toml ./
RUN pip install --no-cache-dir \
    flask \
    gunicorn \
    psycopg2-binary \
    redis \
    requests \
    pydantic \
    sqlalchemy \
    flask-sqlalchemy \
    flask-migrate \
    celery \
    python-dotenv

# Copy API code
COPY api/ ./

# Create simple nginx config
RUN echo 'server { \
    listen 80; \
    server_name _; \
    location / { \
        proxy_pass http://localhost:5000; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; \
        proxy_set_header X-Forwarded-Proto $scheme; \
    } \
}' > /etc/nginx/sites-available/default

# Environment variables
ENV FLASK_APP=app.py
ENV FLASK_ENV=production
ENV WEB_API_CORS_ALLOW_ORIGINS=*
ENV CONSOLE_CORS_ALLOW_ORIGINS=*
ENV WEB_API_URL=http://localhost:5000
ENV CONSOLE_API_URL=http://localhost:5000

# Create startup script
RUN echo '#!/bin/bash\n\
set -e\n\
echo "Starting WayMaker AI..."\n\
\n\
# Start nginx in background\n\
nginx -g "daemon off;" &\n\
\n\
# Wait a moment for nginx to start\n\
sleep 2\n\
\n\
# Start Flask app\n\
echo "Starting Flask API on port 5000..."\n\
exec python app.py\n\
' > /app/start.sh && chmod +x /app/start.sh

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

# Start application
CMD ["/app/start.sh"]
