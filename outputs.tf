output "instance_id" {
  value = aws_instance.this.id
}

output "private_ip" {
  value = aws_instance.this.private_ip
}

output "security_group_id" {
  value = aws_security_group.this.id
}

output "iam_role_name" {
  value = aws_iam_role.this.name
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.this.name
}

output "subnet_id" {
  value = local.subnet_id_use
}

output "vpc_id" {
  value = local.vpc_id_use
}


output "ami_id" {
  value = local.ami_id_use
}
