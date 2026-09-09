variable "dev" { type = string }
variable "instance_type" { type = string }
variable "ami_id" { type = string }
variable "vpc_id" { type = string }
variable "subnet_id" { type = string }
variable "security_group_ids" { type = list(string) }
variable "iam_instance_profile" { type = string }
variable "tags" { type = map(string), default = {} }