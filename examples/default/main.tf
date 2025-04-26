terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "ec2" {
  source = "../../"

  name_prefix  = "demo"
  ami_id       = "ami-0c02fb55956c7d316" # Amazon Linux 2023 x86_64 in us-east-1
  subnet_id    = "subnet-xxxxxxxx"

  # ALB integration example
  enable_alb_registration = true
  alb_security_group_id   = "sg-0abcd1234ef56789"

  # S3 integration example
  enable_s3_integration = true
  s3_bucket_name        = "demo-app-bucket"

  # RDS integration example
  enable_rds_integration = true
  rds_security_group_id  = "sg-0123456789abcdef0"
}
