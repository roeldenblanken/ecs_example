##################################################################################
# Variables --- instance-profile
##################################################################################
variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default 	  = "ecs"
}
variable "json_file" {
  description = "Location of the json file"
  type        = string
  default	  =	"../../templates/policies/ec2-instance-policy.json"		
}

variable "policy_arns" {
  description = "Policy_arn's t add to the instance profile"
  type        = map
}
