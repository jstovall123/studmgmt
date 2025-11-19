# Music Student Progress Tracker - Setup Guide

This is a Flask-based local version of the Student Music Progress Tracker app. It runs on Gunicorn and stores data locally as JSON files.

## Prerequisites

- Python 3.8 or higher
- pip (Python package manager)

## Setup Instructions

### 1. Create Virtual Environment

```bash
cd /Users/jamesstovall/Cursor\ Projects/sebo-project
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Set Up Gemini API Key

This app uses Google's Generative AI (Gemini) to generate song recommendations, lesson plans, and journey reports.

1. Go to [Google AI Studio](https://aistudio.google.com/apikey)
2. Click "Get API Key"
3. Create a new API key in your Google Cloud project
4. Create a `.env` file in the project root:

```bash
cat > .env << 'EOF'
GEMINI_API_KEY=your_api_key_here
FLASK_ENV=development
FLASK_DEBUG=True
EOF
```

Replace `your_api_key_here` with your actual API key.

### 4. Run Locally (Development)

```bash
python app.py
```

The app will be available at: **http://localhost:5000**

### 5. Run with Gunicorn (Production-like)

```bash
gunicorn --workers 4 --bind 127.0.0.1:5000 app:app
```

For deployment on a Linux server (Linode, etc.):

```bash
gunicorn --workers 4 --bind 0.0.0.0:5000 app:app
```

## Project Structure

```
sebo-project/
├── app.py                 # Main Flask application
├── requirements.txt       # Python dependencies
├── templates/
│   └── index.html        # Frontend (HTML/CSS/JavaScript)
├── data/                 # Data directory (created automatically)
│   └── students.json    # Student data storage
├── venv/                 # Virtual environment
├── .env                  # Environment variables (create this)
└── SETUP.md             # This file
```

## Features

- ✅ Add and manage music students
- ✅ Import students from .XLSX files
- ✅ Generate song recommendations using AI
- ✅ Create 8-week lesson plans
- ✅ Draft musician's journey reports for parents/students
- ✅ Edit student information inline
- ✅ Responsive, beautiful UI with Tailwind CSS

## Environment Variables

```
GEMINI_API_KEY    # Your Google Gemini API key
FLASK_ENV         # Set to 'development' for local, 'production' for server
FLASK_DEBUG       # Set to True for development, False for production
```

## Troubleshooting

### "ModuleNotFoundError: No module named 'flask'"
Make sure you've activated the virtual environment and installed requirements:
```bash
source venv/bin/activate
pip install -r requirements.txt
```

### "GEMINI_API_KEY not configured"
Make sure you've:
1. Created a `.env` file in the project root
2. Added your Gemini API key to the `.env` file
3. Restarted the Flask app

### Can't access from other machines
If running on a server and can't connect from another machine:
- Change `127.0.0.1` to `0.0.0.0` in gunicorn command
- Make sure port 5000 is open in your firewall
- Use the server's IP address to access (e.g., `http://192.168.1.100:5000`)

## Deployment to Linux Server

### Quick Deploy with Systemd

1. SSH into your server and clone/copy the project
2. Follow steps 1-3 above (setup venv and .env)
3. Create a systemd service file at `/etc/systemd/system/music-tracker.service`:

```ini
[Unit]
Description=Music Student Progress Tracker
After=network.target

[Service]
User=www-data
WorkingDirectory=/path/to/sebo-project
Environment="PATH=/path/to/sebo-project/venv/bin"
ExecStart=/path/to/sebo-project/venv/bin/gunicorn --workers 4 --bind 0.0.0.0:5000 app:app

[Install]
WantedBy=multi-user.target
```

4. Enable and start the service:
```bash
sudo systemctl enable music-tracker
sudo systemctl start music-tracker
sudo systemctl status music-tracker
```

### Using Nginx as Reverse Proxy

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## Data Storage

Student data is stored in `data/students.json`. This is a local JSON file that persists between app restarts.

To backup your data:
```bash
cp data/students.json data/students.json.backup
```

## Support

For issues with:
- **AI Generation**: Check your Gemini API key and usage limits
- **File Uploads**: Make sure Excel files have the correct column headers
- **UI Issues**: Check browser console (F12) for JavaScript errors

---

**Version**: 1.0.0  
**Last Updated**: 2025-01-19

