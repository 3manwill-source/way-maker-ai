# Fixed Dockerfile for WayMaker AI (Dify-based) - No port conflicts
FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install Python dependencies
RUN pip install --no-cache-dir \
    flask \
    gunicorn \
    requests \
    python-dotenv

# Copy API code
COPY api/ ./
COPY simple_app.py ./

# Environment variables
ENV FLASK_APP=simple_app.py
ENV FLASK_ENV=production

# Create startup script
RUN echo '#!/bin/bash\n\
set -e\n\
echo "Starting WayMaker AI on port 5000..."\n\
exec python simple_app.py\n\
' > /app/start.sh && chmod +x /app/start.sh

# Expose port 5000 (NOT 80 to avoid conflicts)
EXPOSE 5000

# Health check on port 5000
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:5000/health || exit 1

# Start application
CMD ["/app/start.sh"]
