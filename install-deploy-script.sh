#!/usr/bin/env bash
# Install the deployment script system-wide
# Run this once to install the deployment script

set -euo pipefail

echo "🔧 Installing River City deployment script..."

# Copy the deploy script to system location
sudo cp deploy.sh /usr/local/bin/rivercity-deploy
sudo chmod +x /usr/local/bin/rivercity-deploy

# Copy the update script to system location
sudo cp update-site.sh /usr/local/bin/rivercity-update
sudo chmod +x /usr/local/bin/rivercity-update

echo "✅ Deployment scripts installed successfully!"
echo ""
echo "📋 Available commands:"
echo "  rivercity-deploy  - Full deployment (creates venv if needed)"
echo "  rivercity-update  - Quick update (assumes venv exists)"
echo ""
echo "🚀 Usage:"
echo "  sudo rivercity-deploy   # Run from anywhere for full deployment"
echo "  sudo rivercity-update   # Run from anywhere for quick updates"
