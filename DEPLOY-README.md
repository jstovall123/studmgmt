# 📦 Linux Server Deployment Setup

Your application is now ready for automated deployment to a Linux server with:
- **Installation location**: `/opt/studmgmt/`
- **Service name**: `studmgmt.service` (systemd)
- **Web server**: Nginx (reverse proxy)
- **App server**: Gunicorn (Flask)
- **Auto-start**: Yes (systemd)

---

## 🚀 Quick Start (3 Steps)

### Step 1: Copy Files to Server

From your local machine:

```bash
cd /Users/jamesstovall/Cursor\ Projects/sebo-project
scp -r * root@your-linode-ip:/tmp/studmgmt/
```

### Step 2: Run Installation

On your server:

```bash
ssh root@your-linode-ip
cd /tmp/studmgmt
sudo bash install-linux.sh
```

### Step 3: Configure & Restart

```bash
sudo nano /opt/studmgmt/.env
# Add your Gemini API key
sudo systemctl restart studmgmt.service
```

**Done!** Access at `http://your-server-ip`

---

## 📚 Documentation Files

| File | Purpose |
|------|---------|
| **install-linux.sh** | Automated installation script |
| **DEPLOY-LINUX.md** | Detailed deployment guide |
| **DEPLOY-CHECKLIST.md** | Step-by-step checklist |
| **DEPLOY-README.md** | This file |

---

## 📝 What Gets Installed

```
/opt/studmgmt/                    Application directory
├── app.py                        Flask backend
├── templates/index.html          Frontend
├── requirements.txt              Python packages
├── venv/                         Virtual environment
├── data/                         Student data
├── .env                          Configuration (API keys)
└── .env.template                Configuration template

/etc/systemd/system/              
└── studmgmt.service              Auto-start service

/etc/nginx/sites-available/
└── studmgmt                       Nginx configuration

/var/log/studmgmt/                Application logs
├── access.log                    Request logs
└── error.log                     Error logs
```

---

## ⚙️ Architecture

```
┌─ Internet User
│
├─ Port 80 (HTTP)
│
├─ Nginx (Reverse Proxy)
│  /etc/nginx/sites-available/studmgmt
│
├─ Port 8000 (localhost only)
│
├─ Gunicorn (Flask App)
│  /opt/studmgmt/app.py
│  4 worker processes
│  Started by: studmgmt.service
│
└─ Application Data
   /opt/studmgmt/data/students.json
```

---

## 🔧 Installation Features

The `install-linux.sh` script automatically:

✅ Updates system packages  
✅ Installs Python 3, Nginx, and dependencies  
✅ Creates `/opt/studmgmt/` directory  
✅ Creates `studmgmt` system user  
✅ Sets up Python virtual environment  
✅ Copies application files  
✅ Installs Python packages from requirements.txt  
✅ Creates systemd service file (`studmgmt.service`)  
✅ Configures Nginx as reverse proxy  
✅ Creates log directory with proper permissions  
✅ Enables services to start on boot  
✅ Starts all services immediately  

---

## 🎯 After Installation

Your application will:

- Run at: `http://your-server-ip` (via Nginx port 80)
- Backend at: `http://your-server-ip:8000` (Gunicorn, internal only)
- Auto-start when server boots
- Auto-restart if it crashes
- Log all access and errors
- Run as dedicated `studmgmt` user (security)

---

## 🔐 Configuration

### API Key Setup

Edit: `/opt/studmgmt/.env`

```bash
GEMINI_API_KEY=your_key_here
FLASK_ENV=production
FLASK_DEBUG=False
```

### Gunicorn Workers

Default: 4 workers

To increase (for more concurrent users):

Edit: `/etc/systemd/system/studmgmt.service`

Change `--workers 4` to `--workers 8` (or more)

Then restart: `sudo systemctl restart studmgmt.service`

### Nginx Custom Domain

Edit: `/etc/nginx/sites-available/studmgmt`

Change `server_name _;` to `server_name yourdomain.com;`

---

## 📊 Service Management

### Common Commands

```bash
# Start service
sudo systemctl start studmgmt.service

# Stop service
sudo systemctl stop studmgmt.service

# Restart service
sudo systemctl restart studmgmt.service

# Check status
sudo systemctl status studmgmt.service

# View logs
sudo journalctl -u studmgmt.service -f

# View recent logs (50 lines)
sudo journalctl -u studmgmt.service -n 50

# Enable on boot
sudo systemctl enable studmgmt.service

# Disable on boot
sudo systemctl disable studmgmt.service
```

---

## 📝 Logs

### Application Logs

```bash
# Access log (who accessed what)
sudo tail -f /var/log/studmgmt/access.log

# Error log (what went wrong)
sudo tail -f /var/log/studmgmt/error.log

# Systemd journal
sudo journalctl -u studmgmt.service -f
```

### Nginx Logs

```bash
# Nginx access log
sudo tail -f /var/log/nginx/studmgmt_access.log

# Nginx error log
sudo tail -f /var/log/nginx/studmgmt_error.log
```

---

## 🔄 Updating the Application

When you have new code:

```bash
# 1. Upload new files
scp app.py root@server:/opt/studmgmt/
scp -r templates root@server:/opt/studmgmt/

# 2. Restart service
ssh root@server
sudo systemctl restart studmgmt.service

# 3. Verify
sudo systemctl status studmgmt.service
```

---

## 💾 Backup & Recovery

### Backup Data

```bash
# Manual backup
sudo cp -r /opt/studmgmt/data /opt/studmgmt/data.backup.$(date +%Y%m%d)

# List backups
ls -la /opt/studmgmt/data.backup*
```

### Restore Data

```bash
# Stop service
sudo systemctl stop studmgmt.service

# Restore from backup
sudo rm -rf /opt/studmgmt/data
sudo cp -r /opt/studmgmt/data.backup.YYYYMMDD /opt/studmgmt/data

# Fix permissions
sudo chown studmgmt:studmgmt /opt/studmgmt/data -R

# Start service
sudo systemctl start studmgmt.service
```

---

## 🔒 Security Notes

### File Permissions

```bash
# App files owned by studmgmt user
sudo ls -la /opt/studmgmt/

# .env has strict permissions (only owner can read)
sudo ls -la /opt/studmgmt/.env
# Should show: -rw------- 1 studmgmt studmgmt
```

### Firewall

Allow only necessary ports:

```bash
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS (if using SSL)
sudo ufw enable
```

### HTTPS Setup

Use Let's Encrypt (free SSL):

```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com
```

---

## 🆘 Troubleshooting

### Service Won't Start

```bash
# Check logs
sudo journalctl -u studmgmt.service -n 50

# Check if port is in use
sudo netstat -tlnp | grep 8000

# Check file permissions
sudo ls -la /opt/studmgmt/
```

### Can't Access from Browser

```bash
# Check Nginx is running
sudo systemctl status nginx
sudo nginx -t

# Check app is listening
sudo netstat -tlnp | grep 8000

# Check firewall
sudo ufw status
```

### API Key Not Working

```bash
# Verify .env has key
sudo cat /opt/studmgmt/.env

# Verify key is valid
# Visit: https://aistudio.google.com/app/apikey

# Restart service after updating key
sudo systemctl restart studmgmt.service
```

---

## 📖 Full Documentation

For detailed information, see:

- **DEPLOY-LINUX.md** - Complete deployment guide with all details
- **DEPLOY-CHECKLIST.md** - Step-by-step verification checklist
- **README.md** - General application documentation

---

## 🎯 Server Hosting Options

This setup works great on:

- **Linode** (Recommended)
- **DigitalOcean**
- **AWS EC2**
- **Google Cloud**
- **Azure**
- **Any Linux VPS**

Choose Ubuntu 20.04, 22.04, or 24.04 for best compatibility.

---

## 📋 Pre-Installation Checklist

Before running `install-linux.sh`:

- [ ] Linux server with SSH access
- [ ] Root or sudo privileges
- [ ] Gemini API key ready
- [ ] All project files copied to `/tmp/studmgmt/`

---

## ✅ Post-Installation Verification

After installation completes:

- [ ] Can access app at `http://server-ip`
- [ ] Can add students
- [ ] Can generate recommendations (AI)
- [ ] Service starts on boot (test with reboot)
- [ ] Logs are being created
- [ ] Data persists after restart

---

## 🚀 Quick Commands Reference

```bash
# SSH into server
ssh root@your-server-ip

# Run installer
cd /tmp/studmgmt && sudo bash install-linux.sh

# Edit configuration
sudo nano /opt/studmgmt/.env

# View service status
sudo systemctl status studmgmt.service

# View logs
sudo journalctl -u studmgmt.service -f

# Restart service
sudo systemctl restart studmgmt.service

# Restart nginx
sudo systemctl reload nginx

# Backup data
sudo cp -r /opt/studmgmt/data /opt/studmgmt/data.backup.$(date +%Y%m%d)
```

---

## 📞 Getting Started

1. **Read**: DEPLOY-CHECKLIST.md (5 min read)
2. **Copy**: Files to server
3. **Run**: `sudo bash install-linux.sh`
4. **Configure**: API key in `.env`
5. **Test**: Access in browser

That's it! 🎉

---

*Last Updated: January 19, 2025*  
*Version: 1.0.0*  
*Status: ✅ Production Ready*

