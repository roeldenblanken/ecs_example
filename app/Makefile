# Project variables
# PROJECT_NAME ?= docfm
ORG_NAME ?= blankia
REPO_NAME ?= hello-world

# Filenames
DEV_COMPOSE_FILE := docker/dev/$(REPO_NAME)/docker-compose.yml
REL_COMPOSE_FILE := docker/prd/$(REPO_NAME)/docker-compose.yml

# Docker Compose Project Names
REL_PROJECT := $(REPO_NAME)$(BUILD_ID)
DEV_PROJECT := $(REL_PROJECT)dev

# Application Service Name - must match Docker Compose release specification application service name
APP_SERVICE_NAME := hello-world

# Build tag expression - can be used to evaulate a shell expression at runtime
BUILD_TAG_EXPRESSION ?= date -u +%Y%m%d%H%M%S

# Execute shell expression
BUILD_EXPRESSION := $(shell $(BUILD_TAG_EXPRESSION))

# Build tag - defaults to BUILD_EXPRESSION if not defined
BUILD_TAG ?= $(BUILD_EXPRESSION)

# Check and Inspect Logic
INSPECT := $$(docker-compose -p $$1 -f $$2 ps -q $$3 | xargs -I ARGS docker inspect -f "{{ .State.ExitCode }}" ARGS)

# Get login credentials
DOCKER_USER ?= $(shell bash -c 'read -p "DOCKER_USER: " pwd; echo $$pwd')
DOCKER_PASSWORD ?= $(shell bash -c 'read -s -p "DOCKER_PASSWORD: " pwd; echo $$pwd')

CHECK := @bash -c '\
  if [[ $(INSPECT) -ne 0 ]]; \
  then exit $(INSPECT); fi' VALUE

# Use these settings to specify a custom Docker registry
DOCKER_REGISTRY ?= docker.io

# WARNING: Set DOCKER_REGISTRY_AUTH to empty for Docker Hub
# Set DOCKER_REGISTRY_AUTH to auth endpoint for private Docker registry
DOCKER_REGISTRY_AUTH ?=

.PHONY: pull build run clean tag buildtag login logout publish

pull:
	${INFO} "Pulling latest dev images..."
	@ docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) pull 
	${INFO} "Pull complete"

build:
	${INFO} "Creating app image..."
	@ docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) build hello-world
	${INFO} "Build complete"
	
run:
	${INFO} "Ensuring app image is running..."
	@ docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) run -d --service-ports --rm -u root $(APP_SERVICE_NAME)
	${CHECK} $(DEV_PROJECT) $(DEV_COMPOSE_FILE) hello-world
	${INFO} "App is running now"

clean:
	${INFO} "Destroying development environment..."
	@ docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) down
	@ docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) rm -f -v
	${INFO} "Removing dangling images..."
	@ #docker images -q -f dangling=true -f label=application=$(REPO_NAME) | xargs -I ARGS docker rmi -f ARGS
	@ docker images -q -f dangling=true | xargs -I ARGS docker rmi -f ARGS
	${INFO} "Removing stopped containers..."
	@ docker kill $(docker ps -q)
	@ docker rm $$(docker ps -a -q)
	@ docker ps -a -q | xargs -I ARGS docker rm ARGS
	${INFO} "Clean complete"

tag: 
	${INFO} "Tagging image with tags $(TAG_ARGS)..."
	@ $(foreach tag,$(TAG_ARGS), docker tag $(IMAGE_ID) $(DOCKER_REGISTRY)/$(ORG_NAME)/$(REPO_NAME):$(tag);)
	${INFO} "Tagging complete"

buildtag:
	${INFO} "Tagging image with suffix $(BUILD_TAG) and build tags $(BUILDTAG_ARGS)..."
	@ $(foreach tag,$(BUILDTAG_ARGS), docker tag $(IMAGE_ID) $(DOCKER_REGISTRY)/$(ORG_NAME)/$(REPO_NAME):$(tag).$(BUILD_TAG);)
	${INFO} "Tagging complete"

login:
	${INFO} "Logging in to Docker registry $$DOCKER_REGISTRY $(DOCKER_REGISTRY_AUTH)..."
	@ winpty docker login -u $(DOCKER_USER) -p $(DOCKER_PASSWORD) $(DOCKER_REGISTRY_AUTH)
	${INFO} "Logged in to Docker registry $$DOCKER_REGISTRY"

logout:
	${INFO} "Logging out of Docker registry $$DOCKER_REGISTRY..."
	@ docker logout
	${INFO} "Logged out of Docker registry $$DOCKER_REGISTRY"	

publish:
	${INFO} "Publishing image $(IMAGE_ID) to $(DOCKER_REGISTRY)/$(ORG_NAME)/$(REPO_NAME)..."
	 $(foreach tag,$(shell echo $(REPO_EXPR)), docker push $(tag);)
	${INFO} "Publish complete"
	
# Cosmetics
YELLOW := "\e[1;33m"
NC := "\e[0m"

# Shell Functions
INFO := @bash -c '\
  printf $(YELLOW); \
  echo "=> $$1"; \
  printf $(NC)' SOME_VALUE

# Get container id of application service container
APP_CONTAINER_ID := $$(docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) ps -q $(APP_SERVICE_NAME))

# Get image id of application service
IMAGE_ID := $$(docker inspect -f '{{ .Image }}' $(APP_CONTAINER_ID))

# Repository Filter
ifeq ($(DOCKER_REGISTRY), docker.io)
	REPO_FILTER := $(ORG_NAME)/$(REPO_NAME)[^[:space:]|\$$]*
else
	REPO_FILTER := $(DOCKER_REGISTRY)/$(REPO_NAME)[^[:space:]|\$$]*
endif

# Introspect repository tags
REPO_EXPR := $$(docker inspect -f '{{range .RepoTags}}{{.}} {{end}}' $(IMAGE_ID) | grep -oh "$(REPO_FILTER)" | xargs)

# Extract build tag arguments
ifeq (buildtag,$(firstword $(MAKECMDGOALS)))
	BUILDTAG_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  ifeq ($(BUILDTAG_ARGS),)
  	$(error You must specify a tag)
  endif
  $(eval $(BUILDTAG_ARGS):;@:)
endif

# Extract tag arguments
ifeq (tag,$(firstword $(MAKECMDGOALS)))
  TAG_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  ifeq ($(TAG_ARGS),)
    $(error You must specify a tag)
  endif
  $(eval $(TAG_ARGS):;@:)
endif

