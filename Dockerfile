# WayMaker AI - Production Ready Dockerfile
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

# Copy all application files
COPY . .

# Create the main application
RUN echo 'from flask import Flask, jsonify, send_from_directory, render_template_string
import os

app = Flask(__name__, static_folder=".", static_url_path="")

@app.route("/")
def home():
    return jsonify({
        "message": "WayMaker AI is running!",
        "status": "healthy", 
        "version": "production-v2",
        "tagline": "Your path to living God'\''s will---step by step",
        "features": ["Biblical AI", "Age Adaptation", "Crisis Support", "Community Chat"]
    })

@app.route("/health")
def health():
    return jsonify({"status": "ok"})

@app.route("/chat")
def chat():
    try:
        return send_from_directory(".", "waymaker_enhanced_community_chat.html")
    except Exception as e:
        return jsonify({
            "error": "Chat interface not found", 
            "available_files": [f for f in os.listdir(".") if f.endswith(".html")],
            "message": "WayMaker AI chat interface will be available soon"
        })

@app.route("/apps")
def apps():
    return jsonify({
        "message": "WayMaker AI Apps Interface",
        "status": "available",
        "chat_url": "/chat",
        "features": ["Biblical Guidance", "Prayer Support", "Crisis Intervention"]
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)
' > app.py

# Environment variables
ENV FLASK_APP=app.py
ENV FLASK_ENV=production

# Expose port 5000
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:5000/health || exit 1

# Start application
CMD ["python", "app.py"]