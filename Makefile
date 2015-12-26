NAME = joonas/joonas.fi
VERSION = latest

.PHONY: all build run push

all: build

build:
	rm -rf build/
	docker rm jekyll-builder || true
	docker run --name jekyll-builder --volume /vagrant/blog:/src:ro joonas/jekyll-builder:0.1.0
	docker cp jekyll-builder:/build .

	docker build -t $(NAME):$(VERSION) .

push:
	docker push $(NAME):$(VERSION)

preview:
	docker rm -f joonas_fi || true
	docker run -d --name joonas_fi -e VIRTUAL_HOST=joonas.fi.dev.xs.fi $(NAME):$(VERSION)
	echo "Running at http://joonas.fi.dev.xs.fi/"

