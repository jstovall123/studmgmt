# ✅ First Time Setup Checklist

Follow these steps **in order** to get your app running for the first time.

## Step 1: Check Prerequisites ✓

- [ ] You have Python 3.8 or higher
  ```bash
  python3 --version
  # Should show 3.8.0 or higher
  ```

- [ ] You have pip (Python package manager)
  ```bash
  pip3 --version
  # Should show a version number
  ```

**If either failed**, install Python from https://www.python.org/downloads/

---

## Step 2: Navigate to Project Folder ✓

```bash
cd /Users/jamesstovall/Cursor\ Projects/sebo-project
```

Verify you're in the right place:
```bash
ls -la
# Should see: app.py, requirements.txt, README.md, etc.
```

- [ ] You're in the sebo-project folder

---

## Step 3: Run the Startup Script ✓

```bash
./run.sh
```

This will:
- Create a Python virtual environment
- Install all dependencies
- Ask you which mode to run (Flask or Gunicorn)

- [ ] Run script completed without errors

---

## Step 4: Get Gemini API Key ✓

The AI features need a Google Gemini API key.

1. **Go to**: https://aistudio.google.com/apikey
2. **Click**: "Get API Key"
3. **Follow**: The prompts to create a key
4. **Copy**: Your API key (it looks like a long string)

- [ ] You have your API key copied

---

## Step 5: Create `.env` File ✓

In your terminal (still in the sebo-project folder):

```bash
cat > .env << 'EOF'
GEMINI_API_KEY=paste_your_key_here
FLASK_ENV=development
FLASK_DEBUG=True
EOF
```

**Replace** `paste_your_key_here` with your actual API key!

Verify it was created:
```bash
cat .env
# Should show your API key
```

- [ ] `.env` file created with API key

---

## Step 6: Activate Virtual Environment ✓

```bash
source venv/bin/activate
```

Your terminal should now show `(venv)` at the beginning of the line.

- [ ] Virtual environment is active (shows `(venv)` in terminal)

---

## Step 7: Run the App ✓

Choose one:

### Option A: Flask (Development)
```bash
python app.py
```

You should see:
```
 * Running on http://127.0.0.1:5000
```

### Option B: Gunicorn (Production-like)
```bash
gunicorn --workers 4 --bind 127.0.0.1:5000 app:app
```

You should see:
```
Listening at: http://127.0.0.1:5000
```

- [ ] App is running without errors

---

## Step 8: Open in Browser ✓

Open your web browser and go to:

```
http://localhost:5000
```

You should see:
- Title: "Music Student Progress Tracker"
- Input fields for adding students
- Empty student roster

- [ ] App loaded in browser successfully

---

## Step 9: Test Basic Features ✓

### Add a Test Student
1. Fill in the form:
   - Name: "Test Student"
   - Age: 12
   - Instrument: "Piano"
   - Skill Level: "Beginner"
   - Current Books: "Alfred's Method Book 1"
   - Goals: "Learn to read music"
2. Click "Add Student"
3. Student appears in the table

- [ ] You can add a student

### Edit the Student
1. Click "Edit" on the student row
2. Change something (e.g., age to 13)
3. Click "Save"
4. Changes appear in the table

- [ ] You can edit a student

### Test AI Feature
1. Click "Generate Recs" on your test student
2. Wait for AI to generate recommendations
3. You should see 5 song recommendations

*Note: If this fails, check your API key in `.env`*

- [ ] You can generate recommendations

---

## Step 10: Stop the App ✓

When done testing:

```bash
# Press Ctrl+C in the terminal
```

---

## ✨ Success! You're Done!

Your app is:
- ✅ Installed locally
- ✅ Running successfully
- ✅ Ready to use
- ✅ Ready to deploy

---

## 📚 What to Do Next

### Add Real Data
- Import your student list from an Excel file
- Or manually add students one by one

### Deploy to Server
- See SETUP.md for Linode/AWS/DigitalOcean instructions

### Customize
- Edit colors in templates/index.html
- Adjust AI prompts in app.py
- Add new features

### Get Help
- **Can't add students?** → Check app.py errors
- **AI not working?** → Check .env and API key
- **Port 5000 in use?** → Use a different port
- **More questions?** → See README.md or SETUP.md

---

## 🆘 Troubleshooting

### "ModuleNotFoundError: No module named 'flask'"

Make sure:
1. Virtual environment is activated: `source venv/bin/activate`
2. Requirements installed: `pip install -r requirements.txt`

### "API Key not working"

Check:
1. `.env` file exists in project root
2. No typos in API key
3. API key is valid at https://aistudio.google.com/app/apikey

### "Port 5000 already in use"

Use a different port:
```bash
gunicorn --workers 4 --bind 127.0.0.1:8000 app:app
# Then visit: http://localhost:8000
```

### "Permission denied when running run.sh"

Make it executable:
```bash
chmod +x run.sh
./run.sh
```

### Can't see app at localhost:5000

Try:
1. Copy exact URL: http://localhost:5000
2. Try http://127.0.0.1:5000 instead
3. Check terminal for error messages
4. Make sure app didn't crash

---

## 🎯 Quick Reference Commands

```bash
# Navigate to project
cd /Users/jamesstovall/Cursor\ Projects/sebo-project

# Auto setup
./run.sh

# Activate virtual environment
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run with Flask
python app.py

# Run with Gunicorn
gunicorn --workers 4 --bind 127.0.0.1:5000 app:app

# Stop app
Ctrl+C

# Exit virtual environment
deactivate

# View data file
cat data/students.json

# Backup data
cp data/students.json data/students.json.backup
```

---

## 📋 Checklist Summary

✅ Prerequisites checked  
✅ Project folder navigated  
✅ Startup script run  
✅ API key obtained  
✅ .env file created  
✅ Virtual environment activated  
✅ App running  
✅ Browser test successful  
✅ Basic features tested  
✅ App stopped  

**Status: 🎉 COMPLETE AND READY TO USE!**

---

*First Time Setup Guide*  
*Last Updated: January 19, 2025*

