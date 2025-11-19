# 🚀 Deploy to Linux Server - Complete Guide

This guide explains how to deploy the Student Management System to a Linux server with automated installation, systemd service, and Nginx reverse proxy.

---

## 📋 Overview

Your setup will be:

```
Internet
  ↓ (port 80)
Nginx (Reverse Proxy)
  ↓ (port 8000)
Gunicorn (Flask App)
  ↓
/opt/studmgmt/ (Application)
  ↓
systemd: studmgmt.service (Auto-start on boot)
```

---

## 🎯 Installation

### Prerequisites

- Ubuntu 20.04, 22.04, or 24.04 (or Debian-based Linux)
- SSH access to your server
- Root access (or sudo privileges)
- Your Gemini API key (get from https://aistudio.google.com/apikey)

### Step 1: SSH into Your Server

```bash
ssh root@your-server-ip
# or if you have a user with sudo:
ssh your-user@your-server-ip
```

### Step 2: Upload Installation Files

From your **local machine**:

```bash
# Copy all project files to server
scp -r /Users/jamesstovall/Cursor\ Projects/sebo-project/* root@your-server-ip:/tmp/studmgmt/

# Or clone from git if you have a repo
ssh root@your-server-ip
git clone your-repo-url /tmp/studmgmt
cd /tmp/studmgmt
```

### Step 3: Run Installation Script

On the **server**, as root:

```bash
cd /tmp/studmgmt
sudo bash install-linux.sh
```

This script will:
- ✅ Install Python, Nginx, and dependencies
- ✅ Create `/opt/studmgmt/` directory
- ✅ Create `studmgmt` system user
- ✅ Set up Python virtual environment
- ✅ Copy application files
- ✅ Install Python dependencies
- ✅ Create systemd service file
- ✅ Configure Nginx
- ✅ Start all services

The script takes about 2-3 minutes.

### Step 4: Configure API Key

After installation completes:

```bash
# Edit the .env file
sudo nano /opt/studmgmt/.env
```

Find this line:
```
GEMINI_API_KEY=your_api_key_here
```

Replace `your_api_key_here` with your actual Gemini API key.

Save with: `Ctrl+O`, `Enter`, `Ctrl+X`

### Step 5: Restart Service

```bash
sudo systemctl restart studmgmt.service
```

### Step 6: Test Your App

Open your browser and visit:
```
http://your-server-ip
```

You should see the Student Management System interface.

---

## ⚙️ Configuration Details

### Application Directory Structure

After installation:

```
/opt/studmgmt/
├── app.py                    # Flask application
├── requirements.txt          # Python packages
├── templates/
│   └── index.html           # Frontend
├── data/
│   └── students.json        # Student data (auto-created)
├── venv/                    # Python virtual environment
├── .env                     # Configuration (API keys)
└── .env.template            # Configuration template
```

### Configuration File (.env)

Located at: `/opt/studmgmt/.env`

```bash
# Gemini API Configuration
GEMINI_API_KEY=your_api_key_here

# Flask Configuration
FLASK_ENV=production
FLASK_DEBUG=False

# Server Configuration
GUNICORN_WORKERS=4
GUNICORN_HOST=127.0.0.1
GUNICORN_PORT=8000
```

**Only the API key needs to be changed for basic operation.**

### Systemd Service

Located at: `/etc/systemd/system/studmgmt.service`

Key details:
- **User**: `studmgmt` (dedicated app user)
- **Working Directory**: `/opt/studmgmt`
- **Port**: 8000 (internal, proxied by Nginx)
- **Workers**: 4 Gunicorn workers
- **Logs**: `/var/log/studmgmt/`
- **Auto-restart**: On failure

### Nginx Configuration

Located at: `/etc/nginx/sites-available/studmgmt`

Key details:
- **Listen**: Port 80 (HTTP)
- **Upstream**: Proxies to `127.0.0.1:8000` (Gunicorn)
- **Max Upload Size**: 20 MB
- **Logs**: `/var/log/nginx/studmgmt_*.log`

---

## 📊 Useful Commands

### Service Management

```bash
# Start the service
sudo systemctl start studmgmt.service

# Stop the service
sudo systemctl stop studmgmt.service

# Restart the service
sudo systemctl restart studmgmt.service

# View service status
sudo systemctl status studmgmt.service

# Enable on boot (should already be done)
sudo systemctl enable studmgmt.service

# Disable on boot
sudo systemctl disable studmgmt.service

# View recent logs
sudo journalctl -u studmgmt.service -f

# View last 50 lines
sudo journalctl -u studmgmt.service -n 50
```

### Application Logs

```bash
# View access logs
sudo tail -f /var/log/studmgmt/access.log

# View error logs
sudo tail -f /var/log/studmgmt/error.log

# View both simultaneously (in tmux/screen)
sudo tail -f /var/log/studmgmt/*.log
```

### Nginx Commands

```bash
# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx

# Restart Nginx
sudo systemctl restart nginx

# View Nginx logs
sudo tail -f /var/log/nginx/studmgmt_access.log
sudo tail -f /var/log/nginx/studmgmt_error.log
```

### Manual Restart Sequence

If you need to restart everything:

```bash
# 1. Restart the app
sudo systemctl restart studmgmt.service

# 2. Reload Nginx
sudo systemctl reload nginx

# 3. Check status
sudo systemctl status studmgmt.service
sudo systemctl status nginx
```

---

## 🔧 Troubleshooting

### Service Won't Start

Check the logs:
```bash
sudo journalctl -u studmgmt.service -n 50
```

Common issues:
- **Missing API key** → Edit `/opt/studmgmt/.env` and add Gemini key
- **Port 8000 in use** → Change `GUNICORN_PORT` in `.env`
- **Permission error** → Check file ownership: `ls -la /opt/studmgmt/`

### Can't Access App from Browser

Check Nginx is running:
```bash
sudo systemctl status nginx
sudo nginx -t
```

Check app is listening:
```bash
sudo netstat -tlnp | grep 8000
```

### Slow Performance

Increase Gunicorn workers:
```bash
sudo nano /etc/systemd/system/studmgmt.service
# Change "workers 4" to "workers 8" (or more)
sudo systemctl daemon-reload
sudo systemctl restart studmgmt.service
```

### Data Not Persisting

Check data directory permissions:
```bash
ls -la /opt/studmgmt/data/
sudo chown studmgmt:studmgmt /opt/studmgmt/data -R
```

---

## 🔐 Security Considerations

### HTTPS/SSL

For production with HTTPS, use Let's Encrypt:

```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

### Firewall

Open only necessary ports:

```bash
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS (if using SSL)
sudo ufw enable
```

### Data Backups

Backup your student data regularly:

```bash
# Manual backup
sudo cp -r /opt/studmgmt/data /opt/studmgmt/data.backup.$(date +%Y%m%d)

# Or automate with cron
sudo crontab -e
# Add: 0 2 * * * cp -r /opt/studmgmt/data /opt/studmgmt/data.backup.$(date +\%Y\%m\%d)
```

### API Key Security

- ✅ Stored in `.env` (not in version control)
- ✅ File permissions: 600 (read/write for owner only)
- ✅ Only read by `studmgmt` user
- ✅ Not exposed in code

Check permissions:
```bash
sudo ls -la /opt/studmgmt/.env
# Should show: -rw------- 1 studmgmt studmgmt
```

---

## 📈 Scaling & Performance

### Increase Gunicorn Workers

For more concurrent requests, increase workers:

```bash
sudo nano /etc/systemd/system/studmgmt.service
```

Find the line with `--workers 4` and change to `--workers 8` (or more).

Rule of thumb: `workers = (2 × CPU cores) + 1`

```bash
sudo systemctl daemon-reload
sudo systemctl restart studmgmt.service
```

### Monitor Performance

```bash
# Check CPU/memory usage
top -p $(pgrep -f 'gunicorn')

# Check open connections
sudo netstat -antp | grep 8000

# Check app request rate
sudo tail -f /var/log/studmgmt/access.log
```

---

## 🎓 Advanced Configuration

### Custom Domain

Edit Nginx config:
```bash
sudo nano /etc/nginx/sites-available/studmgmt
```

Change:
```nginx
server_name _;
```

To:
```nginx
server_name yourdomain.com www.yourdomain.com;
```

Then:
```bash
sudo systemctl reload nginx
```

### Custom Port

Change default HTTP port:
```bash
sudo nano /etc/nginx/sites-available/studmgmt
# Change "listen 80;" to "listen 8080;"
sudo systemctl reload nginx
```

### Environment Variables

Edit `/opt/studmgmt/.env` to customize:
```bash
# Number of Gunicorn workers
GUNICORN_WORKERS=8

# Bind address
GUNICORN_HOST=127.0.0.1

# Port (internal, behind Nginx)
GUNICORN_PORT=8000

# Flask environment
FLASK_ENV=production

# Debug mode
FLASK_DEBUG=False
```

Then restart:
```bash
sudo systemctl restart studmgmt.service
```

---

## 📝 File Reference

### Created Files

| File | Purpose | Permissions |
|------|---------|-------------|
| `/opt/studmgmt/app.py` | Flask backend | studmgmt user |
| `/opt/studmgmt/.env` | Configuration | 600 (private) |
| `/opt/studmgmt/venv/` | Python environment | studmgmt user |
| `/var/log/studmgmt/` | App logs | studmgmt user |
| `/etc/systemd/system/studmgmt.service` | Systemd service | root |
| `/etc/nginx/sites-available/studmgmt` | Nginx config | root |

### Log Locations

```
/var/log/studmgmt/access.log      # Gunicorn access log
/var/log/studmgmt/error.log       # Gunicorn error log
/var/log/nginx/studmgmt_access.log # Nginx access log
/var/log/nginx/studmgmt_error.log  # Nginx error log
/var/log/syslog                    # System logs
```

---

## 🚨 Emergency Procedures

### Stop All Services

```bash
sudo systemctl stop studmgmt.service
sudo systemctl stop nginx
```

### Start All Services

```bash
sudo systemctl start studmgmt.service
sudo systemctl start nginx
```

### Check Everything is Running

```bash
sudo systemctl status studmgmt.service
sudo systemctl status nginx
sudo netstat -tlnp | grep -E ':(80|8000)'
```

### Restore from Backup

```bash
sudo systemctl stop studmgmt.service
sudo rm -rf /opt/studmgmt/data
sudo cp -r /opt/studmgmt/data.backup.YYYYMMDD /opt/studmgmt/data
sudo chown studmgmt:studmgmt /opt/studmgmt/data -R
sudo systemctl start studmgmt.service
```

---

## 📞 Getting Help

### Check System Logs

```bash
# All systemd logs
sudo journalctl -xe

# App-specific logs
sudo journalctl -u studmgmt.service -n 100

# Nginx logs
sudo tail -50 /var/log/nginx/studmgmt_error.log
```

### Verify Installation

```bash
# Check Python
/opt/studmgmt/venv/bin/python3 --version

# Check Gunicorn
/opt/studmgmt/venv/bin/gunicorn --version

# Check Nginx
nginx -v

# Check if app port is listening
sudo netstat -tlnp | grep 8000

# Check if Nginx is listening
sudo netstat -tlnp | grep 80
```

---

## 🎉 What You Now Have

✅ Application running at `/opt/studmgmt/`  
✅ Systemd service for auto-start on boot  
✅ Nginx reverse proxy on port 80  
✅ Gunicorn running on port 8000 (internal)  
✅ Automatic logging  
✅ Secure configuration  
✅ Easy management via systemctl  

Your app will:
- Start automatically when server boots
- Restart automatically if it crashes
- Log all errors and access
- Be accessible at your server's IP/domain

---

## 🔄 Updating the Application

When you have new code:

```bash
# 1. Upload new files
scp app.py root@server:/opt/studmgmt/
scp -r templates root@server:/opt/studmgmt/

# 2. Restart the service
ssh root@server
sudo systemctl restart studmgmt.service

# 3. Check status
sudo systemctl status studmgmt.service
```

---

## 📚 Reference Links

- [Systemd Documentation](https://www.freedesktop.org/software/systemd/man/latest/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Gunicorn Documentation](https://gunicorn.org/)
- [Flask Documentation](https://flask.palletsprojects.com/)

---

*Last Updated: January 19, 2025*  
*Version: 1.0.0*

