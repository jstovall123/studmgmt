# 🚀 Deployment Checklist

Use this checklist to deploy to your Linux server at `/opt/studmgmt/`.

---

## 📋 Pre-Deployment (On Your Local Machine)

- [ ] Have your Linode/server IP address ready
- [ ] Have SSH access configured
- [ ] Have your Gemini API key ready
- [ ] All project files are in `/Users/jamesstovall/Cursor Projects/sebo-project/`

---

## 🔗 Server Connection

- [ ] SSH into server:
  ```bash
  ssh root@your-server-ip
  ```

---

## 📦 Clone Repository

On **your server**:

```bash
# Clone the repository
git clone https://github.com/jstovall123/studmgmt.git /opt/studmgmt

# Navigate to directory
cd /opt/studmgmt
```

- [ ] Repository cloned to `/opt/studmgmt/`

---

## 🚀 Run Installation

On **your server**:

```bash
sudo bash install-linux.sh
```

The script will:

- [ ] Update system packages
- [ ] Install Python, Nginx, dependencies
- [ ] Create `studmgmt` system user
- [ ] Set up Python virtual environment
- [ ] Verify application files are in place
- [ ] Install Python packages
- [ ] Create systemd service
- [ ] Configure Nginx
- [ ] Start all services

**Installation takes 2-3 minutes**

- [ ] Installation script completed successfully

---

## 🔐 Configure API Key

On **your server**:

```bash
sudo nano /opt/studmgmt/.env
```

- [ ] Open `.env` file in nano
- [ ] Find: `GEMINI_API_KEY=your_api_key_here`
- [ ] Replace with your actual API key
- [ ] Save: `Ctrl+O`, `Enter`, `Ctrl+X`

---

## 🔄 Restart Service

```bash
sudo systemctl restart studmgmt.service
```

- [ ] Service restarted

---

## ✅ Verify Installation

### Check Service Status

```bash
sudo systemctl status studmgmt.service
```

Should show: **Active (running)**

- [ ] Service is running

### Check Nginx Status

```bash
sudo systemctl status nginx
```

Should show: **Active (running)**

- [ ] Nginx is running

### Check Port Listening

```bash
sudo netstat -tlnp | grep -E ':(80|8000)'
```

Should show:
- Port 80 (Nginx)
- Port 8000 (Gunicorn)

- [ ] Both ports are listening

### View Recent Logs

```bash
sudo journalctl -u studmgmt.service -n 20
```

Should show no errors

- [ ] Logs look good

---

## 🌐 Test in Browser

Open your browser and visit:

```
http://your-server-ip
```

You should see:
- Title: "Music Student Progress Tracker"
- Form to add students
- Empty student list

- [ ] App loads in browser

### Test Adding a Student

1. Fill in the form:
   - Name: "Test"
   - Instrument: "Piano"
   - Skill Level: "Beginner"
   - Books: "Test Book"
2. Click "Add Student"
3. Student appears in table

- [ ] Can add students

### Test AI Feature

1. Click "Generate Recs" on your test student
2. Wait 10-15 seconds
3. Should see 5 song recommendations

- [ ] AI features work

---

## 📊 Optional: Monitor Logs

Check logs in real-time:

```bash
# App logs
sudo tail -f /var/log/studmgmt/access.log

# Or error logs
sudo tail -f /var/log/studmgmt/error.log

# Or system logs
sudo journalctl -u studmgmt.service -f
```

- [ ] Logs accessible

---

## 🔐 Security Setup (Optional but Recommended)

### Enable Firewall

```bash
sudo ufw allow 22/tcp     # SSH
sudo ufw allow 80/tcp     # HTTP
sudo ufw enable
```

- [ ] Firewall enabled (optional)

### Setup HTTPS (Optional)

```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com
```

- [ ] HTTPS configured (optional)

### Backup Data

```bash
sudo cp -r /opt/studmgmt/data /opt/studmgmt/data.backup.$(date +%Y%m%d)
```

- [ ] Data backup created (optional)

---

## 📝 Post-Deployment

### Useful Commands to Remember

```bash
# Check service status
sudo systemctl status studmgmt.service

# View logs
sudo journalctl -u studmgmt.service -f

# Restart service
sudo systemctl restart studmgmt.service

# Stop service
sudo systemctl stop studmgmt.service

# Start service
sudo systemctl start studmgmt.service
```

### Edit Configuration

To change settings:

```bash
sudo nano /opt/studmgmt/.env
sudo systemctl restart studmgmt.service
```

### View Logs

```bash
# Recent logs
sudo tail -f /var/log/studmgmt/access.log

# Or all logs
sudo journalctl -u studmgmt.service -n 50
```

---

## 🎯 Testing Checklist

- [ ] Service starts automatically on boot (reboot to test)
- [ ] Service restarts automatically if crashed (kill process to test)
- [ ] Can access app at http://server-ip
- [ ] Can add students
- [ ] Can edit students
- [ ] Can generate recommendations (with API key)
- [ ] Can import Excel files
- [ ] Data persists after restart
- [ ] Logs are being created

---

## ⚠️ If Something Goes Wrong

### Service won't start

```bash
# Check logs
sudo journalctl -u studmgmt.service -n 50

# Check if port is in use
sudo netstat -tlnp | grep 8000

# Check file permissions
ls -la /opt/studmgmt/
```

### Can't access from browser

```bash
# Check nginx
sudo systemctl status nginx
sudo nginx -t

# Check app is listening
sudo netstat -tlnp | grep 8000

# Check firewall
sudo ufw status
```

### API key not working

```bash
# Check .env file
sudo cat /opt/studmgmt/.env

# Check permissions
sudo ls -la /opt/studmgmt/.env

# Verify key is correct
# Visit: https://aistudio.google.com/app/apikey
```

---

## 🎉 Deployment Complete!

If all checkboxes are checked:

✅ **Your app is live and ready to use!**

**Access at**: `http://your-server-ip`

**Manage with**: `sudo systemctl [start|stop|restart|status] studmgmt.service`

**View logs**: `sudo journalctl -u studmgmt.service -f`

---

## 🔄 Regular Maintenance

### Daily
- Nothing needed - service auto-restarts

### Weekly
- Check logs for errors
- Verify students can be added/edited

### Monthly
- Backup data: `sudo cp -r /opt/studmgmt/data /opt/studmgmt/data.backup.YYYYMMDD`
- Review resource usage: `top`
- Update system: `sudo apt-get update && apt-get upgrade -y`

### Quarterly
- Review firewall rules
- Check certificate expiry (if using HTTPS)
- Test restore from backup

---

## 📞 Support

If you need help:

1. Check logs: `sudo journalctl -u studmgmt.service -f`
2. Verify service: `sudo systemctl status studmgmt.service`
3. Test app: Open `http://server-ip` in browser
4. Check configuration: `sudo cat /opt/studmgmt/.env`

For detailed information, see: **DEPLOY-LINUX.md**

---

*Last Updated: January 19, 2025*
*Deployment Checklist v1.0*

