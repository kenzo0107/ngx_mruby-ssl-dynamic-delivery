FROM alpine:3.12

# https://github.com/cubicdaiya/nginx-build
ENV NGINX_BUILD=0.11.11
ENV NGINX_VER=1.19.8

RUN mkdir /usr/local/src
ADD build /build

WORKDIR /usr/local/src
RUN apk add --update openssl-dev curl file wget \
    && apk add --virtual build-deps build-base openssl git ruby-rake bison perl \
    && curl -L https://github.com/cubicdaiya/nginx-build/releases/download/v$NGINX_BUILD/nginx-build-linux-amd64-$NGINX_BUILD.tar.gz -o nginx-build.tar.gz \
    && tar xvzf nginx-build.tar.gz \
    && ./nginx-build -verbose -v $NGINX_VER -d work -pcre -zlib -zlibversion=1.2.9 -m /build/modules3rd.ini -c /build/configure.sh --clear \
    && cd work/nginx/$NGINX_VER/nginx-$NGINX_VER \
    && make install \
    && openssl genrsa -out /etc/ssl/certs/dummy.key 4096 \
    && openssl req -new -key /etc/ssl/certs/dummy.key -out /etc/ssl/certs/dummy.csr -subj "/CN=dummy" \
    && openssl x509 -req -in /etc/ssl/certs/dummy.csr -days 36500 -signkey /etc/ssl/certs/dummy.key > /etc/ssl/certs/dummy.crt \
    && rm /etc/ssl/certs/dummy.csr \
    && apk del build-deps \
    && mv ../ngx_mruby/mruby/bin/* /usr/local/bin/ \
    && rm -rf /var/cache/apk/* /usr/local/src/*

EXPOSE 80 443
WORKDIR /usr/local/nginx

COPY docker/conf/nginx.conf conf/nginx.conf
COPY docker/hook hook

CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
