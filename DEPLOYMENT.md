# River City Invitational - Deployment Guide

This guide covers how to deploy and update the River City Invitational website using the provided scripts. These scripts are designed to work when pulled from a repository and run on your server.

## Scripts Overview

### 1. `setup-deployment.sh` - Initial Setup Script
**Run this first** to configure deployment for your specific server environment.

**Features:**
- Detects your system configuration
- Prompts for server-specific settings
- Creates `deploy-config.sh` with your configuration
- Validates the setup

**Usage:**
```bash
# Run initial setup (do this first!)
./setup-deployment.sh
```

### 2. `update-site.sh` - Full Update Script
The comprehensive script that handles the complete deployment process including Caddy setup.

**Features:**
- Pulls latest code from repository
- Builds MkDocs site
- Installs/configures Caddy if needed
- Deploys site to web root
- Reloads Caddy configuration
- Validates site accessibility

**Usage:**
```bash
# Full update (recommended for first-time setup)
./update-site.sh

# Skip pulling code (if you've already pulled manually)
./update-site.sh --no-pull

# Skip Caddy operations (if you're using a different web server)
./update-site.sh --no-caddy

# Build only (don't deploy or reload)
./update-site.sh --build-only

# Show help
./update-site.sh --help
```

### 3. `quick-update.sh` - Quick Update Script
A simple script for quick updates after you've already pulled new code.

**Usage:**
```bash
# After pulling new code
git pull origin main
./quick-update.sh
```

## Configuration

The scripts use a separate configuration file `deploy-config.sh` that is created by the setup script. This makes the deployment portable across different servers.

**Configuration is handled automatically by `setup-deployment.sh`, but you can manually edit `deploy-config.sh` if needed:**

## Prerequisites

### System Requirements
- Ubuntu/Debian Linux
- Python 3.7+
- Git
- sudo access

### First-Time Setup
The `update-site.sh` script will automatically:
- Create a Python virtual environment
- Install MkDocs and dependencies
- Install Caddy web server
- Configure SSL certificates with Let's Encrypt
- Set up proper file permissions

## Workflow

### Initial Deployment (First Time Setup)
```bash
# Clone your repository
git clone https://github.com/yourusername/rivercity.git
cd rivercity

# Run setup to configure for your server
./setup-deployment.sh

# Run full update (this will install everything)
./update-site.sh
```

### Regular Updates After Code Changes
```bash
# Option 1: Let the script pull code for you
./update-site.sh

# Option 2: Pull manually then quick update
git pull origin main
./quick-update.sh
```

## Caddy Configuration

The script creates a Caddyfile at `/etc/caddy/Caddyfile` with:
- Automatic HTTPS with Let's Encrypt
- Security headers
- Gzip compression
- Custom error pages
- Logging configuration

### Manual Caddy Commands
```bash
# Test Caddy configuration
sudo caddy validate --config /etc/caddy/Caddyfile

# Reload Caddy
sudo systemctl reload caddy

# Check Caddy status
sudo systemctl status caddy

# View Caddy logs
sudo journalctl -u caddy -f
```

## Troubleshooting

### Common Issues

**Permission Denied:**
```bash
# Make scripts executable
chmod +x *.sh
```

**Virtual Environment Issues:**
```bash
# Recreate virtual environment
rm -rf .venv
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

**Caddy SSL Issues:**
```bash
# Check Caddy logs
sudo journalctl -u caddy -f

# Test domain resolution
nslookup rivercity.michiganesports.org
```

**Site Not Updating:**
```bash
# Check file permissions
ls -la /var/www/rivercity/

# Verify Caddy is serving from correct directory
sudo caddy validate --config /etc/caddy/Caddyfile
```

### Logs and Monitoring

**Caddy Logs:**
```bash
# System logs
sudo journalctl -u caddy -f

# Site-specific logs
tail -f /var/log/caddy/rivercity.log
```

**Check Site Status:**
```bash
# Test site accessibility
curl -I https://rivercity.michiganesports.org

# Check SSL certificate
openssl s_client -connect rivercity.michiganesports.org:443 -servername rivercity.michiganesports.org
```

## Security Considerations

The Caddy configuration includes:
- Automatic HTTPS with Let's Encrypt
- Security headers (HSTS, X-Frame-Options, etc.)
- Content Security Policy
- Proper file permissions

## Backup and Recovery

### Backup Site
```bash
# Create backup
sudo tar -czf rivercity-backup-$(date +%Y%m%d).tar.gz /var/www/rivercity

# Backup Caddy configuration
sudo cp /etc/caddy/Caddyfile /etc/caddy/Caddyfile.backup
```

### Restore Site
```bash
# Restore from backup
sudo tar -xzf rivercity-backup-YYYYMMDD.tar.gz -C /
sudo systemctl reload caddy
```

## Development vs Production

### Development
- Use `./serve-mkdocs.sh` for local development
- Access at `http://localhost:8000`
- Auto-reload on file changes

### Production
- Use `./update-site.sh` or `./quick-update.sh`
- Access at `https://rivercity.michiganesports.org`
- Optimized for performance and security

## Support

If you encounter issues:
1. Check the logs using the commands above
2. Verify all configuration variables are correct
3. Ensure all prerequisites are installed
4. Check network connectivity and DNS resolution

For additional help, refer to:
- [MkDocs Documentation](https://www.mkdocs.org/)
- [Caddy Documentation](https://caddyserver.com/docs/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
