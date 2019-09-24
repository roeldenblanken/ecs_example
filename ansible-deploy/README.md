**Purpose: Deploy the app and infra with Ansible**

# **Before use**
	export VAULT_PASSWORD=xxxxxx
	export AWS_ACCESS_KEY_ID=AK123
	export AWS_SECRET_ACCESS_KEY=abc123
	
	Have ansible installed locally
	Or use the earlier created jenkins image to deploy the app and infra with Ansible

# How to use
	### Deploy jenkins stack
	ansible-playbook site.yml --vault-password-file=vault.py --extra-var="debug=true jenkins=true"

	### Deploy app stack
	ansible-playbook site.yml --vault-password-file=vault.py --extra-var="debug=true app=true"
	
	### Deploy a new version of the app
	ansible-playbook site.yml --vault-password-file=vault.py --extra-var="debug=true image_tag=blankia/hello-world:2.0 stack_config=true"

	ansible-playbook site.yml --vault-password-file=vault.py --extra-var="debug=true app=true image_tag=blankia/hello-world:2.0 stack_config=true COLOR=red"


# **How to use with make commands**
	make run -> Start a Docker container with Ansible
	make jenkins_stack
	make app_stack
	make deploy

## Run Jenkins image with ansible workdir included
	docker run -it -d --rm  blankia/jenkins:latest bash | xargs -I {} sh -c "docker cp . {}:/var/tmp; echo winpty docker exec -it -u root {} bash"
	docker run -it -d --rm  blankia/jenkins:latest bash | xargs -I {} sh -c "docker cp . {}:/var/tmp; winpty docker exec -it -u root {} bash"
		
# **troubleshooting**
	docker ps
	docker images
	docker inspect  {{ CONTAINER_ID }}

