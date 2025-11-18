#!/bin/bash

# Update frontend on Azure VM
SERVER="4.218.12.135"
CONTAINER="sms-frontend-1"

echo "Updating frontend files in container..."

# Copy new index.html
cat << 'EOF' > /tmp/index.html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/assets/logo-p2AoECBb.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>SMS DevOps</title>
    <script src="/config.js"></script>
    <script type="module" crossorigin src="/assets/index-BIgbwR2D.js"></script>
    <link rel="stylesheet" crossorigin href="/assets/index-CoJyNNAh.css">
  </head>
  <body class="bg-white">
    <div id="root"></div>
  </body>
</html>
EOF

# Update index.html in container
ssh azureuser@$SERVER "docker cp /tmp/index.html $CONTAINER:/usr/share/nginx/html/index.html && docker exec $CONTAINER nginx -s reload"

echo "Frontend updated successfully!"
