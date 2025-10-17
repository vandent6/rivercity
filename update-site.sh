#!/usr/bin/env bash
# River City Invitational - Production Deployment Script
# This script builds and deploys the MkDocs site to production

set -euo pipefail

# Configuration
SITE_DIR="/var/www/mkdocs/site"
PROJ_DIR="/opt/mkdocs/rivercity"
VENV="/opt/mkdocs/.venv"

echo "🚀 Starting River City Invitational deployment..."

# Check if we're in the right directory
if [ ! -f "mkdocs.yml" ]; then
    echo "❌ Error: mkdocs.yml not found. Please run this script from the project root."
    exit 1
fi

# Activate virtual environment
if [ -d "$VENV" ]; then
    echo "✅ Activating virtual environment..."
    source "${VENV}/bin/activate"
else
    echo "❌ Virtual environment not found at $VENV"
    exit 1
fi

# Navigate to project directory
cd "${PROJ_DIR}"

# Pull latest changes (if this is a git repo)
if [ -d ".git" ]; then
    echo "📥 Pulling latest changes..."
    git pull --rebase
fi

# Install/update requirements
echo "📦 Installing requirements..."
pip install -r requirements.txt

# Build the documentation
echo "🏗️  Building documentation..."
mkdocs build --clean

# Deploy to web root
echo "🚀 Deploying to web server..."
rsync -a --delete site/ "${SITE_DIR}/"

# Set proper permissions
chown -R docs:docs "${SITE_DIR}"

echo "✅ Deployment completed successfully at $(date)"
echo "🌐 Site should be available at your configured domain"