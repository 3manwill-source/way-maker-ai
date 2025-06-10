#!/bin/bash
# WayMaker AI Health Check Script
# Usage: ./health-check.sh

set -e

DOMAIN="waymaker.4children.3manwill.com"
LOCAL_URL="http://localhost"
HTTPS_URL="https://$DOMAIN"

echo "WayMaker AI Health Check - $(date)"
echo "================================="

# Check Docker containers
echo "\n1. Docker Container Status:"
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

# Check disk space
echo "\n2. Disk Space:"
df -h | head -n 1
df -h | grep -E '/$|/opt'

# Check memory usage
echo "\n3. Memory Usage:"
free -h

# Check local health endpoint
echo "\n4. Local Health Check:"
if curl -f -s "$LOCAL_URL/health" > /dev/null; then
    echo "✅ Local health endpoint responding"
else
    echo "❌ Local health endpoint failed"
fi

# Check HTTPS if available
echo "\n5. HTTPS Health Check:"
if curl -f -s "$HTTPS_URL/health" > /dev/null; then
    echo "✅ HTTPS health endpoint responding"
else
    echo "❌ HTTPS health endpoint failed (SSL may not be configured)"
fi

# Check database
echo "\n6. Database Check:"
if docker compose exec -T db psql -U waymaker_user -d waymaker_ai -c "SELECT 1;" > /dev/null 2>&1; then
    echo "✅ Database connection working"
else
    echo "❌ Database connection failed"
fi

# Check Redis
echo "\n7. Redis Check:"
if docker compose exec -T redis redis-cli ping > /dev/null 2>&1; then
    echo "✅ Redis connection working"
else
    echo "❌ Redis connection failed"
fi

# Check API response
echo "\n8. API Response Test:"
API_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$LOCAL_URL/api/version" || echo "000")
if [ "$API_RESPONSE" = "200" ]; then
    echo "✅ API responding correctly ($API_RESPONSE)"
else
    echo "❌ API not responding correctly (HTTP $API_RESPONSE)"
fi

# Check logs for errors
echo "\n9. Recent Error Check:"
ERROR_COUNT=$(docker compose logs --since 1h 2>/dev/null | grep -i error | wc -l)
if [ "$ERROR_COUNT" -eq 0 ]; then
    echo "✅ No errors in last hour"
else
    echo "⚠️  $ERROR_COUNT errors found in last hour"
fi

# Summary
echo "\n================================="
echo "Health Check Completed - $(date)"
echo "\nTo view detailed logs:"
echo "  docker compose logs api"
echo "  docker compose logs nginx"
echo "\nTo restart services:"
echo "  docker compose restart [service_name]"