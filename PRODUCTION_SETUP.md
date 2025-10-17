# Production Deployment Guide

## Quick Setup on Lightsail Server

### 1. Replace existing site
```bash
# Switch to docs user
sudo -iu docs

# Navigate to mkdocs directory
cd /opt/mkdocs

# Remove old site
rm -rf mysite

# Clone rivercity repository
git clone https://github.com/yourusername/rivercity.git mysite

# Navigate to new site
cd mysite

# Activate virtual environment
source ../.venv/bin/activate

# Install requirements
pip install -r requirements.txt

# Build and deploy
mkdocs build --clean
rsync -a --delete site/ /var/www/mkdocs/site/
```

### 2. Update deploy script
Replace `/usr/local/bin/mkdocs-deploy` with the provided `deploy.sh` script:

```bash
sudo cp deploy.sh /usr/local/bin/mkdocs-deploy
sudo chmod +x /usr/local/bin/mkdocs-deploy
```

### 3. Future deployments
After making changes to the repository:

```bash
sudo /usr/local/bin/mkdocs-deploy
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
