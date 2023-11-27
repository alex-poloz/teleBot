APP=$(shell basename $(shell git remote get-url origin) |cut -d '.' -f1)
REGESTRY=polozoleks
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS ?=linux
TARGETOSARCH ?=arm64

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get

build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETOSARCH} go build -v -o telebot -ldflags "-X="github.com/alex-poloz/telebot/cmd.appVersion=${VERSION}

image:
	docker build . -t ${DOCKER_USERNAME}/${APP}:${VERSION}-${SHORT_HASH}-linux-amd64

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETOSARCH}

clean:
	rm -rf telebot
	docker rmi ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETOSARCH}

# linux: TARGETOS=linux
# linux: build image push clean

linux: # Build for linucx, by default this made for arm64
	${MAKE} build TARGETOS=linux

windows: # Build for windows, by default this made for arm64
	${MAKE} build TARGETOS=windows

macos: # Build for macos, by default this made for arm64
	${MAKE} build TARGETOS=darwin