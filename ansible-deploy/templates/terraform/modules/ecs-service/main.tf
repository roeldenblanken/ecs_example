##################################################################################
# ecs service
##################################################################################
resource "aws_ecs_cluster" "this" {
  count = var.create_ecs ? 1 : 0

  name = "${var.name}"
  tags = "${var.tags}"
}

data "template_file" "task_definition" {
  template = "${file("${var.json_file}")}"

  vars = {
    image = "${var.image}",
	color = "${var.color}"
  }
}

resource "aws_ecs_task_definition" "this" {
  count = var.create_ecs ? 1 : 0
  family = "${var.name}_taskdefinition"

  container_definitions = "${data.template_file.task_definition.rendered}"
}

resource "aws_ecs_service" "this" {
  count = var.create_ecs ? 1 : 0
  name = "${var.name}"
  cluster = aws_ecs_cluster.this[0].id
  task_definition = aws_ecs_task_definition.this[count.index].arn

  desired_count = 2

  deployment_maximum_percent = 100
  deployment_minimum_healthy_percent = 50
  
  iam_role = "${var.iam_role}"
  
  load_balancer {
    target_group_arn = "${var.elb}"
    container_name   = "hello_world"
    container_port   = 80
  }
}