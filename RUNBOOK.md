# 📚 Operations Runbook

## Table of Contents

- [Overview](#overview)
- [Emergency Contacts](#emergency-contacts)
- [Common Operations](#common-operations)
- [Incident Response](#incident-response)
- [Troubleshooting Guide](#troubleshooting-guide)
- [Rollback Procedures](#rollback-procedures)
- [Maintenance Procedures](#maintenance-procedures)
- [Monitoring & Alerts](#monitoring--alerts)

## Overview

This runbook provides operational procedures for the Secure Web Application Pipeline. Use this guide for day-to-day operations, troubleshooting, and incident response.

**Last Updated**: February 2026  
**Application**: Secure Web App Pipeline  
**Environment**: Production  

## Emergency Contacts

| Role | Contact | Availability |
|------|---------|-------------|
| On-Call Engineer | [Your Name/Email] | 24/7 |
| AWS Support | AWS Console | 24/7 |
| Team Lead | [Name/Email] | Business Hours |

## Common Operations

### 1. Deploying a New Version

**Normal Deployment (via GitHub Actions)**

```bash
# 1. Commit and push changes
git add .
git commit -m "feat: your feature description"
git push origin main

# 2. Monitor pipeline
# Visit: https://github.com/YOUR_USERNAME/secure-webapp-pipeline/actions

# 3. Verify deployment
curl http://<EC2_IP>:5000/health
```

**Manual Deployment (Emergency)**

```bash
# 1. SSH to EC2 instance
ssh -i ~/.ssh/secure-webapp-key ec2-user@<EC2_IP>

# 2. Pull latest image
docker pull YOUR_DOCKERHUB_USERNAME/secure-webapp:latest

# 3. Stop current container
docker stop webapp
docker rm webapp

# 4. Start new container
docker run -d \
  --name webapp \
  -p 5000:5000 \
  --restart unless-stopped \
  -e ENVIRONMENT=production \
  YOUR_DOCKERHUB_USERNAME/secure-webapp:latest

# 5. Verify
curl http://localhost:5000/health
```

**Expected Time**: 5-10 minutes  
**Impact**: ~30 seconds downtime

### 2. Checking Application Health

```bash
# Health check endpoint
curl http://<EC2_IP>:5000/health

# Expected response:
# {
#   "status": "healthy",
#   "version": "1.0.0",
#   "timestamp": "2026-02-07T..."
# }

# Check application logs
ssh -i ~/.ssh/secure-webapp-key ec2-user@<EC2_IP>
docker logs webapp --tail 100 -f

# Check container status
docker ps -a | grep webapp
```

### 3. Accessing Logs

**Application Logs**
```bash
# Real-time logs
ssh -i ~/.ssh/secure-webapp-key ec2-user@<EC2_IP>
docker logs -f webapp

# Last 100 lines
docker logs webapp --tail 100

# Logs with timestamps
docker logs webapp --timestamps
```

**System Logs**
```bash
# SSH to EC2
ssh -i ~/.ssh/secure-webapp-key ec2-user@<EC2_IP>

# System logs
sudo journalctl -u webapp.service -f

# Docker daemon logs
sudo journalctl -u docker -f
```

### 4. Scaling Infrastructure

**Vertical Scaling (Change Instance Type)**

```bash
cd terraform

# Edit terraform.tfvars
# Change: instance_type = "t2.small"

# Apply changes
terraform plan
terraform apply

# Note: Requires instance restart (~5 min downtime)
```

**Horizontal Scaling (Add Load Balancer)**
- See [Advanced Setup Guide](docs/advanced-setup.md)

## Incident Response

### Severity Levels

| Level | Description | Response Time | Example |
|-------|-------------|---------------|---------|
| P0 | Critical - Service down | Immediate | Website unreachable |
| P1 | High - Major degradation | 15 minutes | Slow response times |
| P2 | Medium - Partial impact | 1 hour | Single feature broken |
| P3 | Low - Minor issue | Next business day | Cosmetic issue |

### Incident Response Workflow

```
1. Detect → 2. Acknowledge → 3. Investigate → 4. Mitigate → 5. Resolve → 6. Post-Mortem
```

### P0: Service Completely Down

**Symptoms**
- Health check endpoint not responding
- All requests timing out
- Monitoring alerts firing

**Immediate Actions**

```bash
# 1. Check EC2 instance status
aws ec2 describe-instance-status --instance-ids <INSTANCE_ID>

# 2. Check if container is running
ssh -i ~/.ssh/secure-webapp-key ec2-user@<EC2_IP>
docker ps -a | grep webapp

# 3. If container is stopped, restart it
docker start webapp

# 4. If container keeps crashing, check logs
docker logs webapp --tail 50

# 5. If instance is down, restart it
aws ec2 reboot-instances --instance-ids <INSTANCE_ID>
```

**Escalation Path**
1. Attempt restart (5 min)
2. Rollback to last known good version (10 min)
3. Contact AWS Support
4. Notify stakeholders

## Troubleshooting Guide

### Problem: Pipeline Fails on Security Scan

**Symptoms**
- GitHub Actions workflow fails at security-scan job
- Trivy or Bandit reports critical vulnerabilities

**Solution**

```bash
# 1. Review security scan results
# Download artifacts from GitHub Actions

# 2. Check Trivy results
cat trivy-results.json | jq '.Results[].Vulnerabilities[] | select(.Severity=="CRITICAL")'

# 3. Update vulnerable dependencies
cd app
pip install --upgrade <package-name>
pip freeze > requirements.txt

# 4. Re-run pipeline
git add requirements.txt
git commit -m "fix: update vulnerable dependencies"
git push
```

**Prevention**
- Run `safety check` locally before committing
- Keep dependencies updated regularly

### Problem: Docker Build Fails

**Symptoms**
- Pipeline fails at "Build Docker image" step
- Local docker build fails

**Solution**

```bash
# 1. Build locally to see full error
cd app
docker build -t test .

# 2. Common issues:

# Issue: Base image not found
# Fix: Check internet connection, verify image name in Dockerfile

# Issue: Dependency installation fails
# Fix: Update requirements.txt, check Python version compatibility

# Issue: COPY command fails
# Fix: Verify file paths, check .dockerignore

# 3. Test with verbose output
docker build -t test . --progress=plain --no-cache
```

### Problem: Application Not Responding

**Symptoms**
- Health check fails
- Connection timeout errors
- Container is running but not responding

**Solution**

```bash
# 1. Check if port is listening
ssh -i ~/.ssh/secure-webapp-key ec2-user@<EC2_IP>
netstat -tuln | grep 5000

# 2. Check container logs for errors
docker logs webapp --tail 100

# 3. Check security group rules
aws ec2 describe-security-groups \
  --group-ids <SECURITY_GROUP_ID> \
  --query 'SecurityGroups[0].IpPermissions'

# 4. Test locally on EC2
curl http://localhost:5000/health

# 5. If local works but external doesn't, check firewall
sudo iptables -L -n
```

**Common Causes**
- Security group not allowing inbound traffic on port 5000
- Application crashed (check logs)
- Port already in use
- Incorrect environment variables

### Problem: Terraform Apply Fails

**Symptoms**
- `terraform apply` errors out
- Resource conflicts or permission denied

**Solution**

```bash
# 1. Check Terraform state
terraform show

# 2. Refresh state
terraform refresh

# 3. Common errors:

# Error: VPC already exists
# Solution: Import existing resource
terraform import aws_vpc.main <VPC_ID>

# Error: Permission denied
# Solution: Check AWS credentials, verify IAM permissions
aws sts get-caller-identity

# Error: Resource limit exceeded
# Solution: Request limit increase in AWS Console

# 4. Force unlock if state is locked
terraform force-unlock <LOCK_ID>

# 5. Nuclear option - destroy and recreate
terraform destroy
terraform apply
```

### Problem: High Memory Usage

**Symptoms**
- Container constantly restarting
- Out of memory errors in logs
- Monitoring shows high memory usage

**Solution**

```bash
# 1. Check current memory usage
docker stats webapp --no-stream

# 2. Set memory limits
docker run -d \
  --name webapp \
  -p 5000:5000 \
  --memory="512m" \
  --memory-swap="1g" \
  YOUR_IMAGE

# 3. Investigate memory leaks
# Review application code for:
# - Unclosed database connections
# - Large data structures in memory
# - Infinite loops

# 4. Scale instance type (temporary fix)
# Edit terraform.tfvars: instance_type = "t2.small"
# Run: terraform apply
```

### Problem: Cannot SSH to EC2

**Symptoms**
- Connection timeout when SSH
- Permission denied errors

**Solution**

```bash
# 1. Verify instance is running
aws ec2 describe-instances --instance-ids <INSTANCE_ID>

# 2. Check security group allows SSH from your IP
aws ec2 describe-security-groups --group-ids <SG_ID>

# 3. Verify SSH key permissions
chmod 600 ~/.ssh/secure-webapp-key

# 4. Use correct username
ssh -i ~/.ssh/secure-webapp-key ec2-user@<EC2_IP>

# 5. Try EC2 Instance Connect (web-based SSH)
# AWS Console → EC2 → Connect → EC2 Instance Connect

# 6. Check system logs via AWS Console
# EC2 → Instances → Actions → Monitor and troubleshoot → Get system log
```

## Rollback Procedures

### Quick Rollback to Previous Version

```bash
# 1. SSH to EC2
ssh -i ~/.ssh/secure-webapp-key ec2-user@<EC2_IP>

# 2. Find previous image version
docker images | grep secure-webapp

# 3. Stop current container
docker stop webapp
docker rm webapp

# 4. Start previous version (replace SHA with actual commit SHA)
docker run -d \
  --name webapp \
  -p 5000:5000 \
  --restart unless-stopped \
  -e ENVIRONMENT=production \
  YOUR_DOCKERHUB_USERNAME/secure-webapp:<PREVIOUS_SHA>

# 5. Verify rollback
curl http://localhost:5000/health
```

**Expected Time**: 2-3 minutes

### Rollback Infrastructure Changes

```bash
cd terraform

# 1. Checkout previous working version
git log --oneline terraform/
git checkout <COMMIT_SHA> terraform/

# 2. Apply previous configuration
terraform plan
terraform apply

# 3. Return to current branch
git checkout main
```

## Maintenance Procedures

### Weekly Maintenance Checklist

- [ ] Review monitoring dashboards
- [ ] Check for security updates
- [ ] Review application logs for errors
- [ ] Verify backup procedures (if implemented)
- [ ] Update dependencies
- [ ] Review AWS costs

### Monthly Maintenance Checklist

- [ ] Patch EC2 instances
- [ ] Rotate secrets
- [ ] Review IAM permissions
- [ ] Update documentation
- [ ] Disaster recovery drill
- [ ] Performance review

### Updating Dependencies

```bash
# 1. Update Python packages
cd app
pip list --outdated
pip install --upgrade <package-name>
pip freeze > requirements.txt

# 2. Test locally
docker build -t test .
docker run -p 5000:5000 test

# 3. Run security scan
trivy image test

# 4. Commit and deploy
git add requirements.txt
git commit -m "chore: update dependencies"
git push
```

### Patching EC2 Instance

```bash
# 1. SSH to instance
ssh -i ~/.ssh/secure-webapp-key ec2-user@<EC2_IP>

# 2. Update system packages
sudo yum update -y

# 3. Check if reboot required
sudo needs-restarting -r

# 4. If reboot needed, schedule maintenance window
sudo reboot

# 5. Wait 2-3 minutes and verify
curl http://<EC2_IP>:5000/health
```

## Monitoring & Alerts

### Key Metrics to Watch

| Metric | Warning | Critical | Action |
|--------|---------|----------|--------|
| CPU Usage | >70% | >90% | Scale up instance |
| Memory Usage | >75% | >90% | Investigate leaks |
| Disk Usage | >80% | >95% | Clean logs, increase volume |
| Response Time | >2s | >5s | Check application |
| Error Rate | >5% | >10% | Check logs, rollback |

### Accessing Monitoring

**Prometheus**
```
URL: http://<EC2_IP>:9090
Queries:
- CPU: rate(container_cpu_usage_seconds_total[5m])
- Memory: container_memory_usage_bytes
- Requests: flask_http_request_total
```

**Grafana**
```
URL: http://<EC2_IP>:3000
Username: admin
Password: admin (change on first login)
```

### Setting Up Alerts

```yaml
# Add to monitoring/prometheus.yml
alerting:
  alertmanagers:
    - static_configs:
        - targets: ['localhost:9093']

rule_files:
  - 'alerts.yml'

# Create monitoring/alerts.yml
groups:
  - name: application
    rules:
      - alert: HighErrorRate
        expr: rate(flask_http_request_total{status=~"5.."}[5m]) > 0.05
        for: 5m
        annotations:
          summary: "High error rate detected"
```

## Post-Incident Procedures

### Post-Mortem Template

```markdown
# Incident Post-Mortem

**Date**: [Date]
**Severity**: [P0/P1/P2/P3]
**Duration**: [Start - End time]
**Impact**: [What was affected]

## Timeline
- [Time]: Incident detected
- [Time]: Initial response began
- [Time]: Root cause identified
- [Time]: Fix applied
- [Time]: Incident resolved

## Root Cause
[Detailed explanation]

## Resolution
[What was done to fix it]

## Action Items
- [ ] [Preventive measure 1]
- [ ] [Preventive measure 2]
- [ ] [Documentation update]

## Lessons Learned
[Key takeaways]
```

## Additional Resources

- [AWS Documentation](https://docs.aws.amazon.com/)
- [Docker Documentation](https://docs.docker.com/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [Flask Documentation](https://flask.palletsprojects.com/)

---

**Remember**: When in doubt, don't guess. Check logs, monitor metrics, and document everything!

**Questions?** Contact the team lead or create an issue in the GitHub repository.
