FROM alpine:latest

RUN apk add --update curl

RUN curl --fail --location --no-progress-meter https://github.com/spf13/hugo/releases/download/v0.80.0/hugo_0.80.0_Linux-64bit.tar.gz | tar -C /usr/bin -xzf -

