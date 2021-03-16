FROM alpine:3.12

# https://github.com/cubicdaiya/nginx-build
ENV NGINX_BUILD=0.11.11
ENV NGINX_VER=1.19.8

RUN mkdir /usr/local/src
ADD config /config

WORKDIR /usr/local/src
RUN apk add --update openssl-dev git curl geoip-dev file wget mariadb-connector-c-dev \
    && apk add --virtual build-deps build-base ruby-rake bison perl \
    && curl -L https://github.com/cubicdaiya/nginx-build/releases/download/v$NGINX_BUILD/nginx-build-linux-amd64-$NGINX_BUILD.tar.gz -o nginx-build.tar.gz \
    && tar xvzf nginx-build.tar.gz \
    && ./nginx-build -verbose -v $NGINX_VER -d work -pcre -zlib -zlibversion=1.2.9 -m /config/modules3rd.ini -c /config/configure.sh --clear \
    && cd work/nginx/$NGINX_VER/nginx-$NGINX_VER \
    && make install \
    && apk del build-deps \
    && mv ../ngx_mruby/mruby/bin/* /usr/local/bin/ \
    && rm -rf /var/cache/apk/* /usr/local/src/*

EXPOSE 80 443
WORKDIR /usr/local/nginx

COPY docker/conf/nginx.conf conf/nginx.conf
COPY docker/hook hook
COPY docker/certs/* /etc/ssl/certs/

CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
