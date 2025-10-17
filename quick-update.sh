#!/usr/bin/env bash
# River City Invitational - Quick Update Script
# Simple script for quick updates after pulling code

set -euo pipefail

# Load configuration from external file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${SCRIPT_DIR}/deploy-config.sh" ]]; then
    source "${SCRIPT_DIR}/deploy-config.sh"
else
    echo "❌ Error: deploy-config.sh not found in ${SCRIPT_DIR}"
    echo "Please ensure deploy-config.sh exists in the same directory as this script"
    exit 1
fi

echo "🚀 Quick Update - River City Invitational"
echo "========================================"
echo ""

# Check if we're in the right directory
if [[ ! -f "${PROJECT_DIR}/mkdocs.yml" ]]; then
    echo "❌ Error: mkdocs.yml not found in ${PROJECT_DIR}"
    echo "Please run this script from the project root"
    exit 1
fi

cd "${PROJECT_DIR}"

# Check if we're already in a virtual environment
if [[ -n "${VIRTUAL_ENV:-}" ]]; then
    echo "📦 Using existing virtual environment: ${VIRTUAL_ENV}"
else
    echo "📦 Activating virtual environment..."
    source "${VENV_DIR}/bin/activate"
fi

# Build the site
echo "🏗️  Building MkDocs site..."
mkdocs build --clean

# Deploy to web root
echo "🚀 Deploying to web root..."
sudo rsync -a --delete site/ "${WEB_ROOT}/"
sudo chown -R "${WEB_USER}:${WEB_GROUP}" "${WEB_ROOT}"

# Reload Caddy
echo "🔄 Reloading Caddy..."
sudo systemctl reload caddy

echo ""
echo "✅ Quick update completed!"
echo "🌐 Site should be updated at https://rivercity.michiganesports.org"
echo ""
