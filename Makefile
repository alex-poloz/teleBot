APP=$(shell basename $(shell git remote get-url origin) |cut -d '.' -f1)
REGESTRY=polozoleks
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)

ifeq '$(findstring ;,$(PATH))' ';'
    detected_OS := windows
	detected_arch := amd64
else
    detected_OS := $(shell uname | tr '[:upper:]' '[:lower:]' 2> /dev/null || echo Unknown)
    detected_OS := $(patsubst CYGWIN%,Cygwin,$(detected_OS))
    detected_OS := $(patsubst MSYS%,MSYS,$(detected_OS))
    detected_OS := $(patsubst MINGW%,MSYS,$(detected_OS))
	detected_arch := $(shell dpkg --print-architecture 2>/dev/null || amd64)
endif

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

image: build
	docker build . -t ${REGESTRY}/${APP}:${VERSION}-$(detected_arch)

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-$(detected_arch)

clean:
	rm -rf telebot; \
	docker rmi ${REGISTRY}/${APP}:${VERSION}-$(detected_arch)

# linux: TARGETOS=linux
# linux: build image push clean

linux: # Build for linucx, by default this made for arm64
	${MAKE} build TARGETOS=linux

windows: # Build for windows, by default this made for arm64
	${MAKE} build TARGETOS=windows

macos: # Build for macos, by default this made for arm64
	${MAKE} build TARGETOS=darwin