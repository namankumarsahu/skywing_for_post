
# Serve the static site with an unprivileged NGINX image.
FROM nginxinc/nginx-unprivileged:alpine

WORKDIR /usr/share/nginx/html

# Copy only the files required to serve the site.
COPY --chown=nginx:nginx index.html styles.css script.js ./
COPY --chown=nginx:nginx assets/ ./assets/

EXPOSE 8080

# Verify that NGINX is serving the website.
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1:8080/ || exit 1
