############################################
# NETWORK
############################################
variable "subnet_id" {
  description = <<-EOF
    Existing subnet ID to launch the instance in.
    Leave null to make the module automatically pick one of the default
    subnets that AWS created in the default VPC for this region.
  EOF
  type        = string
  default     = null
}



############################################
# INSTANCE BASICS
############################################
variable "name_prefix" {
  type        = string
  description = <<-EOF
    Optional prefix applied to all resource names.
    If omitted, the module will generate an 8-character random string.
 EOF
  default     = null
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

############################################
# AMI SELECTION (OPTIONAL OVERRIDE)
############################################
variable "ami_id" {
  description = "Explicit AMI ID. If null, the module auto-selects an Amazon Linux 2 AMI."
  type        = string
  default     = null
}

variable "ami_name_pattern" {
  type    = string
  default = "amzn2-ami-hvm-*-x86_64-gp2"
}

variable "ami_architecture" {
  type    = string
  default = "x86_64"
}

variable "ami_root_device_type" {
  type    = string
  default = "ebs"
}

variable "ami_virtualization_type" {
  type    = string
  default = "hvm"
}

variable "ami_owners" {
  type    = list(string)
  default = ["137112412989"]
}

############################################
# SECURITY GROUP OPTIONS
############################################
variable "ssh_cidr_blocks" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "app_port" {
  type    = number
  default = 80
}

variable "additional_security_group_ids" {
  type    = list(string)
  default = []
}

############################################
# OPTIONAL INTEGRATIONS
############################################
variable "enable_alb_registration" {
  type    = bool
  default = false
}

variable "alb_security_group_id" {
  type    = string
  default = null
  validation {
    condition     = var.enable_alb_registration == false || var.alb_security_group_id != null
    error_message = "When enable_alb_registration=true you must supply alb_security_group_id."
  }
}

variable "enable_rds_integration" {
  type    = bool
  default = false
}

variable "rds_security_group_id" {
  type    = string
  default = null
  validation {
    condition     = var.enable_rds_integration == false || var.rds_security_group_id != null
    error_message = "When enable_rds_integration=true you must supply rds_security_group_id."
  }
}

variable "enable_s3_integration" {
  type    = bool
  default = false
}

variable "s3_bucket_name" {
  type    = string
  default = null
  validation {
    condition     = var.enable_s3_integration == false || var.s3_bucket_name != null
    error_message = "When enable_s3_integration=true you must supply s3_bucket_name."
  }
}
