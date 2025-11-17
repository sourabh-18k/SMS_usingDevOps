#!/bin/sh
set -e

# Replace placeholders in config.js with environment variables
if [ -f /usr/share/nginx/html/config.js ]; then
  sed -i "s|__API_BASE_URL__|${VITE_API_BASE_URL:-http://localhost:8080}|g" /usr/share/nginx/html/config.js
  echo "Runtime config injected: API_BASE_URL=${VITE_API_BASE_URL:-http://localhost:8080}"
fi

# Start nginx
exec nginx -g 'daemon off;'
