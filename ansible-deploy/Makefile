# Project variables

.PHONY: run jenkins_stack app_stack deploy terraform clean
	
run:
	${INFO} "Ensuring jenkins image is running..."
	@ docker run -it -d --rm  blankia/jenkins:latest bash | xargs -I {} sh -c "docker cp . {}:/var/tmp; echo winpty docker exec -it -u root {} bash"
	${INFO} "Jenkins is running now"

jenkins_stack:
	${INFO} "Deploying the Jenkins stack..."
	ansible-playbook site.yml --vault-password-file=vault.py --extra-var="debug=true jenkins=true"
	${INFO} "Finished"
	
app_stack:
	${INFO} "Deploying the app stack..."
	ansible-playbook site.yml --vault-password-file=vault.py --extra-var="debug=true app=true"
	${INFO} "Finished"
	
deploy:
	${INFO} "Deploying image..."
	ansible-playbook site.yml --vault-password-file=vault.py --extra-var="debug=true image_tag=blankia/hello-world:2.0 stack_config=true"
	${INFO} "Finished"
	
terraform:
	${INFO} "Deploying image: $(word 1,$(TERRAFORM_ARGS))  with color: $(word 2,$(TERRAFORM_ARGS))..."
	@ cd ./templates/terraform  && terraform init && terraform apply -var="color=$(word 2,$(TERRAFORM_ARGS))" -var="image=$(word 1,$(TERRAFORM_ARGS))"
	${INFO} "Finished"

clean:
	${INFO} "Removing dangling images..."
	@ #docker images -q -f dangling=true -f label=application=$(REPO_NAME) | xargs -I ARGS docker rmi -f ARGS
	@ docker images -q -f dangling=true | xargs -I ARGS docker rmi -f ARGS
	${INFO} "Removing stopped containers..."
	@ docker kill $(docker ps -q)
	@ docker rm $$(docker ps -a -q)
	@ docker ps -a -q | xargs -I ARGS docker rm ARGS
	${INFO} "Clean complete"

	
# Cosmetics
YELLOW := "\e[1;33m"
NC := "\e[0m"

# Shell Functions
INFO := @bash -c '\
  printf $(YELLOW); \
  echo "=> $$1"; \
  printf $(NC)' SOME_VALUE

# Extract terraform arguments
ifeq (terraform,$(firstword $(MAKECMDGOALS)))
	TERRAFORM_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  ifeq ($(TERRAFORM_ARGS),)
  	$(error You must specify a color and a tag)
  endif
  $(eval $(TERRAFORM_ARGS);@:)
endif