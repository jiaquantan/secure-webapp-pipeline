# Project Configuration
variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "secure-webapp"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# AWS Configuration
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# Network Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"] # CHANGE THIS to your IP for security!
}

# EC2 Configuration
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro" # Free tier eligible
}

variable "ssh_public_key" {
  description = "SSH public key for EC2 access"
  type        = string
  # Generate with: ssh-keygen -t rsa -b 4096 -f ~/.ssh/secure-webapp-key
  # Then paste the content of ~/.ssh/secure-webapp-key.pub here
  default = "" # Add your public key here or use -var-file
}

# Application Configuration
variable "app_version" {
  description = "Application version"
  type        = string
  default     = "1.0.0"
}
