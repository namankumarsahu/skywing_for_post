FROM nginx:1.27-alpine

# Create runtime directories and configure Nginx
RUN mkdir -p /tmp/client_temp /tmp/proxy_temp /tmp/fastcgi_temp /tmp/uwsgi_temp /tmp/scgi_temp \
    && chown -R nginx:nginx /tmp

# Nginx configuration: listen on port 3000
RUN printf '%s\n' \
    'user nginx;' \
    'worker_processes auto;' \
    'pid /tmp/nginx.pid;' \
    'error_log /dev/stderr warn;' \
    'events { worker_connections 1024; }' \
    'http {' \
    '    include /etc/nginx/mime.types;' \
    '    default_type application/octet-stream;' \
    '    access_log /dev/stdout;' \
    '    sendfile on;' \
    '    tcp_nopush on;' \
    '    keepalive_timeout 65;' \
    '    server {' \
    '        listen 3000;' \
    '        server_name _;' \
    '        root /usr/share/nginx/html;' \
    '        index index.html;' \
    '        gzip on;' \
    '        gzip_types text/css application/javascript application/json image/svg+xml;' \
    '        location / {' \
    '            try_files $uri $uri/ =404;' \
    '        }' \
    '        location ~ /\. {' \
    '            deny all;' \
    '        }' \
    '        location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {' \
    '            expires 7d;' \
    '            add_header Cache-Control "public, immutable";' \
    '        }' \
    '    }' \
    '}' > /etc/nginx/nginx.conf

# Copy only application files
COPY --chown=nginx:nginx index.html styles.css script.js /usr/share/nginx/html/
COPY --chown=nginx:nginx assets/ /usr/share/nginx/html/assets/

# Run as non-root
USER nginx

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]