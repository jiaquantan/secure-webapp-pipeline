# 🌐 Secure 3-Tier Web Application Pipeline

A production-ready DevSecOps project demonstrating automated deployment of a containerized Flask application to AWS using Infrastructure as Code, CI/CD pipelines, and comprehensive security scanning.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Python](https://img.shields.io/badge/python-3.11-blue.svg)
![Terraform](https://img.shields.io/badge/terraform-1.6+-purple.svg)
![Docker](https://img.shields.io/badge/docker-latest-blue.svg)
![HTTPS](https://img.shields.io/badge/HTTPS-Cloudflare-orange.svg)
![Build Status](https://github.com/jiaquantan/secure-webapp-pipeline/actions/workflows/deploy.yml/badge.svg?branch=main)

## 📋 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Project Structure](#-project-structure)
- [Deployment Guide](#-deployment-guide)
- [Monitoring](#-monitoring)
- [Security](#-security)
- [Troubleshooting](#-troubleshooting)
- [Learning Outcomes](#-learning-outcomes)
- [Interview Talking Points](#-interview-talking-points)

## 🔎 Overview

This project showcases a complete DevSecOps workflow including:
- **Interactive web application** with Bootstrap 5 dashboard UI and REST API
- **HTTPS encryption** with Cloudflare SSL (free tier)
- **Nginx reverse proxy** for security and performance
- **Infrastructure as Code** using Terraform for AWS provisioning
- **Custom domain** with Cloudflare DNS and CDN
- **Automated CI/CD pipeline** with GitHub Actions
- **Security scanning** at every stage (Trivy, Bandit, Safety)
- **Monitoring stack** with Prometheus and Grafana
- **Docker Compose** orchestration for production deployment

Perfect for demonstrating DevOps capabilities in job interviews and building production-ready applications.

**Live Demo:** https://jqtech.dpdns.org

## 🏛️ Architecture

```
┌─────────────┐      ┌──────────────────┐      ┌─────────────┐
│   GitHub    │─────▶│  GitHub Actions  │─────▶│     AWS     │
│ Repository  │      │    CI/CD Pipeline │      │   EC2/VPC   │
└─────────────┘      └──────────────────┘      └─────────────┘
                              │
                              ▼
                     ┌────────────────┐
                     │ Security Scans │
                     │ • Trivy        │
                     │ • Bandit       │
                     │ • Safety       │
                     └────────────────┘
```

### Traffic Flow
```
User ──▶ Cloudflare CDN ──▶ AWS VPC ──▶ EC2 (t3.micro) ──▶ Nginx ──▶ Docker Compose ──▶ Flask App
         (SSL/DDoS)                           │                        (webapp container)
                                              ▼
                                       Prometheus/Grafana
                                         (Monitoring)
```

## ✨ Features

### Application
- ✅ **Interactive Bootstrap 5 dashboard** with modern, responsive design
- ✅ **Real-time task management** with add, edit, delete, and complete operations
- ✅ **Clickable status toggles** for one-click task completion
- ✅ **Live statistics** showing total, completed, and pending tasks
- ✅ **Accurate timestamps** with timezone support
- ✅ REST API with full CRUD operations and JSON responses
- ✅ Health check endpoints for monitoring
- ✅ Multi-stage Docker builds for optimization
- ✅ Non-root container security

### Security & HTTPS
- ✅ **Cloudflare SSL/TLS encryption** with free universal SSL
- ✅ **Cloudflare CDN** with global edge network and DDoS protection
- ✅ **Nginx reverse proxy** with security headers
- ✅ **Vulnerability scanning** with Trivy (container images)
- ✅ **Code security analysis** with Bandit (Python SAST)
- ✅ **Dependency checking** with Safety (CVE detection)
- ✅ Secrets management with GitHub Secrets
- ✅ IMDSv2 enforcement on EC2
- ✅ Encrypted EBS volumes

### Infrastructure
- ✅ **Custom domain** with HTTPS (jqtech.dpdns.org)
- ✅ **Cloudflare DNS** with proxy and caching
- ✅ VPC with public/private subnets
- ✅ Security groups with minimal access
- ✅ Encrypted EBS volumes (30GB gp3)
- ✅ IAM roles with least privilege
- ✅ Elastic IP for stable addressing
- ✅ Reusable Terraform modules

### CI/CD Pipeline
- ✅ Automated testing and linting
- ✅ Security scanning (SAST, container scanning)
- ✅ Automated Docker builds and pushes
- ✅ **Docker Compose orchestration**
- ✅ Zero-downtime deployments
- ✅ Rollback capabilities
- ✅ Post-deployment smoke tests

### Monitoring & Observability
- ✅ Prometheus metrics collection
- ✅ Grafana dashboards
- ✅ Container metrics with cAdvisor
- ✅ System metrics with Node Exporter
- ✅ Application health checks

## 🛠️ Tech Stack

| Category | Technologies |
|----------|-------------|
| **Application** | Python 3.11, Flask, Gunicorn (single-worker mode) |
| **Frontend** | Bootstrap 5.3, JavaScript ES6, Bootstrap Icons |
| **Containerization** | Docker (multi-stage builds), Docker Compose |
| **Reverse Proxy** | Nginx 1.25 (Alpine) |
| **SSL/TLS** | Cloudflare Universal SSL (free tier) |
| **CDN** | Cloudflare (global edge network) |
| **Infrastructure** | Terraform 1.6+, AWS (VPC, EC2 t3.micro, IAM, EBS) |
| **CI/CD** | GitHub Actions (5-stage pipeline) |
| **Security** | Trivy, Bandit, Safety, Flake8 |
| **Monitoring** | Prometheus, Grafana, cAdvisor, Node Exporter |
| **Version Control** | Git, GitHub (main branch) |

## ⚠️ Prerequisites ⚠️

Before you begin, ensure you have:

- **AWS Account** with appropriate permissions
- **GitHub Account** for repository and Actions
- **Docker** installed locally (for testing)
- **Terraform** >= 1.0
- **AWS CLI** configured with credentials
- **SSH Key Pair** for EC2 access

### Required Tools Installation

```bash
# Install Terraform (Windows)
choco install terraform

# Install AWS CLI (Windows)
choco install awscli

# Install Docker Desktop (Windows)
# Download from: https://www.docker.com/products/docker-desktop

# Verify installations
terraform --version
aws --version
docker --version
```

## ❯❯❯❯ Quick Start ❯❯❯❯

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/secure-webapp-pipeline.git
cd secure-webapp-pipeline
```

### 2. Local Development

```bash
# Test the application locally
cd app
docker build -t secure-webapp:local .
docker run -p 5000:5000 secure-webapp:local

# Visit http://localhost:5000
```

### 3. Run Monitoring Stack

```bash
# Start Prometheus and Grafana
docker-compose -f docker-compose.monitoring.yml up -d

# Access Grafana: http://localhost:3000 (admin/admin)
# Access Prometheus: http://localhost:9090
```

### 4. Test Security Scanning

```bash
# Install Trivy
choco install trivy

# Scan Docker image
docker build -t secure-webapp:test app/
trivy image secure-webapp:test
```

## 📁 Project Structure

```
secure-webapp-pipeline/
├── app/
│   ├── app.py                    # Flask application
│   ├── Dockerfile               # Multi-stage Docker build
│   ├── requirements.txt         # Python dependencies
│   └── .dockerignore           # Docker ignore rules
│
├── terraform/
│   ├── main.tf                  # Main infrastructure config
│   ├── variables.tf             # Input variables
│   ├── outputs.tf               # Output values
│   ├── user-data.sh            # EC2 initialization script
│   └── terraform.tfvars.example # Example variables
│
├── .github/
│   └── workflows/
│       └── deploy.yml           # CI/CD pipeline
│
├── monitoring/
│   ├── prometheus.yml           # Prometheus config
│   └── grafana-datasources.yml # Grafana data sources
│
├── docker-compose.yml           # Local development
├── docker-compose.monitoring.yml # Monitoring stack
├── README.md                    # This file
└── RUNBOOK.md                   # Operations guide
```

## 📖 Deployment Guide

### Step 1: Configure AWS

```bash
# Configure AWS credentials
aws configure

# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -f ~/.ssh/secure-webapp-key
```

### Step 2: Setup Terraform

```bash
cd terraform

# Copy and edit variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values:
# - ssh_public_key: paste content of ~/.ssh/secure-webapp-key.pub
# - ssh_cidr_blocks: your IP address (for security)

# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply infrastructure
terraform apply
```

### Step 3: Configure GitHub Secrets

Go to your GitHub repository → Settings → Secrets and add:

```
AWS_ACCESS_KEY_ID          # Your AWS access key
AWS_SECRET_ACCESS_KEY      # Your AWS secret key
DOCKERHUB_USERNAME         # Your Docker Hub username
DOCKERHUB_TOKEN            # Docker Hub access token
EC2_SSH_PRIVATE_KEY        # Content of ~/.ssh/secure-webapp-key (private key)
```

### Step 4: Deploy Application

```bash
# Push to main branch to trigger deployment
git add .
git commit -m "Initial deployment"
git push origin main

# GitHub Actions will:
# 1. Run security scans
# 2. Build Docker image
# 3. Scan container
# 4. Deploy to AWS
# 5. Run smoke tests
```

### Step 5: Verify Deployment

```bash
# Get EC2 IP from Terraform outputs
cd terraform
terraform output instance_public_ip

# Test application
curl http://<EC2_IP>:5000
curl http://<EC2_IP>:5000/health
curl http://<EC2_IP>:5000/api/tasks
```

## 👀 Monitoring 👀

### Access Monitoring Tools

**Prometheus:**
- URL: `http://<EC2_IP>:9090`
- View metrics, targets, and alerts

**Grafana:**
- URL: `http://<EC2_IP>:3000`
- Default credentials: admin/admin
- Pre-configured dashboards for container and system metrics

### Key Metrics to Monitor

- **Application Health**: `/health` endpoint status
- **Container Metrics**: CPU, memory, network usage
- **System Metrics**: Disk, load average, processes
- **Request Metrics**: Response times, error rates

## 🔒 Security

### Security Measures Implemented

1. **Container Security**
   - Non-root user execution
   - Multi-stage builds
   - Minimal base images (Alpine)
   - No secrets in images

2. **Infrastructure Security**
   - Encrypted EBS volumes
   - IMDSv2 enforcement
   - Security groups with minimal access
   - IAM roles with least privilege

3. **Pipeline Security**
   - Automated vulnerability scanning
   - Code security analysis
   - Dependency checking
   - Container image scanning

4. **Secrets Management**
   - AWS Secrets Manager integration
   - No hardcoded credentials
   - GitHub Secrets for CI/CD

### Security Scanning Results

Every deployment includes:
- **Trivy**: Container vulnerability scanning
- **Bandit**: Python code security analysis
- **Safety**: Python dependency checking
- **Flake8**: Code quality and style

## 🔧 Troubleshooting

See [RUNBOOK.md](RUNBOOK.md) for detailed troubleshooting guides including:
- Pipeline failures
- Deployment issues
- Container problems
- Network connectivity
- Monitoring issues

## 🎓 Learning Outcomes

This project demonstrates:

✅ **DevOps Skills**
- Infrastructure as Code with Terraform
- Container orchestration with Docker
- CI/CD pipeline automation
- Monitoring and observability

✅ **Security Skills**
- DevSecOps practices
- Vulnerability scanning
- Secrets management
- Secure infrastructure design

✅ **Cloud Skills**
- AWS VPC networking
- EC2 instance management
- IAM policies and roles
- Cloud security best practices

## 📝 Interview Talking Points

When presenting this project:

1. **"I built a fully automated DevSecOps pipeline..."**
   - Emphasize automation and security integration

2. **"Used Terraform to provision AWS infrastructure..."**
   - Mention reusable modules and environment management

3. **"Implemented security scanning at every stage..."**
   - Discuss Trivy, Bandit, and shift-left security

4. **"Set up comprehensive monitoring..."**
   - Talk about Prometheus, Grafana, and observability

5. **"Followed security best practices..."**
   - Highlight IAM, encryption, non-root containers

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest features
- Submit pull requests

## 📄 License

This project is open source and available under the MIT License.

## 🙏 Acknowledgments

Built as a portfolio project to demonstrate DevOps and Cloud Engineering skills for job applications.

---

**Author**: [Your Name]  
**LinkedIn**: [Your LinkedIn]  
**GitHub**: [Your GitHub]  
**Portfolio**: [Your Portfolio]

---

### 📞 Support

For questions or issues:
- Open an issue in this repository
- Contact via LinkedIn

**Happy DevOps-ing! 👨‍💻**
