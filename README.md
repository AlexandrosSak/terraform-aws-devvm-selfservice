# Terraform AWS DevVM Self-Service Module

A modular, reusable Terraform repository designed to provision secure, standardized, on-demand AWS EC2 development instances for engineering teams.

It leverages an internal `devvm_instance` submodule to isolate instance lifecycle logic while managing top-level IAM policies and role attachments to enforce security baselines (such as encrypted EBS volumes, SSM Session Manager access, and automated resource tagging).

## Features

- **Submodule Architecture**: Uses a dedicated `devvm_instance` child module to isolate core EC2 compute logic from identity and access resources.
- **IAM Baseline Integration**: Centralizes IAM role, policy, and instance profile definitions in `iam.tf` for seamless Systems Manager (SSM) integration.
- **Standardized Compute & Storage**: Provisions EC2 instances with encrypted EBS root volumes using customer-managed or AWS-managed KMS keys.
- **Resource Tagging Baseline**: Enforces standard tagging schemes (Environment, Owner, CostCenter, ManagedBy) across all deployed resources.

## Repository Structure

```text
.
├── iam.tf                  # IAM roles, policies, and instance profiles
├── main.tf                 # Root module invoking the devvm_instance submodule
├── outputs.tf              # Top-level module outputs
├── variables.tf            # Top-level input variable declarations
└── modules/
    └── devvm_instance/
        ├── main.tf         # Core EC2 compute and security group resources
        ├── outputs.tf      # Submodule output definitions
        └── variables.tf    # Submodule input variable declarations
```

## Usage Example

```hcl
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
```

## Inputs

| Name | Description | Type | Default | Required |
| :--- | :--- | :--- | :--- | :--- |
| **`environment`** | Deployment environment (e.g., dev, staging) | `string` | `"dev"` | No |
| **`instance_type`** | EC2 instance size | `string` | `"t3.large"` | No |
| **`vpc_id`** | Target VPC ID where the instance will reside | `string` | None | Yes |
| **`subnet_id`** | Target Subnet ID | `string` | None | Yes |
| **`key_name`** | SSH Key Pair name | `string` | `null` | No |
| **`allowed_ingress_cidrs`** | CIDR blocks allowed to access the VM | `list(string)` | `[]` | No |
| **`root_volume_size`** | Size of the root EBS volume in GB | `number` | `50` | No |
| **`tags`** | Map of tags to assign to resources | `map(string)` | `{}` | No |

## Outputs

- **`instance_id`**: The ID of the deployed EC2 instance.
- **`private_ip`**: Private IP address assigned to the instance.
- **`public_ip`**: Public IP address assigned to the instance (if applicable).
- **`security_group_id`**: ID of the created security group.
- **`iam_role_arn`**: ARN of the IAM role attached to the instance profile.

## Development and Testing

Initialize Terraform and submodules:

```bash
terraform init
```

Validate configuration syntax:

```bash
terraform validate
```

Check formatting rules recursively:

```bash
terraform fmt -recursive -check
```
