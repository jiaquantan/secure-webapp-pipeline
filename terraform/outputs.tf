# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

# Security Group Outputs
output "web_security_group_id" {
  description = "ID of the web security group"
  value       = aws_security_group.web.id
}

# EC2 Instance Outputs
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_eip.web.public_ip
}

output "instance_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.web.public_dns
}

# Application URLs
output "app_url" {
  description = "URL to access the application"
  value       = "http://${aws_eip.web.public_ip}:5000"
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/secure-webapp-key ec2-user@${aws_eip.web.public_ip}"
}

# IAM Outputs
output "ec2_role_arn" {
  description = "ARN of the EC2 IAM role"
  value       = aws_iam_role.ec2_role.arn
}

# DNS Outputs (Optional)
output "domain_name" {
  description = "Domain name (if configured)"
  value       = var.domain_name != "" ? var.domain_name : "Not configured"
}

output "https_url" {
  description = "HTTPS URL to access the application (if domain configured)"
  value       = var.domain_name != "" ? "https://${var.domain_name}" : "Configure domain_name variable to enable HTTPS"
}

output "dns_records" {
  description = "DNS records created (if domain configured)"
  value = var.create_dns_record && var.domain_name != "" ? {
    main = "${var.domain_name} -> ${aws_eip.web.public_ip}"
    www  = "www.${var.domain_name} -> ${aws_eip.web.public_ip}"
  } : {}
}
