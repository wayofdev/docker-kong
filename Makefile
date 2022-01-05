IMAGE_NAMESPACE ?= wayofdev/kong
TEMPLATE ?= alpine
BUILD_FROM ?= 2.7.0-alpine
IMAGE_TAG ?= $(IMAGE_NAMESPACE):$(TEMPLATE)-latest



########################################################################################################################
# Most likely there is nothing to change behind this line
########################################################################################################################
OS ?= $(shell uname)

all: generate build test clean
.PHONY: all

generate:
	set -x;
	sed -e 's/%%DOCKER_IMAGE%%/$(BUILD_FROM)/g' $(TEMPLATE)/Dockerfile.template > $(TEMPLATE)/Dockerfile
	#
	# https://unix.stackexchange.com/questions/401905/bsd-sed-vs-gnu-sed-and-i
	# OSX uses BSD based version of sed utility
ifeq ($(OS),Darwin)
	sed -i '' 's/%%DOCKER_TEMPLATE%%/$(TEMPLATE)/g' $(TEMPLATE)/Dockerfile
else
	sed -i 's/%%DOCKER_TEMPLATE%%/$(TEMPLATE)/g' $(TEMPLATE)/Dockerfile
endif
.PHONY: generate

build:
	docker build -f $(TEMPLATE)/Dockerfile . -t $(IMAGE_TAG)
.PHONY: build

test:
	set -eux
	GOSS_FILES_PATH=$(TEMPLATE) dgoss run -t $(IMAGE_TAG)
.PHONY: best

clean:
	rm -rf */Dockerfile
.PHONY: clean

pull:
	docker pull $(IMAGE_TAG)
.PHONY: pull

push:
	docker push $(IMAGE_TAG)
.PHONY: push

ssh:
	docker run --rm -it -v $(PWD)/:/opt/docker-kong $(IMAGE_TAG) sh
.PHONY: ssh

install-hooks:
	pre-commit install --hook-type commit-msg
.PHONY: install-hooks
