SHELL := /bin/bash
SHELLFLAGS := -eu -o pipefail -c

CONTAINER_ENGINE ?= podman
IMAGE_NAME ?= starexec
PODMAN_SOCKET_PATH ?= /run/user/1000/podman/podman.sock
USER ?= $(shell whoami)
SSH_PORT ?= 22
HOST_MACHINE ?= localhost
VOLUME_DB ?= volDB
VOLUME_STAR ?= volStar
VOLUME_PRO ?= volPro
VOLUME_EXPORT ?= volExport

.PHONY: all build run clean kill cleanVolumes connect push

all: build

build:
	@echo "Ensuring SSH keys exist..."
	@if [ ! -f starexec_podman_key ]; then \
	  ssh-keygen -t ed25519 -N '' -f starexec_podman_key; \
	  ssh-copy-id -i starexec_podman_key.pub $(USER)@$(HOST_MACHINE); \
	fi
	@echo "Building $(IMAGE_NAME) image..."
	$(CONTAINER_ENGINE) build --no-cache -t $(IMAGE_NAME) . --ulimit="nofile=100000:100000"

run:
	$(CONTAINER_ENGINE) run --network=host --rm -it \
		-v $(VOLUME_DB):/var/lib/mysql \
		-v $(VOLUME_STAR):/home/starexec \
		-v $(VOLUME_PRO):/project \
		-v $(VOLUME_EXPORT):/export \
		-v ./starexec_podman_key:/root/.ssh/starexec_podman_key \
		-e SSH_USERNAME=$(USER) \
		-e HOST_MACHINE=$(HOST_MACHINE) \
		-e SSH_PORT=$(SSH_PORT) \
		-e SSH_SOCKET_PATH=$(PODMAN_SOCKET_PATH) \
		-p 80:80 -p 443:443 $(IMAGE_NAME)

clean:
	$(CONTAINER_ENGINE) rmi -f $(IMAGE_NAME) || true
	$(CONTAINER_ENGINE) rmi -f $$( \
	  $(CONTAINER_ENGINE) images -q --filter ancestor=$(IMAGE_NAME) \
	) || true

kill:
	$(CONTAINER_ENGINE) rm -f $$( \
	  $(CONTAINER_ENGINE) ps -aq --filter ancestor=$(IMAGE_NAME) \
	) || true

cleanVolumes:
	$(CONTAINER_ENGINE) volume rm -f \
		$(VOLUME_DB) $(VOLUME_STAR) $(VOLUME_PRO) $(VOLUME_EXPORT) || true

connect:
	$(CONTAINER_ENGINE) exec -it $$( \
	  $(CONTAINER_ENGINE) ps -aq --filter ancestor=$(IMAGE_NAME) \
	) bash

push:
	$(CONTAINER_ENGINE) push $(IMAGE_NAME) docker.io/tptpstarexec/$(IMAGE_NAME)
