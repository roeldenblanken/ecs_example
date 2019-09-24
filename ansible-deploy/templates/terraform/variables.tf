##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "region" {
  default = "eu-west-1"
}

variable "instance_type" {
  default = "t2.large"
}

variable "vpc_id" {
  default = "vpc-85071ae1"
}

variable "subnet_id" {
  default = ["subnet-1d859f6b", "subnet-d776508f"]
}

variable "key_name" {
  default = "Work"
}

variable "image" {
  type = string
  default = "blankia/hello-world:1.0"
}

variable "color" {
  type = string
  default = "black"
}

