#!/usr/bin/env bash
# River City Invitational - Site Update Script
# This script rebuilds MkDocs and updates Caddy configuration after pulling new code

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

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to check if running as root
check_permissions() {
    if [[ $EUID -eq 0 ]]; then
        log_warning "Running as root. This script should typically be run as a regular user with sudo privileges."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Function to check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if we're in the right directory
    if [[ ! -f "${PROJECT_DIR}/mkdocs.yml" ]]; then
        log_error "mkdocs.yml not found in ${PROJECT_DIR}"
        log_info "Please run this script from the project root or update PROJECT_DIR variable"
        exit 1
    fi
    
    # Check if virtual environment exists
    if [[ ! -d "${VENV_DIR}" ]]; then
        log_warning "Virtual environment not found. Creating one..."
        cd "${PROJECT_DIR}"
        python3 -m venv "${VENV_DIR}"
        source "${VENV_DIR}/bin/activate"
        pip install --upgrade pip
        pip install -r requirements.txt
    fi
    
    # Check if Caddy is installed
    if ! command -v caddy &> /dev/null; then
        log_warning "Caddy not found. Installing Caddy..."
        install_caddy
    fi
    
    log_success "Prerequisites check completed"
}

# Function to install Caddy
install_caddy() {
    log_info "Installing Caddy..."
    
    # Install Caddy using the official install script
    sudo apt update
    sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
    sudo apt update
    sudo apt install -y caddy
    
    # Enable and start Caddy service
    sudo systemctl enable caddy
    sudo systemctl start caddy
    
    log_success "Caddy installed successfully"
}

# Function to create Caddy configuration
create_caddy_config() {
    log_info "Creating Caddy configuration..."
    
    # Create Caddy config directory if it doesn't exist
    sudo mkdir -p "${CADDY_CONFIG_DIR}"
    
    # Create Caddyfile
    sudo tee "${CADDY_CONFIG_FILE}" > /dev/null <<EOF
${DOMAIN} {
    # Serve static files from web root
    root * ${WEB_ROOT}
    
    # Enable file server
    file_server
    
    # Enable gzip compression
    encode gzip
    
    # Add security headers
    header {
        # Enable HSTS
        Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
        
        # Prevent clickjacking
        X-Frame-Options "DENY"
        
        # Prevent MIME type sniffing
        X-Content-Type-Options "nosniff"
        
        # Enable XSS protection
        X-XSS-Protection "1; mode=block"
        
        # Referrer policy
        Referrer-Policy "strict-origin-when-cross-origin"
        
        # Content Security Policy
        Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://cdnjs.cloudflare.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://cdnjs.cloudflare.com; font-src 'self' https://fonts.gstatic.com https://cdnjs.cloudflare.com; img-src 'self' data: https:; connect-src 'self';"
    }
    
    # Custom error pages
    handle_errors {
        @404 {
            expression {http.error.status_code} == 404
        }
        rewrite @404 /404.html
        file_server
    }
    
    # Logging
    log {
        output file /var/log/caddy/rivercity.log {
            roll_size 100mb
            roll_keep 5
            roll_keep_for 720h
        }
        format json
    }
    
    # Automatic HTTPS with Let's Encrypt
    tls ${EMAIL}
}

# Redirect www to non-www
www.${DOMAIN} {
    redir https://${DOMAIN}{uri} permanent
}
EOF

    # Create log directory
    sudo mkdir -p /var/log/caddy
    sudo chown caddy:caddy /var/log/caddy
    
    log_success "Caddy configuration created"
}

# Function to pull latest code
pull_latest_code() {
    log_info "Pulling latest code from repository..."
    
    cd "${PROJECT_DIR}"
    
    # Check if this is a git repository
    if [[ -d ".git" ]]; then
        # Stash any local changes
        if ! git diff --quiet || ! git diff --cached --quiet; then
            log_warning "Local changes detected. Stashing them..."
            git stash push -m "Auto-stash before update $(date)"
        fi
        
        # Pull latest changes
        git pull origin "${GIT_BRANCH}"
        
        log_success "Code updated successfully"
    else
        log_warning "Not a git repository. Skipping code pull."
    fi
}

# Function to build MkDocs site
build_site() {
    log_info "Building MkDocs site..."
    
    cd "${PROJECT_DIR}"
    
    # Activate virtual environment
    source "${VENV_DIR}/bin/activate"
    
    # Install/update requirements
    pip install --upgrade pip
    pip install -r requirements.txt
    
    # Clean and build the site
    mkdocs build --clean
    
    log_success "Site built successfully"
}

# Function to deploy site
deploy_site() {
    log_info "Deploying site to web root..."
    
    # Create web root if it doesn't exist
    sudo mkdir -p "${WEB_ROOT}"
    
    # Copy built site to web root
    sudo rsync -a --delete "${SITE_BUILD_DIR}/" "${WEB_ROOT}/"
    
    # Set proper permissions
    sudo chown -R "${WEB_USER}:${WEB_GROUP}" "${WEB_ROOT}"
    sudo chmod -R 755 "${WEB_ROOT}"
    
    log_success "Site deployed successfully"
}

# Function to reload Caddy
reload_caddy() {
    log_info "Reloading Caddy configuration..."
    
    # Test Caddy configuration
    if sudo caddy validate --config "${CADDY_CONFIG_FILE}"; then
        log_success "Caddy configuration is valid"
        
        # Reload Caddy
        sudo systemctl reload caddy
        
        log_success "Caddy reloaded successfully"
    else
        log_error "Caddy configuration validation failed"
        exit 1
    fi
}

# Function to check site status
check_site_status() {
    log_info "Checking site status..."
    
    # Check if Caddy is running
    if sudo systemctl is-active --quiet caddy; then
        log_success "Caddy service is running"
    else
        log_warning "Caddy service is not running. Starting it..."
        sudo systemctl start caddy
    fi
    
    # Check if site is accessible (basic check)
    if curl -s -o /dev/null -w "%{http_code}" "https://${DOMAIN}" | grep -q "200"; then
        log_success "Site is accessible at https://${DOMAIN}"
    else
        log_warning "Site may not be accessible yet. SSL certificate might be provisioning..."
        log_info "Check site status manually: curl -I https://${DOMAIN}"
    fi
}

# Function to show usage information
show_usage() {
    echo "River City Invitational - Site Update Script"
    echo "============================================="
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --no-pull      Skip pulling latest code from repository"
    echo "  --no-caddy     Skip Caddy configuration and reload"
    echo "  --build-only   Only build the site, don't deploy or reload Caddy"
    echo "  --help         Show this help message"
    echo ""
    echo "This script will:"
    echo "  1. Pull latest code from repository (unless --no-pull)"
    echo "  2. Build the MkDocs site"
    echo "  3. Deploy to web root"
    echo "  4. Update Caddy configuration (unless --no-caddy)"
    echo "  5. Reload Caddy service (unless --no-caddy)"
    echo ""
    echo "Configuration:"
    echo "  Project Dir: ${PROJECT_DIR}"
    echo "  Web Root: ${WEB_ROOT}"
    echo "  Domain: ${DOMAIN}"
    echo "  Email: ${EMAIL}"
    echo ""
}

# Main function
main() {
    local SKIP_PULL=false
    local SKIP_CADDY=false
    local BUILD_ONLY=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --no-pull)
                SKIP_PULL=true
                shift
                ;;
            --no-caddy)
                SKIP_CADDY=true
                shift
                ;;
            --build-only)
                BUILD_ONLY=true
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    log_info "🚀 Starting River City Invitational site update..."
    echo ""
    
    # Run the update process
    check_permissions
    check_prerequisites
    
    if [[ "$SKIP_PULL" == false ]]; then
        pull_latest_code
    else
        log_info "Skipping code pull (--no-pull specified)"
    fi
    
    build_site
    
    if [[ "$BUILD_ONLY" == false ]]; then
        deploy_site
        
        if [[ "$SKIP_CADDY" == false ]]; then
            create_caddy_config
            reload_caddy
            check_site_status
        else
            log_info "Skipping Caddy operations (--no-caddy specified)"
        fi
    else
        log_info "Build completed (--build-only specified)"
    fi
    
    echo ""
    log_success "🎉 Site update completed successfully!"
    echo ""
    log_info "Next steps:"
    echo "  • Visit your site: https://${DOMAIN}"
    echo "  • Check logs: sudo journalctl -u caddy -f"
    echo "  • Check site logs: tail -f /var/log/caddy/rivercity.log"
}

# Run main function with all arguments
main "$@"
