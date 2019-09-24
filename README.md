**Purpose: Display how to deploy a simple app in ECS using Jenkins and Ansible. Can use Cloudformation or Terraform**

**See also the read me's in the subfolders for extra info**

Requirements:
	AWS account
	Make
	Ansible


1. Deploy the Jenkins stack from a local machine -> ansible-playbook ansible-deploy/site.yml --vault-password-file=vault.py --extra-var="debug=true jenkins=true"
2. Configure AWS/GIT credentials in Jenkins + Add 1 new pipeline project and configure the Github url
3. TASKS parameter is for example: "app": "true", "stack_config": "true"
4. Configure the docker hub to autobuild when a code change has taken place in the github project. Also configure docker hub to call the 
   notify webhook of the jenkins project. http://jenkins-s-elasticl-tizvdipwvhfa-429014174.eu-west-1.elb.amazonaws.com/dockerhub-webhook/notify
   