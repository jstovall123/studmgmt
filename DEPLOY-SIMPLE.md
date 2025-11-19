# 🚀 Simple Linux Deployment - Clone & Run

Deploy the Student Management System in **3 simple steps**.

---

## 📋 Prerequisites

- Ubuntu 20.04, 22.04, or 24.04 LTS server
- Root access (or sudo)
- 2GB RAM, 20GB storage
- Your Gemini API key (from https://aistudio.google.com/apikey)

---

## ⚡ Deploy in 3 Steps

### Step 1: SSH to Your Server

```bash
ssh root@your-server-ip
```

### Step 2: Clone & Install

```bash
# Clone the repository to /opt/studmgmt
git clone https://github.com/jstovall123/studmgmt.git /opt/studmgmt

# Navigate to the directory
cd /opt/studmgmt

# Run the installation script
sudo bash install-linux.sh
```

**The script will:**
- Install all system packages
- Set up Python virtual environment
- Create systemd service (`studmgmt.service`)
- Configure Nginx reverse proxy
- Start all services
- **Takes 2-3 minutes**

### Step 3: Add Your API Key

```bash
# Edit configuration
sudo nano /opt/studmgmt/.env
```

Find this line:
```
GEMINI_API_KEY=your_api_key_here
```

Replace `your_api_key_here` with your actual Gemini API key.

Save with: `Ctrl+O`, `Enter`, `Ctrl+X`

### Step 4: Restart Service

```bash
sudo systemctl restart studmgmt.service
```

---

## ✅ Done!

**Access your app at:**
```
http://your-server-ip
```

That's it! 🎉

---

## 🔍 Verify Everything Works

### Check Service Status

```bash
sudo systemctl status studmgmt.service
```

Should show: **Active (running)**

### Check App is Responsive

```bash
curl http://localhost
# Should return HTML
```

### View Logs

```bash
sudo journalctl -u studmgmt.service -n 20
```

---

## 🧠 What Gets Installed

```
/opt/studmgmt/                    Application directory
├── app.py                        Flask backend
├── templates/index.html          Frontend
├── venv/                         Python environment
├── data/                         Student data storage
└── .env                          Configuration

/etc/systemd/system/
└── studmgmt.service              Auto-start service

/etc/nginx/sites-available/
└── studmgmt                       Web server config

/var/log/studmgmt/                Application logs
```

---

## 🔧 Common Commands

```bash
# Check status
sudo systemctl status studmgmt.service

# Restart service
sudo systemctl restart studmgmt.service

# View logs
sudo journalctl -u studmgmt.service -f

# Stop service
sudo systemctl stop studmgmt.service

# Start service
sudo systemctl start studmgmt.service
```

---

## 🆘 Troubleshooting

### Service won't start

```bash
# Check logs
sudo journalctl -u studmgmt.service -n 50

# Most likely: API key not set
# Edit .env and add your Gemini API key
sudo nano /opt/studmgmt/.env
sudo systemctl restart studmgmt.service
```

### Can't access from browser

```bash
# Check Nginx
sudo systemctl status nginx

# Check app is listening
sudo netstat -tlnp | grep 8000

# Test locally
curl http://localhost
```

### Something isn't working

1. Check logs: `sudo journalctl -u studmgmt.service -f`
2. Verify API key: `sudo cat /opt/studmgmt/.env`
3. Restart: `sudo systemctl restart studmgmt.service`
4. For more help, see DEPLOY-LINUX.md

---

## 📚 Need More Details?

- **DEPLOY-LINUX.md** - Complete guide with all options
- **DEPLOY-CHECKLIST.md** - Verification checklist
- **README.md** - Feature documentation

---

*That's it! Your app is live!* 🎵

**Repository:** https://github.com/jstovall123/studmgmt.git

