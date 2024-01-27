# Image values
REGISTRY := "localhost"
IMAGE := "ark-ascended-test"
IMAGE_REF := $(REGISTRY)/$(IMAGE)

# Git commit hash
HASH := $(shell git rev-parse --short HEAD)

# Buildah/Podman Options
CONTAINER_NAME := "ark-ascended-test"
VOLUME_NAME := "persistent-data-test"
BUILDAH_BUILD_OPTS := --format docker -f ./container/Containerfile
PODMAN_RUN_OPTS := --name $(CONTAINER_NAME) -d --mount type=volume,source=$(VOLUME_NAME),target=/home/steam/ark/ShooterGame/Saved -p 7777:7777/udp -p 27020:27020/tcp --env=SESSION_NAME='Ark Containerized Server Test' --env=SERVER_MAP='TheIsland_WP' --env=SERVER_PASSWORD='PleaseChangeMe' --env=SERVER_ADMIN_PASSWORD='AlcoChangeMe' --env=GAME_PORT=7777 --env=RCON_PORT=27020

# Makefile targets
.PHONY: build run cleanup

build:
	buildah build $(BUILDAH_BUILD_OPTS) -t $(IMAGE_REF):$(HASH) ./container

run:
	podman volume create $(VOLUME_NAME)
	podman run $(PODMAN_RUN_OPTS) $(IMAGE_REF):$(HASH)

cleanup:
	podman rm -f $(CONTAINER_NAME)
	podman rmi -f $(IMAGE_REF):$(HASH)
	podman volume rm $(VOLUME_NAME)
