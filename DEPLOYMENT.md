# WayMaker AI Deployment Configuration

This directory contains the production deployment configuration for WayMaker AI.

## Files:
- `docker-compose.production.yml` - Production Docker Compose configuration
- `.env.production.template` - Environment variables template
- `nginx/nginx.conf` - Nginx reverse proxy configuration

## Deployment Steps:

### 1. Prepare Environment
```bash
# Copy environment template
cp .env.production.template .env

# Edit environment variables
nano .env
```

### 2. SSL Certificates
Place your SSL certificates in `nginx/ssl/`:
- `waymaker.3manwill4children.com.crt`
- `waymaker.3manwill4children.com.key`

### 3. Deploy with Coolify
1. Create new application in Coolify
2. Connect to GitHub repository
3. Set source directory to repository root
4. Set Docker Compose file to `docker-compose.production.yml`
5. Configure environment variables from `.env`
6. Deploy!

### 4. Domain Configuration
- DNS A record: `waymaker.3manwill4children.com` → `95.217.187.120`
- TTL: 300 seconds

## Services:
- **web**: Frontend (Next.js) on port 3000
- **api**: Backend (Python/Flask) on port 5001  
- **postgres**: Database on port 5432
- **redis**: Cache on port 6379
- **nginx**: Reverse proxy on ports 80/443

## Environment Variables Required:
- `DB_PASSWORD` - PostgreSQL password
- `REDIS_PASSWORD` - Redis password
- `SECRET_KEY` - Application secret key
- `DEEPSEEK_API_KEY` - DeepSeek AI API key
- `OPENAI_API_KEY` - OpenAI API key
- Email configuration for user registration

## Health Checks:
- Frontend: https://waymaker.3manwill4children.com
- API: https://waymaker.3manwill4children.com/api/health
- Console: https://waymaker.3manwill4children.com/console
