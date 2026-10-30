FROM nginxinc/nginx-unprivileged:alpine

# Configure Nginx for port 3000
USER root

RUN printf '%s\n' \
    'server {' \
    '    listen 0.0.0.0:3000;' \
    '    server_name _;' \
    '    root /usr/share/nginx/html;' \
    '    index index.html;' \
    '    server_tokens off;' \
    '    location / {' \
    '        try_files $uri $uri/ /index.html;' \
    '    }' \
    '    location /assets/ {' \
    '        try_files $uri =404;' \
    '        expires 7d;' \
    '        add_header Cache-Control "public";' \
    '    }' \
    '    location ~ /\. {' \
    '        deny all;' \
    '    }' \
    '}' > /etc/nginx/conf.d/default.conf

# Copy only required static website files
COPY --chown=101:101 index.html /usr/share/nginx/html/
COPY --chown=101:101 styles.css /usr/share/nginx/html/
COPY --chown=101:101 script.js /usr/share/nginx/html/
COPY --chown=101:101 assets/ /usr/share/nginx/html/assets/

# Run as non-root user
USER 101

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]