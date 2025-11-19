#!/bin/bash

#############################################################################
# Music Student Progress Tracker - Linux Server Installation Script
# This script automates the complete setup for /opt/studmgmt/
# 
# Usage: sudo bash install-linux.sh
#############################################################################

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Installation paths
INSTALL_DIR="/opt/studmgmt"
APP_USER="studmgmt"
APP_GROUP="studmgmt"
VENV_DIR="$INSTALL_DIR/venv"

echo -e "${BLUE}═════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Music Student Progress Tracker - Linux Installation${NC}"
echo -e "${BLUE}Installation Directory: $INSTALL_DIR${NC}"
echo -e "${BLUE}═════════════════════════════════════════════════════════════${NC}"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}❌ This script must be run as root${NC}"
   echo "Usage: sudo bash install-linux.sh"
   exit 1
fi

# Step 1: Update system
echo -e "${YELLOW}📦 Step 1: Updating system packages...${NC}"
apt-get update
apt-get upgrade -y

# Step 2: Install dependencies
echo -e "${YELLOW}📦 Step 2: Installing system dependencies...${NC}"
apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    nginx \
    git \
    curl \
    wget \
    supervisor

# Step 3: Create app user and directory
echo -e "${YELLOW}👤 Step 3: Creating app user and directory...${NC}"

# Create user if it doesn't exist
if ! id "$APP_USER" &>/dev/null; then
    useradd -r -s /bin/bash -d "$INSTALL_DIR" -m "$APP_USER"
    echo -e "${GREEN}✓ User '$APP_USER' created${NC}"
else
    echo -e "${GREEN}✓ User '$APP_USER' already exists${NC}"
fi

# Create installation directory
if [ ! -d "$INSTALL_DIR" ]; then
    mkdir -p "$INSTALL_DIR"
    chown "$APP_USER:$APP_GROUP" "$INSTALL_DIR"
    echo -e "${GREEN}✓ Directory '$INSTALL_DIR' created${NC}"
else
    echo -e "${GREEN}✓ Directory '$INSTALL_DIR' already exists${NC}"
fi

# Step 4: Create virtual environment
echo -e "${YELLOW}🐍 Step 4: Creating Python virtual environment...${NC}"
sudo -u "$APP_USER" python3 -m venv "$VENV_DIR"
echo -e "${GREEN}✓ Virtual environment created at $VENV_DIR${NC}"

# Step 5: Verify application files
echo -e "${YELLOW}📂 Step 5: Verifying application files...${NC}"

# Check if files already exist in INSTALL_DIR (cloned from git)
if [ -f "$INSTALL_DIR/app.py" ]; then
    echo -e "${GREEN}✓ app.py already in place${NC}"
else
    # Try to copy from current directory if running from staging
    if [ -f "app.py" ]; then
        cp app.py "$INSTALL_DIR/"
        echo -e "${GREEN}✓ app.py copied${NC}"
    fi
fi

if [ -f "$INSTALL_DIR/requirements.txt" ]; then
    echo -e "${GREEN}✓ requirements.txt already in place${NC}"
else
    if [ -f "requirements.txt" ]; then
        cp requirements.txt "$INSTALL_DIR/"
        echo -e "${GREEN}✓ requirements.txt copied${NC}"
    fi
fi

if [ -d "$INSTALL_DIR/templates" ]; then
    echo -e "${GREEN}✓ templates/ already in place${NC}"
else
    if [ -d "templates" ]; then
        cp -r templates "$INSTALL_DIR/"
        echo -e "${GREEN}✓ templates/ copied${NC}"
    fi
fi

# Fix permissions on all app files
chown -R "$APP_USER:$APP_GROUP" "$INSTALL_DIR"
echo -e "${GREEN}✓ Permissions set correctly${NC}"

# Step 6: Install Python dependencies
echo -e "${YELLOW}📚 Step 6: Installing Python dependencies...${NC}"
if [ -f "$INSTALL_DIR/requirements.txt" ]; then
    sudo -u "$APP_USER" "$VENV_DIR/bin/pip" install --upgrade pip
    sudo -u "$APP_USER" "$VENV_DIR/bin/pip" install -r "$INSTALL_DIR/requirements.txt"
    echo -e "${GREEN}✓ Python dependencies installed${NC}"
else
    echo -e "${RED}⚠️  requirements.txt not found${NC}"
fi

# Step 7: Create data directory
echo -e "${YELLOW}📊 Step 7: Creating data directory...${NC}"
mkdir -p "$INSTALL_DIR/data"
chown "$APP_USER:$APP_GROUP" "$INSTALL_DIR/data"
chmod 755 "$INSTALL_DIR/data"
echo -e "${GREEN}✓ Data directory created${NC}"

# Step 8: Create .env file template
echo -e "${YELLOW}🔐 Step 8: Creating .env configuration template...${NC}"
cat > "$INSTALL_DIR/.env.template" << 'EOF'
# Student Management System Configuration
# Copy this file to .env and fill in your values

# Gemini API Configuration
# Get your API key from: https://aistudio.google.com/apikey
GEMINI_API_KEY=your_api_key_here

# Flask Configuration
FLASK_ENV=production
FLASK_DEBUG=False

# Server Configuration
GUNICORN_WORKERS=4
GUNICORN_HOST=127.0.0.1
GUNICORN_PORT=8000
EOF

chown "$APP_USER:$APP_GROUP" "$INSTALL_DIR/.env.template"
chmod 600 "$INSTALL_DIR/.env.template"

# Create actual .env if it doesn't exist
if [ ! -f "$INSTALL_DIR/.env" ]; then
    cp "$INSTALL_DIR/.env.template" "$INSTALL_DIR/.env"
    chown "$APP_USER:$APP_GROUP" "$INSTALL_DIR/.env"
    chmod 600 "$INSTALL_DIR/.env"
    echo -e "${GREEN}✓ .env template created${NC}"
    echo -e "${YELLOW}⚠️  Edit $INSTALL_DIR/.env and add your Gemini API key${NC}"
else
    echo -e "${GREEN}✓ .env file already exists${NC}"
fi

# Step 9: Create systemd service file
echo -e "${YELLOW}⚙️  Step 9: Creating systemd service file...${NC}"
cat > /etc/systemd/system/studmgmt.service << EOF
[Unit]
Description=Student Management System
After=network.target nginx.service

[Service]
Type=notify
User=$APP_USER
Group=$APP_GROUP
WorkingDirectory=$INSTALL_DIR
Environment="PATH=$VENV_DIR/bin"
Environment="GUNICORN_WORKERS=4"
EnvironmentFile=$INSTALL_DIR/.env
ExecStart=$VENV_DIR/bin/gunicorn \
    --workers 4 \
    --worker-class sync \
    --bind 127.0.0.1:8000 \
    --timeout 60 \
    --access-logfile /var/log/studmgmt/access.log \
    --error-logfile /var/log/studmgmt/error.log \
    --log-level info \
    app:app

ExecReload=/bin/kill -s HUP \$MAINPID
KillMode=mixed
KillSignal=SIGQUIT
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

chmod 644 /etc/systemd/system/studmgmt.service
systemctl daemon-reload
echo -e "${GREEN}✓ Systemd service file created${NC}"

# Step 10: Create log directory
echo -e "${YELLOW}📝 Step 10: Creating log directory...${NC}"
mkdir -p /var/log/studmgmt
chown "$APP_USER:$APP_GROUP" /var/log/studmgmt
chmod 755 /var/log/studmgmt
echo -e "${GREEN}✓ Log directory created at /var/log/studmgmt${NC}"

# Step 11: Configure Nginx
echo -e "${YELLOW}🌐 Step 11: Configuring Nginx...${NC}"

# Create nginx config
cat > /etc/nginx/sites-available/studmgmt << 'EOF'
upstream studmgmt_app {
    server 127.0.0.1:8000;
}

server {
    listen 80;
    server_name _;
    client_max_body_size 20M;

    # Access and error logs
    access_log /var/log/nginx/studmgmt_access.log;
    error_log /var/log/nginx/studmgmt_error.log;

    # Redirect /favicon.ico to avoid 404s
    location = /favicon.ico { access_log off; log_not_found off; }

    # Main application
    location / {
        proxy_pass http://studmgmt_app;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;
        
        # WebSocket support (if needed in future)
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # Static files (if you add them later)
    location /static/ {
        alias /opt/studmgmt/static/;
        expires 30d;
    }
}
EOF

# Enable the site
if [ ! -L /etc/nginx/sites-enabled/studmgmt ]; then
    ln -s /etc/nginx/sites-available/studmgmt /etc/nginx/sites-enabled/studmgmt
    echo -e "${GREEN}✓ Nginx site enabled${NC}"
else
    echo -e "${GREEN}✓ Nginx site already enabled${NC}"
fi

# Test nginx configuration
if nginx -t &>/dev/null; then
    echo -e "${GREEN}✓ Nginx configuration valid${NC}"
else
    echo -e "${RED}❌ Nginx configuration error - please check manually${NC}"
fi

# Step 12: Start services
echo -e "${YELLOW}🚀 Step 12: Starting services...${NC}"

# Enable services to start on boot
systemctl enable nginx
systemctl enable studmgmt.service

# Start the services
systemctl restart nginx
systemctl start studmgmt.service

# Check status
sleep 2
if systemctl is-active --quiet studmgmt.service; then
    echo -e "${GREEN}✓ studmgmt.service started successfully${NC}"
else
    echo -e "${RED}❌ studmgmt.service failed to start - check logs${NC}"
    systemctl status studmgmt.service
fi

if systemctl is-active --quiet nginx; then
    echo -e "${GREEN}✓ Nginx started successfully${NC}"
else
    echo -e "${RED}❌ Nginx failed to start - check logs${NC}"
fi

# Step 13: Print summary
echo ""
echo -e "${BLUE}═════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Installation Complete!${NC}"
echo -e "${BLUE}═════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}📍 Installation Summary:${NC}"
echo "  Installation Directory: $INSTALL_DIR"
echo "  App User: $APP_USER"
echo "  Virtual Environment: $VENV_DIR"
echo "  Systemd Service: studmgmt.service"
echo "  Nginx Config: /etc/nginx/sites-available/studmgmt"
echo "  Log Directory: /var/log/studmgmt"
echo ""
echo -e "${YELLOW}🔧 Next Steps:${NC}"
echo "  1. Edit the .env file with your Gemini API key:"
echo "     nano $INSTALL_DIR/.env"
echo ""
echo "  2. Restart the service:"
echo "     sudo systemctl restart studmgmt.service"
echo ""
echo "  3. Check service status:"
echo "     sudo systemctl status studmgmt.service"
echo ""
echo "  4. View logs:"
echo "     sudo tail -f /var/log/studmgmt/access.log"
echo "     sudo tail -f /var/log/studmgmt/error.log"
echo ""
echo -e "${YELLOW}🌐 Access Your App:${NC}"
echo "  Open: http://your-server-ip"
echo "  (Nginx will proxy to the Flask app on port 8000)"
echo ""
echo -e "${YELLOW}📝 Useful Commands:${NC}"
echo "  Start service:    sudo systemctl start studmgmt.service"
echo "  Stop service:     sudo systemctl stop studmgmt.service"
echo "  Restart service:  sudo systemctl restart studmgmt.service"
echo "  View status:      sudo systemctl status studmgmt.service"
echo "  View logs:        sudo journalctl -u studmgmt.service -f"
echo "  Test nginx:       sudo nginx -t"
echo "  Reload nginx:     sudo systemctl reload nginx"
echo ""
echo -e "${BLUE}═════════════════════════════════════════════════════════════${NC}"

