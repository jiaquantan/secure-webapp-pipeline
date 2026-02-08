# HTTPS and Custom Domain Setup Guide

This guide walks you through setting up HTTPS with Let's Encrypt SSL certificates and a custom domain name for your Secure Web App.

## Overview

After completing this guide, you will have:
- ✅ Custom domain name (e.g., `yourapp.com`)
- ✅ HTTPS/SSL encryption with Let's Encrypt
- ✅ Professional Bootstrap dashboard UI
- ✅ Automatic SSL certificate renewal
- ✅ Nginx reverse proxy with security headers

## Prerequisites

Before starting, ensure you have completed:
- [x] Main SETUP.md through Phase 7 (application deployed to AWS)
- [x] AWS account with billing enabled
- [x] Credit card for domain purchase (~$12/year)

---

## Phase 1: Register Domain with Route 53 (15 minutes)

### 1.1 Navigate to Route 53

1. Login to AWS Console: https://console.aws.amazon.com/
2. Search for "Route 53" in the services search bar
3. Click "Route 53" to open the dashboard

### 1.2 Register a Domain

1. Click **"Register domain"** in the left sidebar
2. Enter your desired domain name (e.g., `yourname-devops.com`)
3. Click **"Check"** to see if it's available
4. If available, click **"Add to cart"**
5. Click **"Continue"**

### 1.3 Complete Registration

1. Fill in contact information (required by ICANN)
2. Enable/disable privacy protection (recommended: keep enabled)
3. Review and accept terms
4. Click **"Complete purchase"**
5. Verify your email address (check spam folder)

**Wait time:** 10-30 minutes for domain activation

**Cost:** $12-15/year (depends on TLD - .com, .net, .io, etc.)

### 1.4 Verify Hosted Zone

After domain registration:
1. Go to Route 53 → **Hosted zones**
2. You should see your domain listed
3. Note the **Name servers** (4 NS records)

---

## Phase 2: Update Terraform Configuration (10 minutes)

### 2.1 Update terraform.tfvars

Edit `terraform/terraform.tfvars`:

```hcl
# Add these lines at the end:
domain_name        = "your-domain.com"  # Replace with your actual domain
create_dns_record  = true
```

### 2.2 Apply Terraform Changes

```bash
cd terraform

# Review changes
terraform plan

# Apply changes (creates DNS A records)
terraform apply

# Type 'yes' when prompted
```

### 2.3 Verify DNS Records

```bash
# Get outputs
terraform output

# You should see:
# domain_name = "your-domain.com"
# https_url = "https://your-domain.com"
# dns_records = {
#   main = "your-domain.com -> <EC2-IP>"
#   www = "www.your-domain.com -> <EC2-IP>"
# }
```

### 2.4 Test DNS Propagation

**Windows (PowerShell):**
```powershell
nslookup your-domain.com
```

**Linux/Mac (Bash):**
```bash
dig your-domain.com
```

**Expected result:** Should return your EC2 Elastic IP

**Wait time:** DNS propagation can take 5-60 minutes

---

## Phase 3: Setup Let's Encrypt SSL (20 minutes)

### 3.1 SSH to EC2 Instance

```bash
ssh -i ~/.ssh/secure-webapp-key ec2-user@your-domain.com
```

Or use IP if DNS not propagated yet:
```bash
ssh -i ~/.ssh/secure-webapp-key ec2-user@<EC2-IP>
```

### 3.2 Verify Required Files

```bash
# Check if deployment files exist
ls -la ~/

# You should see:
# - docker-compose.prod.yml
# - nginx/ (directory)
# - scripts/ (directory)
```

### 3.3 Run SSL Initialization Script

```bash
# Make script executable
chmod +x ~/scripts/init-letsencrypt.sh

# Run the script (replace with your domain and email)
bash ~/scripts/init-letsencrypt.sh your-domain.com your-email@example.com

# Example:
# bash ~/scripts/init-letsencrypt.sh johndevops.com john@gmail.com
```

**The script will:**
1. Create necessary directories
2. Download recommended TLS parameters
3. Update nginx config with your domain
4. Request SSL certificate from Let's Encrypt
5. Verify certificate installation

### 3.4 Verify SSL Certificate

```bash
# Check certificate files
ls -la ~/certbot/conf/live/your-domain.com/

# Should show:
# - cert.pem
# - chain.pem
# - fullchain.pem
# - privkey.pem
```

---

## Phase 4: Deploy with HTTPS (10 minutes)

### 4.1 Start Services with Docker Compose

```bash
# From EC2 instance (still SSH'd in)
cd ~/

# Set environment variables
export DOCKERHUB_USERNAME=your-dockerhub-username
export APP_VERSION=1.0.0

# Start all services (webapp, nginx, certbot)
docker-compose -f docker-compose.prod.yml up -d

# Check status
docker-compose -f docker-compose.prod.yml ps
```

**Expected output:**
```
NAME      IMAGE                          STATUS         PORTS
certbot   certbot/certbot:latest         Up (healthy)   
nginx     nginx:1.25-alpine              Up (healthy)   0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp
webapp    username/secure-webapp:latest  Up (healthy)   
```

### 4.2 Verify Services

```bash
# Check nginx logs
docker-compose -f docker-compose.prod.yml logs nginx

# Check webapp logs
docker-compose -f docker-compose.prod.yml logs webapp

# Test HTTP (should redirect to HTTPS)
curl -I http://your-domain.com

# Test HTTPS
curl -I https://your-domain.com
```

### 4.3 Exit SSH

```bash
exit
```

---

## Phase 5: Verify HTTPS from Your Computer (5 minutes)

### 5.1 Test HTTPS URL

Open in your browser:
- **https://your-domain.com** (should show Bootstrap dashboard)
- **https://your-domain.com/health** (should show health status)
- **https://your-domain.com/api/tasks** (should show tasks JSON)

### 5.2 Verify SSL Certificate

In browser:
1. Click the padlock icon in address bar
2. Click "Connection is secure"
3. Click "Certificate is valid"
4. Verify:
   - Issued to: your-domain.com
   - Issued by: Let's Encrypt
   - Valid until: ~90 days from today

### 5.3 Test SSL Security

Visit: https://www.ssllabs.com/ssltest/

1. Enter your domain: `your-domain.com`
2. Click **"Submit"**
3. Wait for analysis (1-2 minutes)
4. **Expected grade:** A or A+

### 5.4 Test Dashboard Features

1. Go to https://your-domain.com
2. Click **"Add New Task"**
3. Fill in title and description
4. Click **"Add Task"**
5. Verify task appears in list
6. Test Edit and Delete buttons

---

## Phase 6: Setup Automatic Certificate Renewal (5 minutes)

Let's Encrypt certificates expire every 90 days. Set up automatic renewal.

### 6.1 SSH to EC2

```bash
ssh -i ~/.ssh/secure-webapp-key ec2-user@your-domain.com
```

### 6.2 Test Renewal (Dry Run)

```bash
# Test renewal without actually renewing
docker-compose -f docker-compose.prod.yml run --rm certbot renew --dry-run
```

**Expected output:** "Congratulations, all simulated renewals succeeded"

### 6.3 Setup Cron Job

```bash
# Edit crontab
crontab -e

# Add this line (runs weekly on Sunday at midnight):
0 0 * * 0 cd ~ && bash ~/scripts/renew-certs.sh >> ~/cert-renew.log 2>&1

# Save and exit (:wq in vim, Ctrl+X in nano)
```

### 6.4 Verify Cron Job

```bash
# List cron jobs
crontab -l

# Check if script is executable
chmod +x ~/scripts/renew-certs.sh

# Test the renewal script
bash ~/scripts/renew-certs.sh
```

---

## Phase 7: Update GitHub Repository (5 minutes)

### 7.1 Commit and Push Changes

```bash
# From your local machine (not EC2)
cd ~/DevOps/secure-webapp-pipeline  # Adjust path

# Check what changed
git status

# Add all changes
git add .

# Commit
git commit -m "Add HTTPS support with Let's Encrypt and Bootstrap UI"

# Push to GitHub
git push origin main
```

### 7.2 Monitor GitHub Actions

1. Go to https://github.com/YOUR_USERNAME/secure-webapp-pipeline/actions
2. Watch the pipeline run
3. Verify all steps pass

---

## Troubleshooting

### Issue: DNS not resolving

```bash
# Check nameservers
dig your-domain.com NS

# Wait longer (DNS can take up to 48 hours)
# Try from different network/device
```

### Issue: SSL certificate request failed

```bash
# Check logs
docker logs certbot

# Common causes:
# 1. DNS not propagated yet → Wait and retry
# 2. Port 80 blocked → Check AWS security groups
# 3. Domain validation failed → Verify domain ownership

# Retry with staging (for testing)
bash ~/scripts/init-letsencrypt.sh your-domain.com your-email@example.com 1
```

### Issue: Nginx won't start

```bash
# Check nginx config
docker run --rm -v $(pwd)/nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
  nginx:1.25-alpine nginx -t

# Check logs
docker-compose -f docker-compose.prod.yml logs nginx

# Verify domain name in config
grep DOMAIN_NAME ~/nginx/nginx.conf  # Should be replaced with your domain
```

### Issue: Certificate expired

```bash
# Manually renew
docker-compose -f docker-compose.prod.yml run --rm certbot renew

# Reload nginx
docker-compose -f docker-compose.prod.yml exec nginx nginx -s reload

# Check expiry date
openssl s_client -connect your-domain.com:443 -servername your-domain.com \
  2>/dev/null | openssl x509 -noout -dates
```

### Issue: Mixed content warnings

Update all HTTP URLs to HTTPS in your code:
- Change `http://` to `https://`
- Or use protocol-relative URLs: `//domain.com`

---

## Cost Summary

| Item | Cost | Frequency |
|------|------|-----------|
| Domain (.com) | $12-13 | Per year |
| Domain (.io) | $35-40 | Per year |
| SSL Certificate | FREE | (Let's Encrypt) |
| AWS EC2 (t3.micro) | $7-8/month | Monthly |
| **Total Monthly** | **~$8-9** | (first year with domain) |

---

##🎉 Success Checklist

- [ ] Domain registered and active in Route 53
- [ ] DNS A records created (domain points to EC2)
- [ ] SSL certificate obtained from Let's Encrypt
- [ ] HTTPS works in browser (no warnings)
- [ ] Bootstrap dashboard accessible
- [ ] Task management features work (add/edit/delete)
- [ ] SSL Labs test shows A or A+ grade
- [ ] Auto-renewal cron job configured
- [ ] GitHub Actions pipeline updated and passing

---

## Next Steps

### Portfolio Enhancement

1. **Take Screenshots**
   - HTTPS URL in browser with green padlock
   - Bootstrap dashboard with tasks
   - SSL Labs A+ rating
   - GitHub Actions green checkmarks

2. **Update README.md**
   - Add live HTTPS URL
   - Add screenshots
   - Update tech stack (add nginx, Let's Encrypt)

3. **LinkedIn Post**
   ```
   🚀 Just added HTTPS and a professional UI to my DevSecOps project!
   
   Enhanced features:
   ✅ Custom domain with Route 53
   ✅ Let's Encrypt SSL certificates (A+ rating)
   ✅ Nginx reverse proxy
   ✅ Bootstrap 5 responsive dashboard
   ✅ Automatic certificate renewal
   
   Live demo: https://your-domain.com
   
   #DevSecOps #HTTPS #AWS #Nginx #LetsEncrypt
   ```

### Optional Enhancements

1. **Add www redirect**
   - Already configured in nginx!
   - Both `domain.com` and `www.domain.com` work

2. **Enable HSTS**
   - Uncomment HSTS header in `nginx/nginx.conf`
   - Only after confirming HTTPS works perfectly!

3. **Add monitoring**
   - Setup SSL certificate expiry alerts
   - Monitor via AWS CloudWatch

4. **Multiple environments**
   - Create `staging.your-domain.com`
   - Deploy dev/staging/prod pipelines

---

## Additional Resources

- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [Nginx SSL Configuration Guide](https://ssl-config.mozilla.org/)
- [AWS Route 53 Documentation](https://docs.aws.amazon.com/route53/)
- [SSL Labs Best Practices](https://github.com/ssllabs/research/wiki/SSL-and-TLS-Deployment-Best-Practices)

---

**Need Help?**
- Check nginx logs: `docker-compose -f docker-compose.prod.yml logs nginx`
- Check certbot logs: `docker-compose -f docker-compose.prod.yml logs certbot`
- Test SSL: https://www.ssllabs.com/ssltest/
- DNS propagation: https://dnschecker.org/

**Happy Secure Deploying! 🔒**
