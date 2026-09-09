terraform {
  required_version = ">= 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# --- DEVELOPER REGISTRY & CONFIGURATION MAPS ---
locals {
  default_settings = {
    instance_type = "t3a.large"
    shutdown      = "0 0 * * *" # Daily scheduled scale-down at midnight
  }

  devs = {
    "adam"       = {}
    "angelos"    = {}
    "chris"      = {}
    "dan"        = { instance_type = "c5.xlarge" } # Custom override for heavy workloads
    "darren"     = {}
    "dimitris"   = {}
    "dimos"      = {}
    "ioannis"    = {}
    "johnathan"  = {}
    "konstadina" = {}
    "showcase01" = {}
    "showcase02" = {}
    "vangelis"   = {}
  }

  merged_devs = {
    for dev, settings in local.devs :
    dev => merge(local.default_settings, settings)
  }

  asg_names = { for dev in keys(local.merged_devs) : dev => "devvm_${dev}" }
}

# --- DATA SOURCES ---
data "aws_ami" "devvm" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["adzuna-devvm-ubuntu-22.04-*"]
  }
}

# --- SECURITY GROUPS ---
resource "aws_security_group" "devvm" {
  name        = "devvm-security-group"
  description = "Security group for developer self-service VMs"
  vpc_id      = var.vpc_id

  ingress {
    description = "Internal SSH and HTTPS Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# --- MODULE CALL (ORCHESTRATING PER-DEV ASG) ---
module "dev" {
  for_each = local.merged_devs

  source               = "./modules/devvm_instance"
  dev                  = each.key
  instance_type        = each.value.instance_type
  ami_id               = data.aws_ami.devvm.id
  vpc_id               = var.vpc_id
  subnet_id            = var.private_subnet_ids[0]
  security_group_ids   = [aws_security_group.devvm.id]
  iam_instance_profile = aws_iam_instance_profile.devvm.name

  tags = merge(var.tags, {
    Developer   = each.key
    Environment = "development"
  })
}

# --- COST OPTIMIZATION: AUTOMATED NIGHTLY SHUTDOWN SCHEDULE ---
resource "aws_autoscaling_schedule" "terminate_instances" {
  for_each               = local.asg_names
  scheduled_action_name  = "terminate-instances-${each.key}"
  min_size               = 0
  desired_capacity       = 0
  max_size               = 1
  recurrence             = local.merged_devs[each.key].shutdown
  autoscaling_group_name = module.dev[each.key].asg_name
}