FROM debian:bookworm

ARG LOGIN

RUN apt-get update && apt-get install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes -days 365 \
    -out /etc/nginx/ssl/inception.crt \
    -keyout /etc/nginx/ssl/inception.key \
    -subj "/C=FR/ST=ML/L=Thionville/O=42/OU=42/CN=${LOGIN}.42.fr/UID=${LOGIN}"

COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

RUN mkdir -p /var/www/html && \
    chmod 755 /var/www/html && \
    chown -R www-data:www-data /var/www/html

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
