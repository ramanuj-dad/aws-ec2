# AWS EC2 Connectivity Module

This Terraform module provisions an EC2 instance in either an existing or newly created subnet within the default VPC, along with supporting networking, IAM, and optional integrations (ALB, RDS, S3).

## Usage
```hcl
module "ec2_connectivity" {
  source              = "./path/to/aws-ec2-connectivity"
  name_prefix         = "myapp"
  # Optional overrides:
  subnet_cidr_block   = "10.0.2.0/24"        # if you want a new subnet
  subnet_id           = "subnet-0123456789abcdef0"  # to reuse existing subnet
  instance_type       = "t3.small"
  ami_id              = null                   # or specify AMI ID

  # Security / networking
  ssh_cidr_blocks     = ["203.0.113.0/24"]
  app_port            = 8080
  additional_security_group_ids = []

  # Optional integrations
  enable_alb_registration = true
  alb_security_group_id   = "sg-0123456789abcdef0"
  enable_rds_integration  = false
  enable_s3_integration   = true
  s3_bucket_name          = "my-bucket"
}
```

## Inputs
| Name                           | Type             | Default                          | Required     | Description                                                                                               |
|--------------------------------|------------------|----------------------------------|--------------|-----------------------------------------------------------------------------------------------------------|
| `name_prefix`                  | string           | n/a                              | yes          | Prefix applied to all resource names.                                                                     |
| `subnet_id`                    | string           | `null`                           | no           | Existing subnet ID. If provided, module reuses this subnet; otherwise creates one in default VPC.        |
| `subnet_cidr_block`            | string           | `"10.0.1.0/24"`               | no           | CIDR block for a newly created subnet (when `subnet_id` is null).                                        |
| `instance_type`                | string           | `"t3.micro"`                   | no           | EC2 instance type.                                                                                       |
| `ami_id`                       | string           | `null`                           | no           | Explicit AMI ID. If null, auto-selects latest Amazon Linux 2 AMI.                                         |
| `ami_name_pattern`             | string           | `"amzn2-ami-hvm-*-x86_64-gp2"` | no           | AMI name filter pattern (when selecting automatically).                                                  |
| `ami_architecture`             | string           | `"x86_64"`                     | no           | AMI architecture filter.                                                                                 |
| `ami_root_device_type`         | string           | `"ebs"`                        | no           | AMI root device type filter.                                                                             |
| `ami_virtualization_type`      | string           | `"hvm"`                        | no           | AMI virtualization type filter.                                                                          |
| `ami_owners`                   | list(string)     | `["137112412989"]`             | no           | List of AMI owner IDs (default: Amazon).                                                                  |
| `ssh_cidr_blocks`              | list(string)     | `[
  "0.0.0.0/0"
]`           | no           | CIDR blocks allowed for SSH ingress.                                                                     |
| `app_port`                     | number           | `80`                             | no           | TCP port opened for application ingress.                                                                 |
| `additional_security_group_ids`| list(string)     | `[]`                             | no           | Extra security group IDs to attach to the instance.                                                      |
| `enable_alb_registration`      | bool             | `false`                          | no           | If `true`, restricts app ingress to `alb_security_group_id` instead of opening `0.0.0.0/0`.               |
| `alb_security_group_id`        | string           | `null`                           | conditional  | Security group ID for ALB (required when `enable_alb_registration = true`).                             |
| `enable_rds_integration`       | bool             | `false`                          | no           | If `true`, allows egress to RDS security group.                                                          |
| `rds_security_group_id`        | string           | `null`                           | conditional  | Security group ID for RDS (required when `enable_rds_integration = true`).                               |
| `enable_s3_integration`        | bool             | `false`                          | no           | If `true`, attaches an inline policy granting full access to the S3 bucket.                              |
| `s3_bucket_name`               | string           | `null`                           | conditional  | Name of the S3 bucket (required when `enable_s3_integration = true`).                                    |

## Outputs
| Name                    | Description                                                                 |
|-------------------------|-----------------------------------------------------------------------------|
| `instance_id`           | ID of the created EC2 instance.                                              |
| `private_ip`            | Private IP address assigned to the instance.                                 |
| `security_group_id`     | ID of the security group created for the instance.                           |
| `iam_role_name`         | Name of the IAM role attached to the instance.                               |
| `instance_profile_name` | Name of the IAM instance profile.                                            |
| `subnet_id`             | ID of the subnet (existing or newly created).                                 |
| `vpc_id`                | ID of the VPC where resources are provisioned.                                |
| `ami_id`                | AMI ID used to launch the instance (explicit or auto-selected).              |

## Resource Creation Order
1. **Data Sources**
   - Fetch available AZs (`aws_availability_zones.available`)
   - Lookup default VPC (`aws_vpc.default`)
   - (Conditional) Read existing subnet (`aws_subnet.existing`)

2. **Networking**
   - (Conditional) Create a new subnet (`aws_subnet.generated`)
   - Evaluate `local.subnet_id_use` and `local.vpc_id_use`

3. **AMI Selection**
   - (Conditional) Lookup latest AMI (`aws_ami.autosel`)
   - Evaluate `local.ami_id_use`

4. **IAM Setup**
   - Create EC2 trust policy document
   - Create IAM role (`aws_iam_role.this`)
   - Create instance profile (`aws_iam_instance_profile.this`)
   - (Conditional) Create S3 access policy and attach inline policy

5. **Security Groups**
   - Create security group (`aws_security_group.this`)
   - (Conditional) SSH ingress rule
   - Application ingress rule (ALB or `0.0.0.0/0`)
   - (Conditional) RDS egress rule
   - Allow-all egress rule

6. **EC2 Instance**
   - Launch EC2 instance (`aws_instance.this`) with the selected subnet, AMI, instance profile, and security groups.  

---


