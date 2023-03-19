VERSION=1.2
ORGANIZATION=lekovr

SOURCES:=$(shell find . -name '*.go'  | grep -v './vendor')

TARGET:=postgresql-prometheus-adapter

.PHONY: all clean build docker-image docker-push test prepare-for-docker-build docker-prebuild docker-prebuild-image

all: $(TARGET) 

build: $(TARGET)

$(TARGET): main.go $(SOURCES)
	go build -ldflags="-X 'main.Version=${VERSION}'" -o $(TARGET)

container: $(TARGET) Dockerfile
	@#podman rmi $(ORGANIZATION)/$(TARGET):latest $(ORGANIZATION)/$(TARGET):$(VERSION)
	podman build -t $(ORGANIZATION)/$(TARGET):latest .
	podman tag $(ORGANIZATION)/$(TARGET):latest $(ORGANIZATION)/$(TARGET):$(VERSION)

container-save: container
	rm -f $(TARGET)-$(VERSION).tar
	podman save --output=$(TARGET)-$(VERSION).tar $(ORGANIZATION)/$(TARGET):$(VERSION)

docker-image:
	docker build -t $(ORGANIZATION)/$(TARGET):$(VERSION) .

docker-prebuild: $(TARGET).docker

$(TARGET).docker: main.go $(SOURCES)
	CGO_ENABLED=0 go build -ldflags="-X 'main.Version=${VERSION}'" -o $@

docker-prebuild-image: docker-prebuild
	docker build -f Dockerfile.prebuild -t $(TARGET):$(VERSION) .

clean:
	rm -f *~ $(TARGET)

