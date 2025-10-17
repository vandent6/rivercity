#!/usr/bin/env bash
# Simple River City Deployment Script
# Just the essential commands to build and deploy the site

set -euo pipefail

echo "🚀 Deploying River City Invitational site..."

# Navigate to your cloned repository
cd /opt/mkdocs/rivercity

# Activate virtual environment (if not already active)
source .venv/bin/activate

# Install requirements
pip install -r requirements.txt

# Build the site
mkdocs build --clean

# Deploy to the web directory
sudo rsync -a --delete site/ /var/www/mkdocs/site/

# Set proper ownership for Caddy
sudo chown -R docs:docs /var/www/mkdocs/site/

# Check if Caddy is running
sudo systemctl status caddy

# If it's running, reload the configuration
sudo systemctl reload caddy

# If it's not running, start it
sudo systemctl start caddy

echo "✅ Deployment completed!"
