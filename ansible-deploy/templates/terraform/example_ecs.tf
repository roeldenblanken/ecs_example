provider "aws" {
  region     = var.region
}

locals {
  name        = "complete-ecs"
  environment = "dev"

  # This is the convention we use to know what belongs to each other
  resources_name = "${local.name}-${local.environment}"
}

data "aws_ami" "latest_ecs" {
	most_recent = true
	owners 		= ["amazon"]

	filter {
		name   = "name"
		values = ["amzn-ami-*-amazon-ecs-optimized"]
	}

	filter {
      name   = "virtualization-type"
      values = ["hvm"]
	}  
}

module "ec2-instance-profile" {
  source 			= "./modules/instance-profile"
  name   			= "ec2-${local.resources_name}"
  json_file			= "./templates/policies/ec2-instance-policy.json"
  policy_arns	  	=	{
     policy_arn1 	= "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  }		  
}

module "ecs-instance-profile" {
  source 			= "./modules/instance-profile"
  name   			= "ecs-${local.resources_name}"
  json_file			= "./templates/policies/ecs-service-policy.json"	
  policy_arns	  	=	{
     policy_arn1 	= "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
  }	
}

## ALB
resource "aws_alb_target_group" "test" {
  name     = "cluster-${local.resources_name}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_alb" "main" {
  name            = "alb-${local.resources_name}"
  subnets         = var.subnet_id
  security_groups = ["sg-0c0f3bf70b08e716d"]
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.test.id}"
    type             = "forward"
  }
}

#----- ECS Cluster --------
module "ecs" {
  source 		= "./modules/ecs-service"
  create_ecs 	= true
  name   		= "cluster-${local.resources_name}"
  iam_role 		= "arn:aws:iam::003342916324:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"
  elb 			= "${aws_alb_target_group.test.id}"
  json_file		= "./templates/taskdefinitions/hello-world-taskdefinition.json"
  image			= "${var.image}"
  color 		= "${var.color}"
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 3.0"
  
  name   		= "autoscaling-${local.resources_name}"

  # Launch configuration
  lc_name = local.resources_name

  image_id             = data.aws_ami.latest_ecs.id
  instance_type        = var.instance_type
  security_groups      = ["sg-0c0f3bf70b08e716d"]
  iam_instance_profile = module.ec2-instance-profile.this_iam_instance_profile_id
  user_data            = data.template_file.user_data.rendered
  key_name			   = var.key_name
  
  # Auto scaling group
  asg_name                  = local.resources_name
  vpc_zone_identifier       = var.subnet_id
  health_check_type         = "EC2"
  min_size                  = 0
  max_size                  = 2
  desired_capacity          = 2
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Environment"
      value               = local.environment
      propagate_at_launch = true
    },
    {
      key                 = "Cluster"
      value               = "cluster-${local.resources_name}"
      propagate_at_launch = true
    },
  ]
}

data "template_file" "user_data" {
  template = file("./templates/scripts/user-data.sh")

  vars = {
    cluster_name = "cluster-${local.resources_name}"
  }
}