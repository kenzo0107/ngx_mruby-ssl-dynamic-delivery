FROM alpine:3.14.0 as base

ARG ENVIRONMENT
ENV ENVIRONMENT ${ENVIRONMENT:-development}

ENV NGINX_VER=1.19.8
ENV NGINX_BUILD=0.11.13
ENV NAXSI_VER=1.3

RUN apk add --update openssl-dev curl file

# == nginx-build
FROM base as nginx-build

ADD docker/nginx/build /build

RUN mkdir /usr/local/src
WORKDIR /usr/local/src

RUN apk add --update build-base openssl git ruby-rake bison perl pcre-dev zlib zlib-dev curl-dev \
    && curl -L https://github.com/cubicdaiya/nginx-build/releases/download/v$NGINX_BUILD/nginx-build-linux-amd64-$NGINX_BUILD.tar.gz -o nginx-build.tar.gz \
    && tar xvzf nginx-build.tar.gz \
    && curl -L https://github.com/nbs-system/naxsi/archive/refs/tags/$NAXSI_VER.tar.gz -o naxsi.tar.gz \
    && mkdir naxsi && tar xvzf naxsi.tar.gz -C naxsi --strip-components 1 \
    && ./nginx-build -verbose -v $NGINX_VER -d work -pcre -zlib -m /build/modules3rd.ini -c /build/configure.sh --clear \
    && cd work/nginx/$NGINX_VER/nginx-$NGINX_VER \
    && make install \
    && mv ../ngx_mruby/mruby/bin/* /usr/local/bin/

# == certs
FROM base as certs

RUN apk add --update openssl \
    && openssl genrsa -out /etc/ssl/certs/dummy.key 4096 \
    && openssl req -new -key /etc/ssl/certs/dummy.key -out /etc/ssl/certs/dummy.csr -subj "/CN=dummy" \
    && openssl x509 -req -in /etc/ssl/certs/dummy.csr -days 36500 -signkey /etc/ssl/certs/dummy.key > /etc/ssl/certs/dummy.crt

# == main
FROM base

WORKDIR /etc/nginx

RUN apk add --update --no-cache \
    tzdata

# TZ JST
RUN cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

COPY --from=nginx-build /usr/local/bin /usr/local/bin
COPY --from=nginx-build /etc/nginx .
COPY --from=certs /etc/ssl/certs/* /etc/ssl/certs/

COPY docker/nginx/conf/nginx.conf conf/nginx.conf
COPY docker/nginx/conf/conf.d/${ENVIRONMENT}.conf conf/conf.d/default.conf
COPY docker/nginx/conf/includes /etc/nginx/conf/includes
COPY docker/nginx/hook hook

RUN ln -sf /dev/stdout /etc/nginx/logs/access.log

EXPOSE 80 443

CMD ["/etc/nginx/sbin/nginx", "-g", "daemon off;"]
