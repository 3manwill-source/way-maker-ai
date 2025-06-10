# WayMaker AI - GitHub Actions CI/CD

This repository includes comprehensive CI/CD pipelines for WayMaker AI deployment.

## 🚀 Workflows Overview

### 1. **CI Pipeline** (`.github/workflows/ci.yml`)
- **Triggers**: Push to `main`/`develop`, Pull Requests
- **Features**:
  - Parallel testing for API (Python) and Web (Node.js)
  - Dependency installation and caching
  - Code linting and building
  - Test execution (with fallbacks for missing tests)

### 2. **Deployment Pipeline** (`.github/workflows/deploy.yml`)
- **Triggers**: Push to `main`, Manual dispatch
- **Features**:
  - Automatic deployment to Coolify
  - Webhook integration with Coolify server
  - Deployment notifications

### 3. **Security Scanning** (`.github/workflows/security.yml`)
- **Triggers**: Push, Pull Requests, Weekly schedule
- **Features**:
  - Trivy vulnerability scanning
  - npm audit for frontend dependencies
  - Python safety checks for backend
  - SARIF upload to GitHub Security

### 4. **Docker Images** (`.github/workflows/docker.yml`)
- **Triggers**: Push, Tags, Pull Requests
- **Features**:
  - Multi-architecture builds (amd64, arm64)
  - Container registry publishing (GHCR)
  - Build caching for faster builds
  - Automated tagging strategy

## 🔧 Required Secrets

Add these secrets in **Repository Settings → Secrets and Variables → Actions**:

| Secret | Description | Example |
|--------|-------------|---------|
| `COOLIFY_WEBHOOK_URL` | Coolify deployment webhook | `http://157.180.120.3:8000/webhooks/...` |

## 📋 Setup Instructions

### 1. **Enable GitHub Actions**
- Actions are automatically enabled for public repositories
- Check **Actions** tab in your repository

### 2. **Configure Coolify Webhook**
1. Go to Coolify dashboard: `http://157.180.120.3:8000`
2. Create application from GitHub repository
3. Copy webhook URL
4. Add as `COOLIFY_WEBHOOK_URL` secret in GitHub

### 3. **Container Registry**
- Uses GitHub Container Registry (ghcr.io)
- Automatically configured with `GITHUB_TOKEN`
- No additional setup required

## 🔄 Deployment Flow

1. **Developer pushes to `main`**
2. **CI workflow runs** (testing, building)
3. **Docker images built** and pushed to registry
4. **Deployment workflow triggers** Coolify webhook
5. **Coolify pulls latest code** and deploys
6. **WayMaker AI updates** at `waymaker.3manwill4children.com`

## 🐛 Troubleshooting

### Common Issues:
- **Tests failing**: Add test scripts to `package.json` (web) or install pytest (api)
- **Docker build errors**: Check Dockerfile syntax in `api/` and `web/` directories
- **Deployment not triggering**: Verify `COOLIFY_WEBHOOK_URL` secret is set correctly
- **Security scan failures**: Review and fix reported vulnerabilities

### Logs:
- Check **Actions** tab for detailed workflow logs
- Monitor Coolify dashboard for deployment status
- Review **Security** tab for vulnerability reports
