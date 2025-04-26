########################################
# IAM ROLE + POLICIES
########################################
resource "aws_iam_role" "this" {
  name               = "${var.name_prefix}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
}

data "aws_iam_policy_document" "ec2_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.name_prefix}-ec2-profile"
  role = aws_iam_role.this.name
}

# Optional inline S3 policy
data "aws_iam_policy_document" "s3_access" {
  count = var.enable_s3_integration ? 1 : 0

  statement {
    actions   = ["s3:*"]
    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}",
      "arn:aws:s3:::${var.s3_bucket_name}/*"
    ]
  }
}

resource "aws_iam_role_policy" "s3_access" {
  count  = var.enable_s3_integration ? 1 : 0
  name   = "${var.name_prefix}-s3-access"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.s3_access[0].json
}

########################################
# SECURITY GROUP
########################################
resource "aws_security_group" "this" {
  name_prefix = "${var.name_prefix}-sg-"
  description = "Security group for EC2 module ${var.name_prefix}"
  vpc_id      = data.aws_subnet.selected.vpc_id
}

# Inbound SSH
resource "aws_security_group_rule" "ssh_in" {
  count             = length(var.ssh_cidr_blocks) > 0 ? 1 : 0
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.ssh_cidr_blocks
  security_group_id = aws_security_group.this.id
}

# Inbound app port (80 by default) – source controlled by ALB SG if provided
resource "aws_security_group_rule" "alb_in" {
  type              = "ingress"
  from_port         = var.app_port
  to_port           = var.app_port
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id

  source_security_group_id = var.enable_alb_registration ? var.alb_security_group_id : null
  cidr_blocks              = var.enable_alb_registration ? [] : ["0.0.0.0/0"]
}

# Optional egress rule to RDS
resource "aws_security_group_rule" "rds_egress" {
  count                    = var.enable_rds_integration ? 1 : 0
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.this.id
  source_security_group_id = var.rds_security_group_id
  description              = "Allow outbound traffic to RDS SG"
}

# Default allow-all egress (for updates, OS, etc.)
resource "aws_security_group_rule" "all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

########################################
# EC2 INSTANCE
########################################
data "aws_subnet" "selected" {
  id = var.subnet_id
}

resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = concat([aws_security_group.this.id], var.additional_security_group_ids)
  iam_instance_profile        = aws_iam_instance_profile.this.name

  tags = {
    Name = "${var.name_prefix}-ec2"
    Module = "aws-ec2-connectivity"
  }
}
