# 🎵 Music Student Progress Tracker

A beautiful, AI-powered Flask application for music teachers to manage students, generate song recommendations, and create personalized lesson plans.

## ✨ Features

- **Student Management** - Add, edit, and organize student information
- **AI-Powered Recommendations** - Generate 5 tailored song recommendations for each student
- **8-Week Lesson Plans** - Automatically create structured lesson plans based on student materials and goals
- **Musician's Journey Reports** - Draft encouraging progress reports for parents/students (simplified for non-musicians)
- **Bulk Import** - Import students from Excel (.xlsx) files
- **Local Storage** - All data stored locally as JSON (no cloud dependencies)
- **Beautiful UI** - Modern, responsive design with Tailwind CSS
- **Gunicorn Ready** - Production-ready with Gunicorn WSGI server

## 🚀 Quick Start

### Option 1: Auto-Setup Script (Recommended)

```bash
cd /Users/jamesstovall/Cursor\ Projects/sebo-project
./run.sh
```

This will:
- Create a Python virtual environment
- Install all dependencies
- Let you choose between Flask or Gunicorn
- Start the app on http://localhost:5000

### Option 2: Manual Setup

```bash
# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Set up Gemini API key
cat > .env << 'EOF'
GEMINI_API_KEY=your_api_key_here
FLASK_ENV=development
FLASK_DEBUG=True
EOF

# Run the app
python app.py
# or with Gunicorn:
gunicorn --workers 4 --bind 127.0.0.1:5000 app:app
```

## 📋 Getting Your API Key

This app uses Google's Generative AI (Gemini) for AI features. You need an API key:

1. Go to [Google AI Studio](https://aistudio.google.com/apikey)
2. Click "Get API Key"
3. Follow the prompts to create one in your Google Cloud project
4. Paste it in your `.env` file:

```
GEMINI_API_KEY=your_key_here
```

**Note**: The free tier of Gemini API has generous limits. Check your usage at [AI Studio](https://aistudio.google.com/app/apikey).

## 📁 Project Structure

```
sebo-project/
├── app.py                    # Flask application & API endpoints
├── requirements.txt          # Python packages
├── templates/
│   └── index.html           # Frontend (HTML/CSS/JS)
├── data/
│   └── students.json        # Student data (auto-created)
├── venv/                    # Virtual environment
├── .env                     # Environment variables (create this)
├── run.sh                   # Quick start script
├── SETUP.md                 # Detailed setup guide
└── README.md                # This file
```

## 🎯 How to Use

### Adding Students
1. Fill out the "Add New Student" form with:
   - Student name
   - Age (optional)
   - Instrument
   - Skill level
   - Current books/pieces
   - Current goals (optional)
2. Click "Add Student"

### Importing from Excel
1. Prepare an Excel file with columns: `First Name`, `Last Name`, `Age`, `Instrument`, `Skill Level`, `Current book page`, `Current Pieces`, `Goals`
2. Click "Import Students"
3. Select your file
4. Students are added to your roster

### Generating Content

**Song Recommendations:**
- Click "Generate Recs" button
- AI generates 5 pieces based on instrument, skill level, and goals
- Click "View/Regen Recs" to see or regenerate

**Lesson Plans:**
- Click "Generate Plan" button
- AI creates an 8-week structured plan
- Click "View/Regen Plan" to see or regenerate

**Journey Reports:**
- Click "✨ Journey Report" button
- AI drafts an encouraging progress report
- Automatically simplified if student is under 18

### Editing Students
- Click "Edit" button
- Modify any student information
- Click "Save" to update
- Click "Cancel" to discard changes

## 🌐 Deployment Options

### Local Testing (Development)
```bash
python app.py
```
Available at: `http://localhost:5000`

### Local Production-like (Gunicorn)
```bash
gunicorn --workers 4 --bind 127.0.0.1:5000 app:app
```

### Server Deployment (Linode, AWS, etc.)

**1. SSH into server**
```bash
ssh user@your-server-ip
```

**2. Clone or upload project and follow setup steps**

**3. Run with Gunicorn (bound to all interfaces)**
```bash
gunicorn --workers 4 --bind 0.0.0.0:5000 app:app
```

**4. Optional: Use systemd service**
See [SETUP.md](SETUP.md) for systemd configuration.

**5. Optional: Use Nginx reverse proxy**
See [SETUP.md](SETUP.md) for Nginx configuration.

## 📦 API Endpoints

- `GET /` - Main page
- `GET /api/students` - Get all students
- `POST /api/students` - Add new student
- `PUT /api/students/<id>` - Update student
- `POST /api/students/<id>/recommendations` - Generate song recommendations
- `POST /api/students/<id>/lesson-plan` - Generate 8-week lesson plan
- `POST /api/students/<id>/journey-report` - Generate journey report
- `POST /api/import-xlsx` - Import students from Excel file

## 🔧 Technology Stack

- **Backend**: Flask (Python web framework)
- **Server**: Gunicorn (Python WSGI server)
- **Frontend**: HTML5, Tailwind CSS, Vanilla JavaScript
- **AI**: Google Generative AI (Gemini)
- **Data**: Local JSON files
- **Fonts**: Montserrat (headings), Comfortaa (body)

## 🎨 Customization

### Change Colors
Edit the hex color codes in `templates/index.html`:
- Primary: `#103a52` (dark blue)
- Accent: `#fc4a4b` (red)
- Light: `#fad9b0` (tan)
- Background: `#fff6eb` (cream)

### Change AI Model
Edit `app.py` to use different Gemini models:
```python
model = genai.GenerativeModel('gemini-2.0-flash')  # Change this
```

### Adjust Gunicorn Workers
```bash
gunicorn --workers 8 --bind 0.0.0.0:5000 app:app
```
Rule of thumb: workers = (2 × CPU cores) + 1

## 🐛 Troubleshooting

### "ModuleNotFoundError" errors
```bash
source venv/bin/activate
pip install -r requirements.txt
```

### AI features not working
- Check `.env` file exists in project root
- Verify `GEMINI_API_KEY` is set correctly
- Check API key is valid at [AI Studio](https://aistudio.google.com/apikey)
- Check [API usage limits](https://aistudio.google.com/app/apikey)

### Can't access from other machines
- Make sure to use `0.0.0.0` in Gunicorn bind:
  ```bash
  gunicorn --workers 4 --bind 0.0.0.0:5000 app:app
  ```
- Check firewall allows port 5000
- Use server's IP address: `http://192.168.x.x:5000`

### Data not persisting
- Check `data/` directory exists (created automatically)
- Check `data/students.json` has read/write permissions
- Backup: `cp data/students.json data/students.json.backup`

## 📝 Excel Import Format

Your Excel file should have these columns (case-sensitive):

| First Name | Last Name | Age | Instrument | Skill Level | Current book page | Current Pieces | Goals |
|-----------|-----------|-----|-----------|------------|------------------|-----------------|-------|
| John      | Smith     | 12  | Piano     | 2          | 45               | Fur Elise      | Improve sight reading |

**Skill Level** can be:
- `1` or `Beginner`
- `2` or `Early Intermediate`
- `3` or `Intermediate`
- `4` or `Advanced`

## 🔐 Security Notes

- This is a **local/LAN application** - not designed for public internet
- For server deployment, consider:
  - Using HTTPS/SSL
  - Adding authentication
  - Using a stronger database (PostgreSQL, etc.)
  - Running behind Nginx with access controls

## 📚 Further Reading

- [Flask Documentation](https://flask.palletsprojects.com/)
- [Gunicorn Documentation](https://gunicorn.org/)
- [Google Generative AI Docs](https://ai.google.dev/docs)
- [Tailwind CSS Docs](https://tailwindcss.com/docs)

## 📄 License

This project is for personal/educational use.

## 🤝 Support

For issues:
1. Check [SETUP.md](SETUP.md) for detailed setup instructions
2. Check browser console (F12) for JavaScript errors
3. Check terminal for Python errors

---

**Happy teaching! 🎵**

*Built with ❤️ for music educators*

