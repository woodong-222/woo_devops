#!/bin/bash

echo "Woo-DevOps Environment Setup Script"
echo "===================================="
echo ""

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_success() {
    echo -e "${GREEN}SUCCESS: $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

print_error() {
    echo -e "${RED}ERROR: $1${NC}"
}

print_info() {
    echo -e "${BLUE}INFO: $1${NC}"
}

# Git Repository Configuration
echo -e "${BLUE}Git Repository Configuration${NC}"
read -p "Enter Frontend Git Repository URL (default: https://github.com/test_front.git): " FRONTEND_REPO
read -p "Enter Backend Git Repository URL (default: https://github.com/test_back.git): " BACKEND_REPO

# Set defaults if not provided
FRONTEND_REPO=${FRONTEND_REPO:-"https://github.com/test_front.git"}
BACKEND_REPO=${BACKEND_REPO:-"https://github.com/test_back.git"}

echo ""
# Database Configuration
echo -e "${BLUE}Database Configuration${NC}"
read -p "Enter Database Name (default: woo_devops): " DB_NAME
read -p "Enter Database User (default: woo): " DB_USER
read -s -p "Enter Database Password (default: woo123): " DB_PASSWORD
echo ""
read -s -p "Enter Database Root Password (default: woo123): " DB_ROOT_PASSWORD
echo ""

# Set defaults if not provided
DB_NAME=${DB_NAME:-"woo_devops"}
DB_USER=${DB_USER:-"woo"}
DB_PASSWORD=${DB_PASSWORD:-"woo123"}
DB_ROOT_PASSWORD=${DB_ROOT_PASSWORD:-"woo123"}

echo ""
# Jenkins Configuration
echo -e "${BLUE}Jenkins Configuration${NC}"
read -p "Enter Jenkins Admin Username (default: admin): " JENKINS_USER
read -s -p "Enter Jenkins Admin Password (default: admin123): " JENKINS_PASSWORD
echo ""

# Set defaults if not provided
JENKINS_USER=${JENKINS_USER:-"admin"}
JENKINS_PASSWORD=${JENKINS_PASSWORD:-"admin123"}

echo ""
# Credentials Configuration
echo -e "${BLUE}Credentials Configuration${NC}"
read -p "Enable Discord notifications? [y/N]: " ENABLE_DISCORD

DISCORD_WEBHOOK=""
if [[ "$ENABLE_DISCORD" =~ ^[Yy]$ ]]; then
    read -p "Enter Discord Webhook URL: " DISCORD_WEBHOOK
    if [ -z "$DISCORD_WEBHOOK" ]; then
        print_warning "Discord webhook URL is required when Discord notifications are enabled."
        DISCORD_WEBHOOK=""
    fi
fi

read -p "Enter GitHub Personal Access Token (optional): " GITHUB_TOKEN

echo ""
# Domain input
echo -e "${BLUE}Domain Configuration${NC}"
read -p "Enter main domain (example: example.com): " DOMAIN

if [ -z "$DOMAIN" ]; then
    print_error "Domain is required."
    exit 1
fi

echo ""
echo -e "${BLUE}SSL/HTTPS Configuration${NC}"
echo "1) HTTP only (development)"
echo "2) HTTPS (production - SSL certificate required)"
read -p "Choose [1-2]: " SSL_CHOICE

USE_HTTPS=false
SSL_CERT_PATH=""
SSL_KEY_PATH=""

if [ "$SSL_CHOICE" = "2" ]; then
    USE_HTTPS=true
    echo ""
    print_info "Enter SSL certificate paths"
    read -p "Certificate file path (example: /etc/letsencrypt/live/$DOMAIN/fullchain.pem): " SSL_CERT_PATH
    read -p "Private key file path (example: /etc/letsencrypt/live/$DOMAIN/privkey.pem): " SSL_KEY_PATH
    
    # Required input validation
    if [ -z "$SSL_CERT_PATH" ]; then
        print_error "SSL certificate path is required."
        exit 1
    fi
    if [ -z "$SSL_KEY_PATH" ]; then
        print_error "SSL private key path is required."
        exit 1
    fi
elif [ "$SSL_CHOICE" != "1" ]; then
    print_error "Please choose 1 or 2."
    exit 1
fi

echo ""
echo "==================================="
echo -e "${YELLOW}Configuration Summary${NC}"
echo "==================================="
echo "Frontend Repository: $FRONTEND_REPO"
echo "Backend Repository: $BACKEND_REPO"
echo "Database Name: $DB_NAME"
echo "Database User: $DB_USER"
echo "Jenkins Admin User: $JENKINS_USER"
echo "Discord Notifications: $([ -n "$DISCORD_WEBHOOK" ] && echo "Enabled" || echo "Disabled")"
echo "GitHub Token: $([ -n "$GITHUB_TOKEN" ] && echo "Configured" || echo "Not set")"
echo "Domain: $DOMAIN"
echo "Protocol: $([ "$USE_HTTPS" = true ] && echo "HTTPS" || echo "HTTP")"
if [ "$USE_HTTPS" = true ]; then
    echo "SSL Certificate: $SSL_CERT_PATH"
    echo "SSL Private Key: $SSL_KEY_PATH"
fi
echo "==================================="
echo ""

read -p "Proceed with this configuration? [y/N]: " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    print_warning "Configuration cancelled."
    exit 1
fi

echo ""
print_info "Starting environment setup..."

# Create necessary directories
mkdir -p ./jenkins
mkdir -p ./nginx

# Update Jenkins configuration files with Git repositories
echo "Updating Jenkins configuration files..."

# Update Frontend Jenkins config
if [ -f "./jenkins/jobs/Frontend/config.xml" ]; then
    # Escape URL for sed (replace / with \/)
    FRONTEND_REPO_ESCAPED=$(echo "$FRONTEND_REPO" | sed 's/\//\\\//g')
    sed -i "s/https:\/\/github\.com\/test_front\.git/$FRONTEND_REPO_ESCAPED/g" ./jenkins/jobs/Frontend/config.xml 2>/dev/null || \
    sed -i "" "s/https:\/\/github\.com\/test_front\.git/$FRONTEND_REPO_ESCAPED/g" ./jenkins/jobs/Frontend/config.xml 2>/dev/null || \
    print_warning "Could not update Frontend Jenkins config automatically"
    print_success "Frontend Jenkins config updated"
fi

# Update Backend Jenkins config  
if [ -f "./jenkins/jobs/Backend/config.xml" ]; then
    # Escape URL for sed (replace / with \/)
    BACKEND_REPO_ESCAPED=$(echo "$BACKEND_REPO" | sed 's/\//\\\//g')
    sed -i "s/https:\/\/github\.com\/test_back\.git/$BACKEND_REPO_ESCAPED/g" ./jenkins/jobs/Backend/config.xml 2>/dev/null || \
    sed -i "" "s/https:\/\/github\.com\/test_back\.git/$BACKEND_REPO_ESCAPED/g" ./jenkins/jobs/Backend/config.xml 2>/dev/null || \
    print_warning "Could not update Backend Jenkins config automatically"
    print_success "Backend Jenkins config updated"
fi

# Create setup.conf file for docker-compose
echo "Creating configuration file..."
cat > setup.conf << EOF
# Git Repository URLs
FRONTEND_REPO_URL=$FRONTEND_REPO
BACKEND_REPO_URL=$BACKEND_REPO

# Database Configuration
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
DB_ROOT_PASSWORD=$DB_ROOT_PASSWORD

# Jenkins Configuration
JENKINS_USER=$JENKINS_USER
JENKINS_PASSWORD=$JENKINS_PASSWORD

# Credentials Configuration
DISCORD_WEBHOOK=$DISCORD_WEBHOOK
GITHUB_TOKEN=$GITHUB_TOKEN
EOF

print_success "setup.conf file created"

# Generate Nginx configuration file
echo "Generating Nginx configuration file..."

if [ "$USE_HTTPS" = true ]; then
    # Use HTTPS version
    sed -e "s/test\.com/$DOMAIN/g" \
        -e "s|/etc/letsencrypt/live/test\.com/fullchain\.pem|$SSL_CERT_PATH|g" \
        -e "s|/etc/letsencrypt/live/test\.com/privkey\.pem|$SSL_KEY_PATH|g" \
        ./nginx/nginx-https.conf > ./nginx/nginx.conf
    print_success "HTTPS Nginx configuration applied"
else
    # Use HTTP version
    sed "s/test\.com/$DOMAIN/g" ./nginx/nginx-http.conf > ./nginx/nginx.conf
    print_success "HTTP Nginx configuration applied"
fi

# Jenkins permission setup
if [ -d "./jenkins" ]; then
    echo "Setting Jenkins directory permissions..."
    sudo chown -R 1000:1000 ./jenkins 2>/dev/null || print_warning "Skipping Jenkins permissions (sudo required)"
    sudo chmod -R 755 ./jenkins 2>/dev/null
    print_success "Jenkins permissions setup completed"
fi

# Nginx permission setup
if [ -f "./nginx/nginx.conf" ]; then
    echo "Setting Nginx configuration file permissions..."
    sudo chown 101:101 ./nginx/nginx.conf 2>/dev/null || print_warning "Skipping Nginx permissions (sudo required)"
    sudo chmod 644 ./nginx/nginx.conf 2>/dev/null
    print_success "Nginx permissions setup completed"
fi

# Docker Compose file verification
if [ -f "docker-compose.yml" ]; then
    echo "Verifying Docker Compose file..."
    docker-compose config > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        print_success "Docker Compose file is valid"
    else
        print_error "Docker Compose file has issues"
        print_info "Run 'docker-compose config' for details"
    fi
fi

# /etc/hosts configuration guide
echo ""
print_info "Add the following to /etc/hosts file for local testing:"
echo "127.0.0.1 $DOMAIN"
echo "127.0.0.1 www.$DOMAIN"
echo "127.0.0.1 api.$DOMAIN" 
echo "127.0.0.1 jenkins.$DOMAIN"

echo ""
print_success "Environment setup completed!"
echo ""
print_info "Start services with: docker-compose up -d"
echo ""
echo "Service Access Information:"
if [ "$USE_HTTPS" = true ]; then
    echo "   - Frontend: https://$DOMAIN"
    echo "   - Backend:  https://api.$DOMAIN"
    echo "   - Jenkins:  https://jenkins.$DOMAIN"
    echo "   - Nginx:    https://$DOMAIN"
else
    echo "   - Frontend: http://$DOMAIN"
    echo "   - Backend:  http://api.$DOMAIN"
    echo "   - Jenkins:  http://jenkins.$DOMAIN"
    echo "   - Nginx:    http://$DOMAIN"
fi
echo "   - MySQL:    localhost:3306 (direct connection)"