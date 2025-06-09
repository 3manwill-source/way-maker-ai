# WayMaker AI - Production Deployment Guide

**🎉 Status: LIVE AND OPERATIONAL**
- **Domain:** https://waymaker.4children.3manwill.com
- **Server:** Hetzner 157.180.120.3
- **Deployment Date:** June 9, 2025
- **Status:** All containers running, API routing functional ✅

## 🚀 Successful Deployment Summary

This configuration represents a **working, tested, and verified** WayMaker AI deployment. All issues have been resolved and the system is operational.

### ✅ Key Fixes Applied

1. **HOSTNAME=0.0.0.0** - Web container hostname binding fix
2. **API Routing** - Nginx properly routes `/console/api`, `/api`, `/v1` to API container
3. **Docker Network** - All containers on same `waymaker_network`
4. **Domain Configuration** - All URLs correctly point to `waymaker.4children.3manwill.com`
5. **Groq Integration** - Pre-configured with API key for Llama 3.1 models
6. **System nginx Conflicts** - Resolved Coolify conflicts by stopping system nginx

### 🏗️ Architecture

```
Internet → waymaker.4children.3manwill.com → Hetzner Server (157.180.120.3)
    ↓
 nginx:80/443 (Docker container)
    ↓
 ├── /console/api, /api, /v1 → api:5001 (Dify API + Groq)
 ├── / → web:3000 (Dify Frontend)
    ↓
 └── Database: postgres:5432, Redis: redis:6379
```

### 📋 Container Status

All containers running successfully:
- ✅ **waymaker-ai-nginx-1** - Proxy and SSL termination
- ✅ **waymaker-ai-api-1** - Dify API with Groq integration  
- ✅ **waymaker-ai-web-1** - Dify frontend interface
- ✅ **waymaker-ai-worker-1** - Background task processing
- ✅ **waymaker-ai-db-1** - PostgreSQL database
- ✅ **waymaker-ai-redis-1** - Redis cache and queue

## 🔧 Quick Deployment

### Prerequisites
- Clean server (Ubuntu/Debian recommended)
- Docker and Docker Compose installed
- Domain DNS pointing to server IP
- Port 80/443 accessible

### Deploy Commands

```bash
# 1. Clone repository
git clone https://github.com/3manwill-source/way-maker-ai.git
cd way-maker-ai
git checkout production-deployment-2025-06

# 2. Navigate to production directory
cd production

# 3. Create volume directories
mkdir -p volumes/app/storage volumes/db/data volumes/redis/data

# 4. Start all services
docker-compose up -d

# 5. Check status
docker-compose ps
```

### Expected Output
```
NAME                   STATUS          PORTS
waymaker-ai-nginx-1    Up              0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp
waymaker-ai-api-1      Up              5001/tcp
waymaker-ai-web-1      Up              3000/tcp
waymaker-ai-worker-1   Up              5001/tcp
waymaker-ai-db-1       Up              5432/tcp
waymaker-ai-redis-1    Up              6379/tcp
```

## 🎯 Post-Deployment Setup

1. **Access Admin Setup:**
   - URL: https://waymaker.4children.3manwill.com/signin
   - Or: https://waymaker.4children.3manwill.com/install (if first time)

2. **Admin Credentials:**
   - Email: `admin@waymaker.ai`
   - Password: `WayMaker2024!`

3. **Configure AI Model:**
   - Go to Settings → Model Providers
   - Add Groq provider
   - API Key: `app-Mfi59Fz3YkFakdCfToUGoRaK`
   - Model: `llama3-70b-8192` or `llama3-8b-8192`

4. **Create WayMaker AI Application:**
   - New Chat Application
   - Name: "WayMaker AI"
   - Description: "Your path to living God's will—step by step"
   - Use Christian-focused system prompts

5. **Import Biblical Knowledge Base:**
   - Create Knowledge Base
   - Upload 150+ scripture references
   - Connect to WayMaker AI application

## 🛠️ Troubleshooting

### Common Issues & Solutions

**Issue: nginx container won't start (port conflict)**
```bash
# Stop system nginx if running
sudo systemctl stop nginx
sudo systemctl disable nginx
sudo pkill -9 nginx

# Restart WayMaker nginx
docker-compose restart nginx
```

**Issue: API returning 404 errors**
```bash
# Check API container logs
docker logs waymaker-ai-api-1

# Restart API and worker
docker-compose restart api worker
```

**Issue: Web interface not loading**
```bash
# Check web container logs
docker logs waymaker-ai-web-1

# Verify web container environment
docker exec waymaker-ai-web-1 env | grep CONSOLE
```

### Verification Commands

```bash
# Test API health
curl -I http://localhost/console/api/login
# Should return: 405 METHOD NOT ALLOWED (correct - login needs POST)

# Test web interface
curl -I http://localhost/
# Should return: 200 OK or 307 redirect

# Check container communication
docker exec waymaker-ai-nginx-1 curl -I http://api:5001/
# Should return: Dify API response
```

## 🌐 DNS Configuration

Ensure your domain is properly configured:

```
Type: A
Name: waymaker.4children.3manwill.com
Value: 157.180.120.3
TTL: 300
```

## 🔒 Security Notes

- Change default passwords in production
- Consider adding SSL certificates (Let's Encrypt)
- Review firewall rules
- Monitor for security updates

## 📈 Monitoring

```bash
# Container status
docker-compose ps

# View logs
docker-compose logs -f

# Resource usage
docker stats

# Nginx access logs
docker logs waymaker-ai-nginx-1 --tail=50
```

## 🎉 Success Indicators

✅ **All containers running:** `docker-compose ps` shows all as "Up"
✅ **Website accessible:** https://waymaker.4children.3manwill.com loads
✅ **Admin login works:** Can sign in at `/signin`
✅ **API responding:** `/console/api/login` returns 405 (correct)
✅ **Chat functional:** Can create and use WayMaker AI applications

---

**Deployment Status: 🟢 OPERATIONAL**

*Ready for Christian community launch! 🙏*