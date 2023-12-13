APP := $(shell basename $(shell git remote get-url origin))
REGESTRY=ghcr.io/alex-poloz
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=linux
CH=amd64

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get

build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${CH} go build -v -o telebot -ldflags "-X="github.com/alex-poloz/telebot/cmd.appVersion=${VERSION}

image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${CH}  --build-arg CH=${CH}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${CH}

clean:
	rm -rf kbot
	docker rmi ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${CH}
