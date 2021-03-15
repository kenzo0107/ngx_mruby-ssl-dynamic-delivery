FROM matsumotory/ngx_mruby:master

#
# matsumotory/ngx-mruby image supports ONBUILD for below commands.
#
# ONBUILD ADD docker/hook /usr/local/nginx/hook
# ONBUILD ADD docker/conf /usr/local/nginx/conf
# ONBUILD ADD docker/conf/nginx.conf /usr/local/nginx/conf/nginx.conf

RUN ln -sf /dev/stdout /usr/local/nginx/logs/access.log
COPY docker/certs/* /etc/ssl/certs/
