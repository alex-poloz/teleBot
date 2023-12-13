APP=$(shell basename $(shell git remote get-url origin) |cut -d '.' -f1)
REGESTRY=ghcr.io/alex-poloz
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=linux
TARGETARCH=amd64

format:
	gofmt -s -w ./

test:
	go test -v

get:
	go get

build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${shell dpkg --print-architecture} go build -v -o telebot -ldflags "-X="github.com/alex-poloz/telebot/cmd.appVersion=${VERSION}

image:
	docker build . -t ${REGESTRY}/${APP}:${VERSION}-$(TARGETOS)-$(TARGETARCH)

push:
	docker push ${REGESTRY}/${APP}:${VERSION}-$(TARGETOS)-$(TARGETARCH)

clean:
	rm -rf telebot
	docker rmi ${REGESTRY}/${APP}:${VERSION}-$(TARGETOS)-$(TARGETARCH) -f

linux: format get
	CGO_ENABLED=0 GOOS=arm GOARCH=${shell dpkg --print-architecture} go build -v -o telebot -ldflags "-X="github.com/alex-poloz/telebot/cmd.appVersion=${VERSION}

windows: format get
	CGO_ENABLED=0 GOOS=windows GOARCH=${shell dpkg --print-architecture} go build -v -o telebot -ldflags "-X="github.com/alex-poloz/telebot/cmd.appVersion=${VERSION}

arm: format get
	CGO_ENABLED=0 GOOS=windows GOARCH=${TARGETARCH} go build -v -o telebot -ldflags "-X="github.com/alex-poloz/telebot/cmd.appVersion=${VERSION}

macos: format get
	CGO_ENABLED=0 GOOS=ios GOARCH=${shell dpkg --print-architecture} go build -v -o telebot -ldflags "-X="github.com/alex-poloz/telebot/cmd.appVersion=${VERSION}
