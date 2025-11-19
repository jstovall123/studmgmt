# 🐧 Linux Deployment Summary

## ✨ What's New

I've added comprehensive Linux deployment automation for your application. Everything needed to deploy to a Linux server at `/opt/studmgmt/` with systemd and Nginx.

---

## 📦 New Files Added

### Deployment Files

1. **`install-linux.sh`** - Automated installation script
   - ~350 lines
   - Handles entire setup automatically
   - Root user runs this once
   - Takes 2-3 minutes

2. **`DEPLOY-LINUX.md`** - Complete deployment guide
   - Step-by-step instructions
   - Configuration details
   - Troubleshooting guide
   - Security recommendations
   - Advanced configuration options

3. **`DEPLOY-CHECKLIST.md`** - Deployment verification checklist
   - Pre-deployment steps
   - Installation verification
   - Post-deployment testing
   - Emergency procedures

4. **`DEPLOY-README.md`** - Quick reference guide
   - Overview of what gets installed
   - Architecture diagram
   - Quick commands
   - FAQ

---

## 🎯 What Gets Installed

When you run `install-linux.sh`, it automatically:

### System Setup
- ✅ Updates all system packages
- ✅ Installs Python 3, Nginx, required dependencies
- ✅ Creates `/opt/studmgmt/` directory
- ✅ Creates dedicated `studmgmt` system user
- ✅ Sets up Python virtual environment

### Application Setup
- ✅ Copies all app files (app.py, templates, etc.)
- ✅ Installs Python packages from requirements.txt
- ✅ Creates data directory for student storage
- ✅ Creates .env configuration file

### Service Setup
- ✅ Creates systemd service file: `/etc/systemd/system/studmgmt.service`
- ✅ Service name: `studmgmt.service`
- ✅ Auto-start on boot enabled
- ✅ Auto-restart on crash enabled
- ✅ 4 Gunicorn workers configured
- ✅ Runs on port 8000 (internal, via Nginx)

### Web Server Setup
- ✅ Configures Nginx as reverse proxy
- ✅ Nginx listens on port 80 (HTTP)
- ✅ Proxies to Gunicorn on port 8000
- ✅ Allows 20 MB file uploads
- ✅ Nginx config at: `/etc/nginx/sites-available/studmgmt`

### Logging Setup
- ✅ Creates log directory: `/var/log/studmgmt/`
- ✅ Access logs: `access.log`
- ✅ Error logs: `error.log`
- ✅ Proper permissions set

---

## 🚀 How to Deploy

### The Simple Way (Recommended)

On **your server**:

```bash
# Clone repository directly to /opt/studmgmt
git clone https://github.com/jstovall123/studmgmt.git /opt/studmgmt

# Navigate to directory
cd /opt/studmgmt

# Run installation script
sudo bash install-linux.sh
```

That's it! The script will automatically detect the cloned files and complete the setup.

### Alternative: Copy Files

If you prefer to copy instead of git clone:

```bash
# On your local machine
scp -r /Users/jamesstovall/Cursor\ Projects/sebo-project/* root@your-server-ip:/opt/studmgmt/

# On your server
ssh root@your-server-ip
cd /opt/studmgmt
sudo bash install-linux.sh
```

The script will:
- Ask for confirmation (automatically proceeds)
- Install everything
- Start services
- Show summary

**Takes 2-3 minutes**

### Step 4: Configure API Key

```bash
sudo nano /opt/studmgmt/.env
```

Find and replace:
```
GEMINI_API_KEY=your_api_key_here
```

Save with: `Ctrl+O`, `Enter`, `Ctrl+X`

### Step 5: Restart Service

```bash
sudo systemctl restart studmgmt.service
```

### Step 6: Access Your App

Open browser and visit:
```
http://your-server-ip
```

**Done!** 🎉

---

## ⚙️ Architecture

```
Internet (Port 80)
    ↓
Nginx (Reverse Proxy)
    ↓
Gunicorn (Port 8000, Internal)
    ↓
Flask App (/opt/studmgmt/app.py)
    ↓
systemd Service (studmgmt.service)
    ↓
Auto-start on Boot + Auto-restart on Crash
```

---

## 📝 File Locations

After installation:

```
/opt/studmgmt/                    # Application home
├── app.py                        # Flask backend
├── templates/index.html          # Frontend
├── requirements.txt              # Python packages
├── venv/                         # Virtual environment
├── data/students.json            # Student data
├── .env                          # Configuration (your API key)
└── .env.template                 # Configuration template

/etc/systemd/system/              # Systemd services
└── studmgmt.service              # Auto-start service

/etc/nginx/                       # Nginx web server
└── sites-available/studmgmt      # Nginx config

/var/log/studmgmt/                # Application logs
├── access.log                    # Request logs
└── error.log                     # Error logs

/var/log/nginx/                   # Nginx logs
└── studmgmt_*.log
```

---

## 🔧 Service Management

### Check Status

```bash
sudo systemctl status studmgmt.service
```

### Start/Stop/Restart

```bash
sudo systemctl start studmgmt.service
sudo systemctl stop studmgmt.service
sudo systemctl restart studmgmt.service
```

### View Logs

```bash
# Real-time logs
sudo journalctl -u studmgmt.service -f

# Last 50 lines
sudo journalctl -u studmgmt.service -n 50

# Access logs
sudo tail -f /var/log/studmgmt/access.log

# Error logs
sudo tail -f /var/log/studmgmt/error.log
```

---

## 🔐 Security Features

- ✅ Dedicated system user (`studmgmt`) - not root
- ✅ Private .env file (600 permissions) - only owner can read
- ✅ Nginx handles public HTTP
- ✅ Gunicorn runs on localhost only (127.0.0.1)
- ✅ Proper log permissions
- ✅ Firewall-ready (open only needed ports)

---

## 📋 What You Need on Linode

### Server Specs
- **Image**: Ubuntu 20.04, 22.04, or 24.04 LTS
- **Size**: 2GB RAM minimum (4GB+ recommended)
- **Storage**: 20GB+ SSD
- **Root Password**: Set during creation

### After Creation
- Get IP address
- SSH access configured
- Have Gemini API key ready

---

## 🎯 Deployment Timeline

| Step | Time | Action |
|------|------|--------|
| 1 | 1 min | Copy files to server |
| 2 | 2-3 min | Run `install-linux.sh` |
| 3 | 1 min | Edit `.env` with API key |
| 4 | 1 min | Restart service |
| 5 | 1 min | Test in browser |
| **Total** | **6-7 min** | **Complete deployment** |

---

## ✅ Verification Steps

After installation, verify everything:

```bash
# 1. Service is running
sudo systemctl status studmgmt.service
# Should show: Active (running)

# 2. App is listening on port 8000
sudo netstat -tlnp | grep 8000
# Should show: LISTEN 127.0.0.1:8000

# 3. Nginx is running
sudo systemctl status nginx
# Should show: Active (running)

# 4. Nginx is listening on port 80
sudo netstat -tlnp | grep :80
# Should show: LISTEN 0.0.0.0:80

# 5. Test in browser
# Open: http://your-server-ip
# Should see: Student Management System interface
```

---

## 🔄 Regular Maintenance

### Daily
- Automatic (service manages itself)

### Weekly
- Check logs: `sudo journalctl -u studmgmt.service | grep -i error`
- Verify app works

### Monthly
- Backup data: `sudo cp -r /opt/studmgmt/data /backup/studmgmt-backup-$(date +%Y%m%d)`
- Review performance: `top`
- Update system: `sudo apt-get update && apt-get upgrade -y`

---

## 🆘 Common Issues & Fixes

### Service won't start

```bash
# Check logs
sudo journalctl -u studmgmt.service -n 50

# Likely issues:
# - API key not set → Edit .env and add key
# - Port 8000 in use → Check what's using it
# - File permissions → Run: sudo chown -R studmgmt:studmgmt /opt/studmgmt/
```

### Can't access from browser

```bash
# Check Nginx
sudo systemctl status nginx
sudo nginx -t

# Check ports
sudo netstat -tlnp | grep -E ':(80|8000)'

# Check firewall
sudo ufw status
```

### API not working

```bash
# Verify key in .env
sudo cat /opt/studmgmt/.env

# Restart service
sudo systemctl restart studmgmt.service

# Check if AI is enabled in code
# Check Gemini API quota: https://aistudio.google.com/app/apikey
```

---

## 📚 Documentation Files

For complete information, read:

1. **DEPLOY-CHECKLIST.md** - Start here!
   - Step-by-step verification
   - Pre/post deployment checks
   - Quick commands

2. **DEPLOY-LINUX.md** - Detailed guide
   - Complete instructions
   - Configuration options
   - Troubleshooting
   - Advanced setup (HTTPS, custom domains, etc.)

3. **DEPLOY-README.md** - Quick reference
   - Architecture overview
   - Common commands
   - FAQ

4. **install-linux.sh** - The automation
   - Read through to understand what it does
   - Modify if needed for custom setup

---

## 🎓 Understanding systemd Service

Your `studmgmt.service` file:

```ini
[Unit]
Description=Student Management System
After=network.target nginx.service    # Start after network & nginx

[Service]
Type=notify                           # Service notification
User=studmgmt                        # Run as this user
Group=studmgmt                       # Run as this group
WorkingDirectory=/opt/studmgmt       # Working directory
EnvironmentFile=/opt/studmgmt/.env   # Load .env variables
ExecStart=...gunicorn...             # Start command
Restart=on-failure                   # Restart if crashes
RestartSec=5s                        # Wait 5 sec before restart

[Install]
WantedBy=multi-user.target           # Start with system
```

Benefits:
- Auto-starts on boot
- Auto-restarts if it crashes
- Logs go to systemd journal
- Easy to manage with `systemctl`

---

## 🌟 Next Steps

1. **Test locally first** (if not already done)
   ```bash
   ./run.sh
   # Should work at http://localhost:5000
   ```

2. **Prepare Linode server**
   - Create Ubuntu 22.04 LTS instance
   - Get IP address
   - Configure SSH key

3. **Deploy**
   - Copy files: `scp -r * root@ip:/tmp/studmgmt/`
   - Run installer: `ssh root@ip 'cd /tmp/studmgmt && sudo bash install-linux.sh'`
   - Configure: `ssh root@ip 'sudo nano /opt/studmgmt/.env'`
   - Test: Open `http://your-ip` in browser

4. **Maintain**
   - Monitor logs
   - Backup data periodically
   - Update system packages monthly

---

## 💡 Pro Tips

### Set a Cron Job for Backups

```bash
# SSH to server
ssh root@your-ip

# Edit crontab
sudo crontab -e

# Add this line (backup daily at 2 AM):
0 2 * * * cp -r /opt/studmgmt/data /opt/studmgmt/backups/studmgmt-data.$(date +\%Y\%m\%d)
```

### Monitor in Real-Time

```bash
# Watch logs while testing
sudo tail -f /var/log/studmgmt/access.log

# In another terminal, test the app
curl http://localhost/api/students
```

### Scale Gunicorn Workers

If you get "connection refused" errors:

```bash
# Increase workers
sudo nano /etc/systemd/system/studmgmt.service
# Change --workers 4 to --workers 8
sudo systemctl daemon-reload
sudo systemctl restart studmgmt.service
```

---

## 📞 Support Resources

- **Systemd**: `man systemd.service` or https://www.freedesktop.org/software/systemd/man/
- **Nginx**: `nginx -h` or https://nginx.org/en/docs/
- **Gunicorn**: `gunicorn -h` or https://gunicorn.org/
- **Flask**: https://flask.palletsprojects.com/
- **Linux**: `man` command for any tool (e.g., `man systemctl`)

---

## ✨ You're All Set!

Everything is ready for Linux deployment:

✅ Automated installation script  
✅ Systemd service configuration  
✅ Nginx reverse proxy setup  
✅ Complete documentation  
✅ Verification checklist  
✅ Troubleshooting guide  

**Next step**: Read DEPLOY-CHECKLIST.md and deploy! 🚀

---

*Created: January 19, 2025*  
*Version: 1.0.0*  
*Status: ✅ Production Ready*

