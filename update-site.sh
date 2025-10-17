#!/usr/bin/env bash
# River City Invitational - Quick Site Update Script
# Run this script to update the live site with latest changes

set -euo pipefail

# Configuration
PROJ_DIR="/opt/mkdocs/rivercity"
SITE_DIR="/var/www/mkdocs/site"

echo "🔄 Updating River City Invitational site..."

# Navigate to project directory
cd "${PROJ_DIR}"

# Check if we're in the right directory
if [ ! -f "mkdocs.yml" ]; then
    echo "❌ Error: mkdocs.yml not found in ${PROJ_DIR}"
    exit 1
fi

# Pull latest changes from git
echo "📥 Pulling latest changes from git..."
# Use the ubuntu user's SSH keys for git operations
sudo -u ubuntu git pull --rebase

# Activate virtual environment
echo "✅ Activating virtual environment..."
source .venv/bin/activate

# Build the documentation
echo "🏗️  Building documentation..."
mkdocs build --clean

# Deploy to web root
echo "🚀 Deploying to web server..."
sudo rsync -a --delete site/ "${SITE_DIR}/"

# Set proper permissions for Caddy
echo "🔐 Setting file permissions..."
sudo chown -R docs:docs "${SITE_DIR}"

echo "✅ Site updated successfully at $(date)"
echo "🌐 Changes should be live now!"