FROM ccr.ccs.tencentyun.com/crs-backend/crs-php-fpm-mods:1.0

COPY src /data/www

RUN rm /bin/sh && \
    ln -s /bin/bash /bin/sh && \
    cd /data/www && \

