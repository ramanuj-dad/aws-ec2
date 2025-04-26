output "instance_id" {
  value       = aws_instance.this.id
  description = "EC2 instance ID"
}

output "private_ip" {
  value       = aws_instance.this.private_ip
  description = "EC2 private IP address"
}

output "security_group_id" {
  value       = aws_security_group.this.id
  description = "Primary security-group ID for the instance"
}

output "iam_role_name" {
  value       = aws_iam_role.this.name
  description = "IAM role attached to the instance"
}

output "instance_profile_name" {
  value       = aws_iam_instance_profile.this.name
  description = "Instance profile used by the EC2 instance"
}
