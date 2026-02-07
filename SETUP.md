# 🚀 Secure Web Application Pipeline - Setup Guide

Welcome! This guide will help you set up and deploy your DevSecOps project step-by-step.

## ⏱️ Time Estimate: 1-2 hours

## Prerequisites Checklist

Before starting, ensure you have:

- [] AWS Account (Free Tier eligible)
- [ ] GitHub Account
- [ ] Docker Desktop installed
- [ ] Git installed
- [ ] Text editor (VS Code recommended)

## Step-by-Step Setup

### Phase 1: Local Setup (15 minutes)

#### 1.1 Install Required Tools

**Windows (using Chocolatey)**
```powershell
# Install Chocolatey first (if not installed)
# Visit: https://chocolatey.org/install

# Install tools
choco install git -y
choco install docker-desktop -y
choco install terraform -y
choco install awscli -y
choco install vscode -y

# Verify installations
git --version
docker --version
terraform --version
aws --version
```

**Alternative: Manual Installation**
- Docker Desktop: https://www.docker.com/products/docker-desktop
- Git: https://git-scm.com/downloads
- Terraform: https://www.terraform.io/downloads
- AWS CLI: https://aws.amazon.com/cli/

#### 1.2 Fork and Clone Repository

```bash
# 1. Fork this repository on GitHub
# Click "Fork" button on GitHub

# 2. Clone your fork
git clone https://github.com/YOUR_USERNAME/secure-webapp-pipeline.git
cd secure-webapp-pipeline

# 3. Verify structure
```

**Windows (PowerShell):**
```powershell
dir
# or
Get-ChildItem
```

**Linux/Mac (Bash):**
```bash
ls -la
```

### Phase 2: Test Locally (20 minutes)

#### 2.1 Run Application Locally

```bash
# Build and run the Flask app
cd app
docker build -t secure-webapp:local .
docker run -p 5000:5000 secure-webapp:local

# In another terminal, test:
curl http://localhost:5000
curl http://localhost:5000/health
curl http://localhost:5000/api/tasks

# Stop with Ctrl+C
```

#### 2.2 Run Monitoring Stack

```bash
# From project root
docker-compose -f docker-compose.monitoring.yml up -d

# Access:
# Grafana: http://localhost:3000 (admin/admin)
# Prometheus: http://localhost:9090

# Stop when done:
docker-compose -f docker-compose.monitoring.yml down
```

### Phase 3: AWS Setup (25 minutes)

#### 3.1 Create AWS Account

1. Go to https://aws.amazon.com/free/
2. Create new account (requires credit card, but we'll use free tier)
3. Verify email and phone

#### 3.2 Create IAM User

# Login to AWS Console
# Go to IAM → Users → Create User

# Step 1: Specify user details
Username: terraform-user
Click "Next"

# Step 2: Set permissions
- Select: "Attach policies directly"
- Search and check these policies:
  ✓ AmazonEC2FullAccess
  ✓ AmazonVPCFullAccess
  ✓ IAMFullAccess
Click "Next"

# Step 3: Review and create
- Review the details
Click "Create user"

# Step 4: Create Access Keys (separate step after user creation)
- Click on the username "terraform-user"
- Go to "Security credentials" tab
- Scroll to "Access keys" section
- Click "Create access key"
- Select use case: "Command Line Interface (CLI)"
- Check the confirmation box
- Click "Next"
- (Optional) Add description tag
- Click "Create access key"
- IMPORTANT: Download CSV or copy both:
  * Access key ID
  * Secret access key
- Click "Done"

# Save Access Key ID and Secret Access Key securely!

#### 3.3 Configure AWS CLI

**Both Windows and Linux/Mac:**
```bash
aws configure

# Enter when prompted:
AWS Access Key ID: [from step 3.2]
AWS Secret Access Key: [from step 3.2]
Default region name: us-east-1
Default output format: json

# Test configuration:
aws sts get-caller-identity
```

**Expected output:**
```json
{
    "UserId": "AIDAXXXXXXXXXXXXXXXXX",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/terraform-user"
}
```

#### 3.4 Generate SSH Key Pair

**Windows (PowerShell):**
```powershell
# Generate key (no passphrase)
ssh-keygen -t rsa -b 4096 -f $env:USERPROFILE\.ssh\secure-webapp-key -N '""'

# This creates:
# - C:\Users\YourName\.ssh\secure-webapp-key (private key)
# - C:\Users\YourName\.ssh\secure-webapp-key.pub (public key)

# View public key
Get-Content $env:USERPROFILE\.ssh\secure-webapp-key.pub

# Copy to clipboard (optional)
Get-Content $env:USERPROFILE\.ssh\secure-webapp-key.pub | Set-Clipboard
```

**Linux/Mac (Bash):**
```bash
# Generate key (press Enter twice for no passphrase)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/secure-webapp-key

# This creates:
# - ~/.ssh/secure-webapp-key (private key)
# - ~/.ssh/secure-webapp-key.pub (public key)

# View public key
cat ~/.ssh/secure-webapp-key.pub

# Copy to clipboard (Mac)
cat ~/.ssh/secure-webapp-key.pub | pbcopy

# Copy to clipboard (Linux with xclip)
cat ~/.ssh/secure-webapp-key.pub | xclip -selection clipboard
```

**Save your public key - you'll need it for Terraform in Phase 4!**

### Phase 4: Terraform Setup (20 minutes)

#### 4.1 Configure Terraform Variables

**Windows (PowerShell):**
```powershell
cd terraform

# Copy example file
Copy-Item terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars (opens in default editor)
notepad terraform.tfvars

# Get your public IP
Invoke-RestMethod -Uri https://ifconfig.me/ip
```

**Linux/Mac (Bash):**
```bash
cd terraform

# Copy example file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars
nano terraform.tfvars
# or: vi terraform.tfvars

# Get your public IP
curl ifconfig.me
```

**Edit terraform.tfvars and replace these values:**
- ssh_public_key: paste your public key from step 3.4
- ssh_cidr_blocks: your IP from the command above

**Example terraform.tfvars:**
```hcl
project_name = "secure-webapp"
environment  = "dev"
aws_region   = "us-east-1"

instance_type = "t2.micro"  # Free tier

# Replace with YOUR public key!
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC..."

# Replace with YOUR IP for security!
ssh_cidr_blocks = ["123.45.67.89/32"]  # Your IP here!

app_version = "1.0.0"
```

#### 4.2 Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Review the plan, then apply
terraform apply

# Type 'yes' when prompted

# Save outputs (you'll need these!)
terraform output instance_public_ip
terraform output app_url
```

**Expected Output:**
```
Apply complete! Resources: 12 added, 0 changed, 0 destroyed.

Outputs:
app_url = "http://54.123.45.67:5000"
instance_public_ip = "54.123.45.67"
ssh_command = "ssh -i ~/.ssh/secure-webapp-key ec2-user@54.123.45.67"
```

### Phase 5: Docker Hub Setup (10 minutes)

#### 5.1 Create Docker Hub Account

1. Go to https://hub.docker.com/
2. Sign up for free account
3. Verify email

#### 5.2 Create Access Token

```bash
# Login to Docker Hub
# Go to: Account Settings → Security → New Access Token

Token Description: github-actions
Permissions: Read, Write, Delete

# Save the token! You can't see it again
```

#### 5.3 Create Repository

```bash
# On Docker Hub
# Create → Create Repository

Name: secure-webapp
Visibility: Public (or Private)
```

### Phase 6: GitHub Setup (15 minutes)

#### 6.1 Create GitHub Repository

```bash
# On GitHub
# New Repository

Name: secure-webapp-pipeline
Description: DevSecOps pipeline demonstrating CI/CD with AWS
Visibility: Public (for portfolio)

# Don't initialize with README (we already have one)
```

#### 6.2 Configure GitHub Secrets


**Windows (PowerShell):**
```powershell
# View private key
Get-Content $env:USERPROFILE\.ssh\secure-webapp-key

# Copy to clipboard
Get-Content $env:USERPROFILE\.ssh\secure-webapp-key | Set-Clipboard
```

**Linux/Mac (Bash):**
```bash
# View private key
cat ~/.ssh/secure-webapp-key

# Copy to clipboard (Mac)
cat ~/.ssh/secure-webapp-key | pbcopy

# Copy to clipboard (Linux with xclip)
cat ~/.ssh/secure-webapp-key | xclip -selection clipboard
Name: AWS_SECRET_ACCESS_KEY
Value: [Your AWS Secret Key from Phase 3.2]

Name: DOCKERHUB_USERNAME
Value: [Your Docker Hub username]

Name: DOCKERHUB_TOKEN
Value: [Token from Phase 5.2]

Name: EC2_SSH_PRIVATE_KEY
Value: [Content of ~/.ssh/secure-webapp-key - the PRIVATE key!]
```

**To get private key content:**
```bash
# Windows (PowerShell)
Get-Content ~/.ssh/secure-webapp-key | clip

# Linux/Mac
cat ~/.ssh/secure-webapp-key | pbcopy  # Mac
cat ~/.ssh/secure-webapp-key           # Linux (copy manually)
```

#### 6.3 Push Code to GitHub

```bash
# From project root
git remote add origin https://github.com/YOUR_USERNAME/secure-webapp-pipeline.git

# Update README with your info
# Edit README.md and replace:
# - [Your Name]
# - [Your LinkedIn]
# - [Your GitHub]

git add .
git commit -m "Initial commit: DevSecOps pipeline"
git push -u origin main
```

### Phase 7: First Deployment (10 minutes)

#### 7.1 Monitor Pipeline

```bash
# Go to your GitHub repo
# Click "Actions" tab
# Watch the pipeline run!

# Pipeline stages:
# 1. Security Scan
# 2. Build and Scan Docker Image
# 3. Deploy to AWS
# 4. Post-Deployment Tests
```

#### 7.2 Verify Deployment

**Windows (PowerShell):**
```powershell
# Test with PowerShell
Invoke-WebRequest -Uri http://<YOUR_EC2_IP>:5000 -UseBasicParsing
Invoke-WebRequest -Uri http://<YOUR_EC2_IP>:5000/health -UseBasicParsing
Invoke-WebRequest -Uri http://<YOUR_EC2_IP>:5000/api/tasks -UseBasicParsing

# Or use curl if available
curl http://<YOUR_EC2_IP>:5000
curl http://<YOUR_EC2_IP>:5000/health
curl http://<YOUR_EC2_IP>:5000/api/tasks
```

**Linux/Mac (Bash):**
```bash
# Test with curl
curl http://<YOUR_EC2_IP>:5000
curl http://<YOUR_EC2_IP>:5000/health
curl http://<YOUR_EC2_IP>:5000/api/tasks
```

**Or open in any browser:**
- Home: `http://<YOUR_EC2_IP>:5000`
- Health: `http://<YOUR_EC2_IP>:5000/health`
- Tasks API: `http://<YOUR_EC2_IP>:5000/api/tasks`

#### 7.3 SSH to EC2 Instance

**Windows (PowerShell):**
```powershell
# SSH to instance (replace <YOUR_EC2_IP> with actual IP from Terraform output)
ssh -i $env:USERPROFILE\.ssh\secure-webapp-key ec2-user@<YOUR_EC2_IP>

# Check running containers
docker ps

# Check application logs
docker logs webapp

# Exit SSH session
exit
```

**Linux/Mac (Bash):**
```bash
# SSH to instance (replace <YOUR_EC2_IP> with actual IP from Terraform output)
ssh -i ~/.ssh/secure-webapp-key ec2-user@<YOUR_EC2_IP>

# Check running containers
docker ps

# Check application logs
docker logs webapp

# Exit SSH session
exit
```

## 🎯 Success Checklist

- [ ] Application runs locally
- [ ] Terraform deployed infrastructure to AWS
- [ ] GitHub Actions pipeline runs successfully
- [ ] Application is accessible via EC2 public IP
- [ ] Can SSH to EC2 instance
- [ ] Security scans completed (check GitHub Actions artifacts)
- [ ] Monitoring stack works locally

## 🎓 Next Steps

### Enhance Your Project

1. **Add Tests**
   - Unit tests with pytest
   - Integration tests
   - Load testing with Locust

2. **Improve Security**
   - Enable AWS CloudTrail
   - Add WAF rules
   - Implement rate limiting

3. **Advanced Monitoring**
   - Deploy Prometheus to EC2
   - Custom Grafana dashboards
   - CloudWatch integration

4. **Multi-Environment**
   - Create staging environment
   - Implement blue-green deployment
   - Add canary deployments

### Portfolio Enhancement

1. **Document Everything**
   - Add architecture diagrams
   - Create demo video
   - Write blog post about your learnings

2. **LinkedIn Post Template**
```
🚀 Just completed a DevSecOps project!

Built a production-ready pipeline featuring:
✅ Infrastructure as Code (Terraform)
✅ Containerization (Docker)
✅ Automated CI/CD (GitHub Actions)
✅ Security scanning at every stage
✅ Monitoring with Prometheus & Grafana

Tech stack: Python, Flask, AWS, Docker, Terraform

This project demonstrates:
- Cloud infrastructure management
- DevOps automation
- Security-first development
- Container orchestration

Check it out: [GitHub link]

#DevOps #AWS #Docker #Terraform #CloudComputing
```

## 🐛 Troubleshooting

### Issue: Terraform apply fails

**Windows (PowerShell):**
```powershell
# Check AWS credentials
aws sts get-caller-identity

# Check Terraform syntax
terraform validate

# Enable detailed logging
$env:TF_LOG="DEBUG"
terraform apply
```

**Linux/Mac (Bash):**
```bash
# Check AWS credentials
aws sts get-caller-identity

# Check Terraform syntax
terraform validate

# Enable detailed logging
export TF_LOG=DEBUG
terraform apply
```

### Issue: GitHub Actions fails

```bash
# Verify all secrets are set correctly
# GitHub repo → Settings → Secrets

# Check pipeline logs in Actions tab

# Common issues:
# - Wrong Docker Hub credentials
# - Invalid AWS credentials
# - Missing EC2_SSH_PRIVATE_KEY
```

### Issue: Can't access application

```bash
# Check security group
# AWS Console → EC2 → Security Groups
# Ensure port 5000 is open
```

**Windows (PowerShell):**
```powershell
# Check if container is running
ssh -i $env:USERPROFILE\.ssh\secure-webapp-key ec2-user@<EC2_IP>
docker ps

# Check application logs
docker logs webapp
```

**Linux/Mac (Bash):**
```bash
# Check if container is running
ssh -i ~/.ssh/secure-webapp-key ec2-user@<EC2_IP>
docker ps

# Check application logs
docker logs webapp
```

## 💰 Cost Management

**Expected Monthly Costs (Free Tier):**
- EC2 t2.micro: $0 (750 hours/month free)
- EBS 20GB: $0 (30GB free)
- Data Transfer: ~$0 (1GB free)

**After Free Tier:**
- EC2 t2.micro: ~$8.50/month
- EBS 20GB: ~$2/month
- Total: ~$10.50/month

**To Minimize Costs:**
```bash
# Stop EC2 when not needed
aws ec2 stop-instances --instance-ids <INSTANCE_ID>

# Destroy everything when done
cd terraform
terraform destroy
```

## 🎉 Congratulations!

You now have a production-ready DevSecOps pipeline!

Use this project to:
- Demonstrate your skills in interviews
- Build upon for more complex projects
- Learn best practices in DevOps

## 📚 Additional Resources

- [AWS Free Tier](https://aws.amazon.com/free/)
- [Docker Tutorial](https://docs.docker.com/get-started/)
- [Terraform Tutorial](https://learn.hashicorp.com/terraform)
- [GitHub Actions Docs](https://docs.github.com/en/actions)

---

**Need Help?**
- Check [RUNBOOK.md](RUNBOOK.md) for operational procedures
- Open an issue on GitHub
- Review GitHub Actions logs

**Happy DevOps-ing! 🚀**
