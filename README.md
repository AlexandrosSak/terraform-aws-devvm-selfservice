Markdown
# Terraform AWS DevVM Self-Service Module

A modular, reusable Terraform repository designed to provision secure, standardized, on-demand AWS EC2 development instances for engineering teams. 

It leverages an internal `devvm_instance` submodule to isolate instance lifecycle logic while managing top-level IAM policies and role attachments to enforce security baselines (such as encrypted EBS volumes, SSM Session Manager access, and automated resource tagging).

## Features

- **Submodule Architecture**: Uses a dedicated `devvm_instance` child module to isolate core EC2 compute logic from identity and access resources.
- **IAM Baseline Integration**: Centralizes IAM role, policy, and instance profile definitions in `iam.tf` for seamless Systems Manager (SSM) integration.
- **Standardized Compute & Storage**: Provisions EC2 instances with encrypted EBS root volumes using customer-managed or AWS-managed KMS keys.
- **Resource Tagging Baseline**: Enforces standard tagging schemes (Environment, Owner, CostCenter, ManagedBy) across all deployed resources.

## Repository Structure

├── iam.tf                  # IAM roles, policies, and instance profiles
├── main.tf                 # Root module invoking the devvm_instance submodule
├── outputs.tf              # Top-level module outputs
├── variables.tf            # Top-level input variable declarations
└── modules/
    └── devvm_instance/
        ├── main.tf         # Core EC2 compute and security group resources
        ├── outputs.tf      # Submodule output definitions
        └── variables.tf    # Submodule input variable declarations

Usage Example   

module "dev_vm" {
  source = "./modules/devvm_instance"

  environment   = "dev"
  instance_type = "t3.xlarge"
  key_name      = "dev-team-key"
  vpc_id        = "vpc-0123456789abcdef0"
  subnet_id     = "subnet-0123456789abcdef0"

  allowed_ingress_cidrs = ["10.0.0.0/16"]

  tags = {
    Owner      = "Engineering"
    CostCenter = "R&D"
  }
}


Inputs
environment: Deployment environment (e.g., dev, staging). Type: string. Default: "dev"

instance_type: EC2 instance size. Type: string. Default: "t3.large".

vpc_id: Target VPC ID where the instance will reside. Type: string. Default: None.

subnet_id: Target Subnet ID. Type: string. Default: None.

key_name: SSH Key Pair name. Type: string. Default: null.

allowed_ingress_cidrs: CIDR blocks allowed to access the VM. Type: list(string). Default: [].

root_volume_size: Size of the root EBS volume in GB. Type: number. Default: 50.

tags: Map of tags to assign to resources. Type: map(string). Default: {}.


Outputs
instance_id: The ID of the deployed EC2 instance.

private_ip: Private IP address assigned to the instance.

public_ip: Public IP address assigned to the instance (if applicable).

security_group_id: ID of the created security group.

iam_role_arn: ARN of the IAM role attached to the instance profile.