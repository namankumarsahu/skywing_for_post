FROM nginxinc/nginx-unprivileged:alpine

# Write the nginx config inline: listen on 0.0.0.0:3000 (hardcoded).
USER root
RUN printf '%s\n' \
  'server {' \
  '  listen 3000;' \
  '  listen [::]:3000;' \
  '  server_name _;' \
  '  server_tokens off;' \
  '  root /usr/share/nginx/html;' \
  '  index index.html;' \
  '  gzip on;' \
  '  gzip_types text/css application/javascript image/svg+xml;' \
  '  location ~ /\. { deny all; }' \
  '  location /assets/ { expires 7d; add_header Cache-Control "public"; }' \
  '  location / { try_files $uri $uri/ /index.html; }' \
  '}' > /etc/nginx/conf.d/default.conf
USER 101

# Only the files the site needs (Dockerfile/README are not served)
COPY --chown=101:101 index.html styles.css script.js /usr/share/nginx/html/
COPY --chown=101:101 assets/ /usr/share/nginx/html/assets/

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1:3000/ || exit 1