**Purpose: build a jenkins docker image with Ansible/Docker/Make binaries**

# **Before use**
	export DOCKER_GID=996
	docker volume create --name=jenkins_home
	Get the initial Jenkins token from: /var/jenkins_home/secrets/initialAdminPassword

# **How to use with make commands**
	make pull
	make build
	make run
	make tag 1.0 -> tags current running container images
	make buildtag R1.0 -> tags current running container images
	make publish -> publishes current running container images

# **How to use with docker commands**
    alias docker="winpty docker"

## Build app image
	docker build -t blankia/jenkins:latest -f Dockerfile \
		--build-arg DOCKER_GID=${DOCKER_GID} \
		.
		
## RUN APP image
	docker run -it --privileged -p 8080:8080 blankia/jenkins:latest

## Exec app image
	winpty docker exec -it {{ CONTAINER_ID }} sh

# **troubleshooting**
	docker ps
	docker images
	docker inspect  {{ CONTAINER_ID }}

