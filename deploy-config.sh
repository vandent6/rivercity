#!/usr/bin/env bash
# River City Invitational - Deployment Configuration
# This file contains server-specific configuration that should be customized
# for your production environment.

# =============================================================================
# SERVER CONFIGURATION
# =============================================================================
# Update these paths and settings for your specific server environment

# Project and deployment paths
export PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SITE_BUILD_DIR="${PROJECT_DIR}/site"
export WEB_ROOT="/var/www/rivercity"

# Caddy configuration
export CADDY_CONFIG_DIR="/etc/caddy"
export CADDY_CONFIG_FILE="${CADDY_CONFIG_DIR}/Caddyfile"

# Domain and SSL configuration
export DOMAIN="rivercity.michiganesports.org"
export EMAIL="info@mihsef.org"

# Web server user (adjust based on your server setup)
export WEB_USER="www-data"
export WEB_GROUP="www-data"

# Virtual environment location (relative to project)
export VENV_DIR="${PROJECT_DIR}/.venv"

# Git repository settings
export GIT_BRANCH="main"  # or "master" depending on your default branch

# =============================================================================
# OPTIONAL CUSTOMIZATIONS
# =============================================================================

# Additional Caddy modules (if needed)
export CADDY_MODULES=""

# Custom build options
export MKDO CS_BUILD_OPTIONS="--clean"

# Backup settings
export BACKUP_DIR="/var/backups/rivercity"
export BACKUP_RETENTION_DAYS="30"

# Log settings
export LOG_LEVEL="info"
export LOG_RETENTION_DAYS="7"

# =============================================================================
# VALIDATION FUNCTIONS
# =============================================================================

# Function to validate configuration
validate_config() {
    local errors=0
    
    # Check required directories
    if [[ ! -d "$(dirname "$WEB_ROOT")" ]]; then
        echo "❌ Error: Web root parent directory $(dirname "$WEB_ROOT") does not exist"
        ((errors++))
    fi
    
    # Check if domain is set
    if [[ -z "$DOMAIN" || "$DOMAIN" == "your-domain.com" ]]; then
        echo "❌ Error: DOMAIN must be set to your actual domain"
        ((errors++))
    fi
    
    # Check if email is set
    if [[ -z "$EMAIL" || "$EMAIL" == "your-email@example.com" ]]; then
        echo "❌ Error: EMAIL must be set for SSL certificate registration"
        ((errors++))
    fi
    
    # Check web user exists
    if ! id "$WEB_USER" &>/dev/null; then
        echo "❌ Warning: Web user '$WEB_USER' does not exist on this system"
        echo "   Available users: $(cut -d: -f1 /etc/passwd | grep -E '^(www-data|nginx|apache|http)' | tr '\n' ' ')"
    fi
    
    if [[ $errors -gt 0 ]]; then
        echo ""
        echo "Please update the configuration in deploy-config.sh before running deployment"
        exit 1
    fi
    
    echo "✅ Configuration validation passed"
}

# Function to detect system type and adjust configuration
detect_system() {
    # Detect Linux distribution
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        export OS_NAME="$NAME"
        export OS_VERSION="$VERSION_ID"
    else
        export OS_NAME="Unknown"
        export OS_VERSION="Unknown"
    fi
    
    # Detect web server
    if systemctl is-active --quiet nginx; then
        export WEB_SERVER="nginx"
        export WEB_USER="nginx"
        export WEB_GROUP="nginx"
    elif systemctl is-active --quiet apache2; then
        export WEB_SERVER="apache"
        export WEB_USER="www-data"
        export WEB_GROUP="www-data"
    elif systemctl is-active --quiet caddy; then
        export WEB_SERVER="caddy"
    else
        export WEB_SERVER="none"
    fi
    
    echo "🔍 Detected system: $OS_NAME $OS_VERSION"
    echo "🔍 Web server: $WEB_SERVER"
}

# Function to show current configuration
show_config() {
    echo "📋 Current Deployment Configuration"
    echo "=================================="
    echo "Project Directory: $PROJECT_DIR"
    echo "Site Build Dir:    $SITE_BUILD_DIR"
    echo "Web Root:          $WEB_ROOT"
    echo "Domain:            $DOMAIN"
    echo "Email:             $EMAIL"
    echo "Web User:          $WEB_USER"
    echo "Web Group:         $WEB_GROUP"
    echo "Git Branch:        $GIT_BRANCH"
    echo "Virtual Env:       $VENV_DIR"
    echo ""
}

# Load configuration on script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being executed directly
    show_config
    detect_system
    validate_config
else
    # Script is being sourced
    detect_system
fi
