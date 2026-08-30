FROM alpine:latest

LABEL maintainer="sfuhrm"

EXPOSE 8080/tcp

RUN apk add --no-cache apache2 apache2-webdav apr-util-dbm_gdbm && \
    mkdir -p "/media/data" \
             "/var/lib/apache2/dav" && \
    rm -rf "/var/www/localhost" && \
    rm -f "/etc/apache2/conf.d/dav.conf" && \
    chown -R apache:apache "/media/data" "/var/lib/apache2" && \
    sed -i -e 's/^Listen 80$/Listen 8080/' \
           -e 's|^ErrorLog logs/error.log$|ErrorLog /dev/stderr|' \
           -e 's|CustomLog logs/access.log combined$|CustomLog /dev/stdout combined|' \
           -e 's|DocumentRoot "/var/www/localhost/htdocs"|DocumentRoot "/media/data"|' \
        /etc/apache2/httpd.conf && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/* && \
    find / -xdev -type f -perm /6000 -exec chmod a-s {} +

COPY --chmod=0555 entrypoint.sh /
COPY --chown=root:root webdav.conf /etc/apache2/conf.d/webdav.conf.template
COPY --chown=apache:apache webdav.conf /etc/apache2/conf.d/webdav.conf

VOLUME /media/data

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --spider -S http://127.0.0.1:8080/ 2>&1 | grep -E "HTTP/1\.[01] (200|401)"

USER apache

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "httpd", "-DFOREGROUND" ]
