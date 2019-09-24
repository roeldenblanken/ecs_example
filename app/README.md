**Purpose: build a simple docker image**

# **Before use**
	export COLOR="black"
	export http_proxy=""

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
	docker build -t blankia/hello-world:latest -f Dockerfile \
		--build-arg COLOR=${COLOR} \
		--build-arg http_proxy=${http_proxy}  \
		.
		
## RUN APP image
	docker run -it --privileged -p 80:80 blankia/hello-world:latest

## Exec app image
	winpty docker exec -it {{ CONTAINER_ID }} sh

# **troubleshooting**
	docker ps
	docker images
	docker inspect  {{ CONTAINER_ID }}

