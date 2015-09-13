NAME = joonas_fi
VERSION = 0.0.1

.PHONY: all build run push

all: build

build:
	rm -rf build
	docker rm jekyll-builder || true
	docker run --name jekyll-builder --volume /vagrant/blog:/src:ro joonas/jekyll-builder:0.1.0
	docker cp jekyll-builder:/build .

	docker build -t dkr.xs.fi/$(NAME):$(VERSION) .

push:
	docker push dkr.xs.fi/$(NAME):$(VERSION)

preview:
	docker rm -f joonas_fi || true
	docker run -d --name joonas_fi -e VIRTUAL_HOST=joonas.fi.127.0.0.1.xip.io dkr.xs.fi/$(NAME):$(VERSION)

