FROM docker.io/kanboard/kanboard:v1.2.52

# Patch nginx config for Railway
# - Remove SSL directives (not needed on Railway, which terminates TLS at the edge)
# - The nginx run script will substitute PORT at runtime
RUN sed -i \
    -e '/443 ssl/d' \
    -e '/http2/d' \
    -e '/ssl_certificate/d' \
    -e '/ssl_certificate_key/d' \
    -e '/ssl_protocols/d' \
    -e '/ssl_ciphers/d' \
    -e '/ssl_prefer_server_ciphers/d' \
    -e '/ssl_session_timeout/d' \
    -e '/ssl_session_cache/d' \
    -e '/ssl_session_tickets/d' \
    /etc/nginx/nginx.conf

# Replace the s6 nginx run script with a bash wrapper that substitutes PORT at runtime
RUN printf '#!/bin/bash\nset -e\nsed -i "s/listen[[:space:]]\\+80;/listen ${PORT:-80};/" /etc/nginx/nginx.conf\nexec nginx -g "daemon off;"\n' > /etc/services.d/nginx/run && \
    chmod +x /etc/services.d/nginx/run

# Remove the self-signed SSL cert generation from entrypoint (entire if block)
RUN sed -i '/^# Generate a new self signed SSL certificate/,/^fi$/d' /usr/local/bin/entrypoint.sh

EXPOSE 80

# Default runtime configuration
ENV PORT=80
ENV DB_DRIVER=sqlite
ENV DB_NAME=kanboard
ENV PLUGIN_INSTALLER=false
ENV DEBUG=false
ENV MAIL_TRANSPORT=smtp
ENV MAIL_SMTP_PORT=25
ENV MAIL_FROM=notifications@localhost


HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD curl -f http://localhost:${PORT:-80}/healthcheck.php || exit 1
