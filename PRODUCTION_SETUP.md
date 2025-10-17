# Production Deployment Guide

## Quick Setup on Lightsail Server

### 1. Initial Setup
```bash
# Navigate to mkdocs directory
cd /opt/mkdocs

# Remove old site (if exists)
sudo rm -rf mysite

# Clone rivercity repository
git clone git@github.com:vandent6/rivercity.git rivercity

# Navigate to new site
cd rivercity

# Install deployment scripts
./install-deploy-script.sh
```

### 2. First Deployment
```bash
# Run full deployment (creates venv, installs dependencies, builds site)
sudo rivercity-deploy
```

### 3. Future Updates
After making changes to the repository:

```bash
# Quick update (assumes venv already exists)
sudo rivercity-update
```

### 4. Manual Deployment (Alternative)
If you prefer to run manually:

```bash
cd /opt/mkdocs/rivercity
./deploy.sh
```

## What's Ready for Production

✅ **Fixed broken internal links** - All anchor links now work correctly  
✅ **Split registration buttons** - Separate collegiate and high school registration buttons  
✅ **Production deployment script** - Automated build and deploy process  
✅ **Requirements.txt** - All dependencies properly specified  
✅ **MkDocs configuration** - Optimized for production deployment  
✅ **Local testing** - Verified site builds and serves correctly  

## Key Features

- **Separate Registration**: Collegiate and High School registration buttons with distinct styling
- **Fixed Navigation**: All internal links work correctly
- **Production Ready**: Optimized build process and deployment script
- **Material Theme**: Professional design with search functionality
- **Responsive Design**: Works on all devices

The site is now ready for production deployment!
