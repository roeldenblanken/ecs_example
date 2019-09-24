##################################################################################
# Variables --- ecs service
##################################################################################
variable "create_ecs" {
  description = "Controls if ECS should be created"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name to be used on all the resources as identifier, also the name of the ECS cluster"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to ECS Cluster"
  type        = map(string)
  default     = {}
}

variable "iam_role" {
  description = "Name of the IAM policy"
  type        = string
}

variable "elb" {
  description = "Arn of the elb"
  type        = string
}

variable "json_file" {
  description = "Location of the json file"
  type        = string
  default	  =	"../../templates/taskdefinitions/hello-world-taskdefinition.json"		
}

variable "image" {
  description = "Image of the container"
  type        = string
  default	  =	"blankia/hello-world:1.0"		
}

variable "color" {
  description = "Color of the container"
  type        = string
  default	  =	"black"		
}