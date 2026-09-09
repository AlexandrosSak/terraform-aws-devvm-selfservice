variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "vpc_id" {
  type    = string
  default = "vpc-0123456789abcdef0"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "private_subnet_ids" {
  type    = list(string)
  default = ["subnet-012345678eu1"]
}

variable "tags" {
  type = map(string)
  default = {
    Project   = "DevVM-SelfService"
    ManagedBy = "Terraform"
  }
}