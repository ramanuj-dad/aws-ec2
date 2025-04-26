############################
# GENERIC INSTANCE SETTINGS
############################
variable "name_prefix" {
  description = "Name prefix applied to all resources"
  type        = string
}

variable "ami_id" {
  description = "AMI to launch"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "Subnet in which to place the instance"
  type        = string
}

variable "additional_security_group_ids" {
  description = "Extra SGs to attach in addition to the one this module creates"
  type        = list(string)
  default     = []
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed to SSH (port 22).  Set to [] to disable."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "app_port" {
  description = "Application port to allow from the ALB (or publicly if ALB integration is off)"
  type        = number
  default     = 80
}

############################
# OPTIONAL RDS CONNECTIVITY
############################
variable "enable_rds_integration" {
  description = "Whether to allow egress to an RDS SG and grant IAM DB auth"
  type        = bool
  default     = false
}

variable "rds_security_group_id" {
  description = "RDS’s security-group ID. Required when enable_rds_integration = true."
  type        = string
  default     = null
}

############################
# OPTIONAL S3 CONNECTIVITY
############################
variable "enable_s3_integration" {
  description = "Whether to attach IAM permissions for the instance to access a bucket"
  type        = bool
  default     = false
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket the instance should read/write. Required when enable_s3_integration = true."
  type        = string
  default     = null
}

############################
# OPTIONAL ALB CONNECTIVITY
############################
variable "enable_alb_registration" {
  description = "Whether an external module will register this instance in its target group."
  type        = bool
  default     = false
}

variable "alb_security_group_id" {
  description = "ALB security-group ID whose ingress to app_port should be allowed. Required when enable_alb_registration = true."
  type        = string
  default     = null
}
