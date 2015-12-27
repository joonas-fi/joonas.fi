FROM smebberson/alpine-nginx
COPY build/ /usr/html

ENV VIRTUAL_HOST joonas.fi
