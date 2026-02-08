# Quick Reference - HTTPS Setup

## Quick Links
- **Full Setup Guide:** [HTTPS_SETUP.md](HTTPS_SETUP.md)
- **Main Setup Guide:** [SETUP.md](SETUP.md)
- **Runbook:** [RUNBOOK.md](RUNBOOK.md)

## Current vs New Architecture

### Before (HTTP Only)
```
GitHub → Docker Hub → EC2 → Docker Container (port 5000)
                                    ↓
                              Flask App (HTTP)
```

### After (HTTPS)
```
GitHub → Docker Hub → EC2 → Docker Compose
                              ├── Nginx (ports 80, 443) → HTTPS
                              ├── Flask App (port 5000) → Backend
                              └── Certbot → SSL Certs
```

## What Changed

### New Files Created
- `app/templates/index.html` - Bootstrap dashboard UI
- `app/static/css/style.css` - Custom styling
- `app/static/js/app.js` - Frontend JavaScript
- `nginx/nginx.conf` - Nginx reverse proxy config
- `docker-compose.prod.yml` - Production compose file
- `scripts/init-letsencrypt.sh` - SSL setup script
- `scripts/renew-certs.sh` - SSL renewal script
- `HTTPS_SETUP.md` - Complete HTTPS guide
- `.env.production` - Environment template

### Modified Files
- `app/app.py` - Added template serving, CORS support
- `app/requirements.txt` - Added Flask-CORS
- `app/Dockerfile` - Copy static/templates directories
- `terraform/variables.tf` - Added domain variables
- `terraform/main.tf` - Added Route 53 resources
- `terraform/outputs.tf` - Added domain outputs
- `terraform/terraform.tfvars.example` - Added domain config
- `.github/workflows/deploy.yml` - Updated for docker-compose
- `README.md` - Updated features and tech stack

## Prerequisites

✅ Already Completed (from main SETUP.md):
- AWS account with credits
- EC2 instance running
- Docker Hub account
- GitHub repository
- CI/CD pipeline working

❌ New Requirements:
- **Domain name** (~$12/year via Route 53)
- **Valid email** (for Let's Encrypt)
- **Patience** (DNS propagation: 5-60 minutes)

## Deployment Steps (TL;DR)

### 1. Register Domain (15 mins)
```
AWS Console → Route 53 → Register Domain → yourname-devops.com
```

### 2. Update Terraform (5 mins)
```bash
# Edit terraform/terraform.tfvars
domain_name = "yourname-devops.com"
create_dns_record = true

# Apply
cd terraform && terraform apply
```

### 3. Setup SSL (20 mins)
```bash
# SSH to EC2
ssh -i ~/.ssh/secure-webapp-key ec2-user@<EC2-IP>

# Run SSL setup
bash ~/scripts/init-letsencrypt.sh yourname-devops.com your@email.com

# Start services
docker-compose -f docker-compose.prod.yml up -d
```

### 4. Test (5 mins)
```
Browser: https://yourname-devops.com
Verify: Padlock icon, Bootstrap dashboard
Test: Add/edit/delete tasks
```

## Costs

| Item | Monthly | Annual |
|------|---------|--------|
| Domain (.com) | ~$1 | $12 |
| EC2 t3.micro | $7-8 | $90-96 |
| SSL Certificate | $0 | $0 (Let's Encrypt) |
| **Total** | **~$8-9** | **~$102-108** |

**With $100 AWS credits:** First year is basically free!

## Common Commands

### Check SSL Certificate
```bash
curl -I https://your-domain.com
```

### Renew SSL Certificate
```bash
docker-compose -f docker-compose.prod.yml run --rm certbot renew
docker-compose -f docker-compose.prod.yml exec nginx nginx -s reload
```

### View Logs
```bash
# All services
docker-compose -f docker-compose.prod.yml logs -f

# Nginx only
docker-compose -f docker-compose.prod.yml logs -f nginx

# Webapp only
docker-compose -f docker-compose.prod.yml logs -f webapp
```

### Restart Services
```bash
docker-compose -f docker-compose.prod.yml restart
```

### Stop Services
```bash
docker-compose -f docker-compose.prod.yml down
```

## Troubleshooting

### DNS not working?
```bash
# Check propagation
nslookup your-domain.com

# Wait 5-60 minutes for DNS propagation
```

### SSL certificate failed?
```bash
# Check certbot logs
docker logs certbot

# Try staging first (for testing)
bash ~/scripts/init-letsencrypt.sh domain.com email@example.com 1
```

### HTTPS not working?
```bash
# Check nginx logs
docker-compose logs nginx

# Verify domain in nginx config
grep your-domain ~/nginx/nginx.conf
```

### Port 443 timeout?
```bash
# Check AWS security group
# Ensure port 443 is open (already should be from terraform)
```

## Next Steps

1. **Test Everything**
   - HTTPS URL works
   - Dashboard loads
   - Tasks CRUD operations
   - SSL Labs test (A+ rating)

2. **Update Portfolio**
   - Add screenshots
   - Update LinkedIn
   - Share on GitHub

3. **Optional Enhancements**
   - Enable HSTS header
   - Add monitoring alerts
   - Setup staging environment

## Support

- 📖 Full Guide: [HTTPS_SETUP.md](HTTPS_SETUP.md)
- 🐛 Issues: Check logs first
- 📧 Let's Encrypt Help: https://community.letsencrypt.org/
- 🔧 Nginx Help: http://nginx.org/en/docs/

---

**Remember:** SSL certificates auto-renew every 90 days via cron job!

**Status Page:** Check https://letsencrypt.status.io/ if having issues
