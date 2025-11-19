# ⚡ Quick Reference - Clone & Deploy

The absolute simplest deployment guide.

---

## Copy/Paste These Commands

```bash
# SSH to your server
ssh root@your-server-ip

# Clone repository
git clone https://github.com/jstovall123/studmgmt.git /opt/studmgmt

# Run installer
cd /opt/studmgmt && sudo bash install-linux.sh

# Add API key
sudo nano /opt/studmgmt/.env
# Find: GEMINI_API_KEY=your_api_key_here
# Replace with your actual key
# Save: Ctrl+O, Enter, Ctrl+X

# Restart service
sudo systemctl restart studmgmt.service
```

---

## That's It!

Access your app at: `http://your-server-ip`

---

## If Something Goes Wrong

```bash
# Check status
sudo systemctl status studmgmt.service

# View logs
sudo journalctl -u studmgmt.service -f

# Restart
sudo systemctl restart studmgmt.service
```

---

## Repository

**GitHub:** https://github.com/jstovall123/studmgmt.git

---

*Your Student Management System is now live!* 🎵

