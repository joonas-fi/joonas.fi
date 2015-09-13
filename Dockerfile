FROM kyma/docker-nginx
COPY build/ /var/www
CMD 'nginx'

ENV VIRTUAL_HOST joonas.fi
