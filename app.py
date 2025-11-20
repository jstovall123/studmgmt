from flask import Flask, render_template, request, jsonify, send_file
import json
import os
import sys
import logging
from datetime import datetime
import google.generativeai as genai
from pathlib import Path
from dotenv import load_dotenv

app = Flask(__name__)

# Set up logging to see all output in systemd journal
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(message)s',
    stream=sys.stdout
)
logger = logging.getLogger(__name__)

# Load environment variables from .env file
env_path = Path(__file__).parent / '.env'
logger.info(f"Looking for .env file at: {env_path}")
logger.info(f".env file exists: {env_path.exists()}")

if env_path.exists():
    load_dotenv(env_path)
    logger.info("✓ .env file loaded successfully")
else:
    logger.warning("⚠ .env file not found!")

# Configuration
DATA_DIR = Path(__file__).parent / 'data'
STUDENTS_FILE = DATA_DIR / 'students.json'
API_KEY = os.getenv('GEMINI_API_KEY', '')

logger.info(f"API_KEY loaded: {bool(API_KEY)}")
if API_KEY:
    logger.info(f"API_KEY preview: {API_KEY[:15]}...")
else:
    logger.error("❌ API_KEY is empty - AI features will not work!")

# Initialize Generative AI
if API_KEY:
    try:
        genai.configure(api_key=API_KEY)
        logger.info("✓ Generative AI configured successfully")
    except Exception as e:
        logger.error(f"❌ Failed to configure Generative AI: {e}")
else:
    logger.warning("⚠ Generative AI not configured - no API key")

# Ensure data directory exists
DATA_DIR.mkdir(exist_ok=True)
logger.info(f"Data directory ready: {DATA_DIR}")

def load_students():
    """Load students from JSON file."""
    if STUDENTS_FILE.exists():
        with open(STUDENTS_FILE, 'r') as f:
            return json.load(f)
    return {}

def save_students(students):
    """Save students to JSON file."""
    with open(STUDENTS_FILE, 'w') as f:
        json.dump(students, f, indent=2)

def generate_id():
    """Generate a simple ID based on timestamp."""
    return str(int(datetime.now().timestamp() * 1000))

@app.route('/')
def index():
    """Serve the main page."""
    return render_template('index.html')

@app.route('/api/students', methods=['GET'])
def get_students():
    """Get all students."""
    try:
        students_dict = load_students()
        students = list(students_dict.values())
        # Sort by timestamp descending
        students.sort(key=lambda x: x.get('timestamp', ''), reverse=True)
        return jsonify(students), 200
    except Exception as e:
        logger.error(f"Error getting students: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/students', methods=['POST'])
def add_student():
    """Add a new student."""
    try:
        data = request.json
        
        # Validate required fields
        if not data.get('name') or not data.get('instrument') or not data.get('skillLevel') or not data.get('currentAssignments'):
            return jsonify({'error': 'Missing required fields'}), 400
        
        student_id = generate_id()
        students_dict = load_students()
        
        students_dict[student_id] = {
            'id': student_id,
            'name': data.get('name'),
            'age': data.get('age') or None,
            'instrument': data.get('instrument'),
            'skillLevel': data.get('skillLevel'),
            'currentAssignments': data.get('currentAssignments'),
            'currentGoals': data.get('currentGoals', ''),
            'lessonNoteHistory': '',
            'recommendations': json.dumps([]),
            'lessonPlan': '',
            'timestamp': datetime.now().isoformat(),
            'ownerId': 'local-user'
        }
        
        save_students(students_dict)
        logger.info(f"Added student: {data.get('name')}")
        return jsonify(students_dict[student_id]), 201
    except Exception as e:
        logger.error(f"Error adding student: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/students/<student_id>', methods=['PUT'])
def update_student(student_id):
    """Update a student."""
    try:
        data = request.json
        students_dict = load_students()
        
        if student_id not in students_dict:
            return jsonify({'error': 'Student not found'}), 404
        
        # Update fields
        student = students_dict[student_id]
        student['name'] = data.get('name', student['name'])
        student['age'] = data.get('age') or None
        student['instrument'] = data.get('instrument', student['instrument'])
        student['skillLevel'] = data.get('skillLevel', student['skillLevel'])
        student['currentAssignments'] = data.get('currentAssignments', student['currentAssignments'])
        student['currentGoals'] = data.get('currentGoals', student['currentGoals'])
        student['lessonNoteHistory'] = data.get('lessonNoteHistory', student['lessonNoteHistory'])
        
        save_students(students_dict)
        logger.info(f"Updated student: {student['name']}")
        return jsonify(student), 200
    except Exception as e:
        logger.error(f"Error updating student: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/students/<student_id>', methods=['DELETE'])
def delete_student(student_id):
    """Delete a student."""
    try:
        students_dict = load_students()
        
        if student_id not in students_dict:
            return jsonify({'error': 'Student not found'}), 404
        
        # Get student name before deletion (for response)
        student_name = students_dict[student_id]['name']
        
        # Delete the student
        del students_dict[student_id]
        save_students(students_dict)
        
        logger.info(f"Deleted student: {student_name}")
        return jsonify({'success': True, 'message': f'Student {student_name} deleted successfully'}), 200
    except Exception as e:
        logger.error(f"Error deleting student: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/students/<student_id>/recommendations', methods=['POST'])
def generate_recommendations(student_id):
    """Generate song recommendations for a student."""
    logger.info(f"Generating recommendations for student: {student_id}")
    logger.info(f"API_KEY present: {bool(API_KEY)}")
    
    try:
        if not API_KEY:
            logger.error("❌ API_KEY is not configured")
            return jsonify({'error': 'Gemini API key not configured'}), 500
        
        students_dict = load_students()
        if student_id not in students_dict:
            return jsonify({'error': 'Student not found'}), 404
        
        student = students_dict[student_id]
        logger.info(f"Found student: {student['name']}")
        
        # Create the prompt
        system_prompt = """You are a music teacher assistant. Generate a list of 5 pieces appropriate for the specified instrument, skill level, and student goals.

Your entire response MUST be a single, valid JSON array string (e.g., [ { "title": "...", ... } ]).
Do not include any text, markdown, or apologies before or after the JSON array.

Each object in the array must have these keys: "title", "composer", "focus"."""
        
        user_query = f"""{system_prompt}

Generate song recommendations for a {student['instrument']} student at the {student['skillLevel']} level.
Student Goals: {student.get('currentGoals') or 'Not specified'}
Student Lesson History: {student.get('lessonNoteHistory') or 'Not specified'}"""
        
        logger.info("Calling Gemini API...")
        # Call Gemini API
        model = genai.GenerativeModel('gemini-2.0-flash')
        response = model.generate_content(user_query)
        
        logger.info("Gemini API response received")
        
        # Parse the response
        response_text = response.text.strip()
        recommendations = json.loads(response_text)
        
        # Save to student record
        student['recommendations'] = json.dumps(recommendations)
        save_students(students_dict)
        
        logger.info(f"✓ Generated {len(recommendations)} recommendations")
        return jsonify({'recommendations': recommendations}), 200
    except json.JSONDecodeError as e:
        logger.error(f"JSON parsing error: {e}")
        return jsonify({'error': 'Failed to parse AI response as JSON'}), 500
    except Exception as e:
        logger.error(f"❌ Error generating recommendations: {e}", exc_info=True)
        return jsonify({'error': str(e)}), 500

@app.route('/api/students/<student_id>/lesson-plan', methods=['POST'])
def generate_lesson_plan(student_id):
    """Generate an 8-week lesson plan for a student."""
    logger.info(f"Generating lesson plan for student: {student_id}")
    
    try:
        if not API_KEY:
            logger.error("❌ API_KEY is not configured")
            return jsonify({'error': 'Gemini API key not configured'}), 500
        
        students_dict = load_students()
        if student_id not in students_dict:
            return jsonify({'error': 'Student not found'}), 404
        
        student = students_dict[student_id]
        logger.info(f"Found student: {student['name']}")
        
        # Create the prompt
        system_prompt = """You are an expert music educator. Create a structured 8-week lesson plan tailored to the student's instrument, materials, goals, and history. The plan should balance technical exercises, sight-reading, and repertoire.
Format the response in clean Markdown. Use headings (e.g., '### Week 1-2: Focus on Technique') and bullet points for clarity. 
Ensure new information starts on a new line. Do not use horizontal rules (---) or asterisks for bullets; use dashes (-) instead."""
        
        user_query = f"""{system_prompt}

Create an 8-week plan for this {student['instrument']} student.
Current Materials: {student['currentAssignments']}
Student Goals: {student.get('currentGoals') or 'Not specified'}
Lesson Note History: {student.get('lessonNoteHistory') or 'Not specified'}"""
        
        logger.info("Calling Gemini API for lesson plan...")
        # Call Gemini API
        model = genai.GenerativeModel('gemini-2.0-flash')
        response = model.generate_content(user_query)
        
        plan_text = response.text
        
        # Save to student record
        student['lessonPlan'] = plan_text
        save_students(students_dict)
        
        logger.info("✓ Lesson plan generated successfully")
        return jsonify({'lessonPlan': plan_text}), 200
    except Exception as e:
        logger.error(f"❌ Error generating lesson plan: {e}", exc_info=True)
        return jsonify({'error': str(e)}), 500

@app.route('/api/students/<student_id>/journey-report', methods=['POST'])
def generate_journey_report(student_id):
    """Generate a musician's journey report for a student."""
    logger.info(f"Generating journey report for student: {student_id}")
    
    try:
        if not API_KEY:
            logger.error("❌ API_KEY is not configured")
            return jsonify({'error': 'Gemini API key not configured'}), 500
        
        students_dict = load_students()
        if student_id not in students_dict:
            return jsonify({'error': 'Student not found'}), 404
        
        student = students_dict[student_id]
        logger.info(f"Found student: {student['name']}")
        
        # Determine if adult
        try:
            age = int(student.get('age') or 0)
            is_adult = age > 18
        except:
            is_adult = False
        
        logger.info(f"Student age check: is_adult={is_adult}")
        
        # Create appropriate prompt
        if is_adult:
            system_prompt = """You are an expert music educator drafting an encouraging "Musician's Journey Report" for an adult student.
The tone should be positive, professional, and collaborative.
The report must cover:
1.  **Student's Progress:** Summarize their progress based on lesson history.
2.  **Achievements:** Highlight key pieces mastered or skills developed.
3.  **Goal Achievement:** How they have successfully (or are in the process of) achieving their stated goals.
4.  **Looking Forward:** A brief look at what skills and concepts you plan to cover next.
Format this as a clean document. Use headings (###) and bullet points (-) for clarity."""
        else:
            system_prompt = """You are an expert music educator drafting an encouraging "Musician's Journey Report" for the parent of a student.
**CRITICAL: Assume the parent has ZERO musical knowledge.**
The tone must be positive, professional, and simple.
The report must cover:
1.  **Student's Progress:** Summarize their progress. (e.g., "improved rhythm" becomes "got much better at playing steady beats").
2.  **Achievements:** Highlight key pieces mastered.
3.  **Goal Achievement:** How they are achieving their goals.
4.  **Looking Forward:** A brief, simple look at what's next (e.g., "We'll start learning how to play with both hands together more often.").
Format this as a clean document. Use headings (###) and bullet points (-) for clarity."""
        
        user_query = f"""{system_prompt}

Draft the Musician's Journey Report for {student['name']} ({student['instrument']}).
Student's Age: {student.get('age') or 'Not specified'}
Current Materials: {student['currentAssignments']}
Stated Goals: {student.get('currentGoals') or 'Not specified'}
Lesson Note History: {student.get('lessonNoteHistory') or 'Not specified'}"""
        
        logger.info("Calling Gemini API for journey report...")
        # Call Gemini API
        model = genai.GenerativeModel('gemini-2.0-flash')
        response = model.generate_content(user_query)
        
        report_text = response.text
        
        logger.info("✓ Journey report generated successfully")
        return jsonify({'journeyReport': report_text}), 200
    except Exception as e:
        logger.error(f"❌ Error generating journey report: {e}", exc_info=True)
        return jsonify({'error': str(e)}), 500

@app.route('/api/import-xlsx', methods=['POST'])
def import_xlsx():
    """Import students from XLSX file."""
    try:
        if 'file' not in request.files:
            return jsonify({'error': 'No file provided'}), 400
        
        file = request.files['file']
        logger.info(f"Importing file: {file.filename}")
        
        # Import openpyxl here to avoid hard dependency if not using this feature
        import openpyxl
        
        workbook = openpyxl.load_workbook(file.stream)
        worksheet = workbook.active
        
        students_dict = load_students()
        imported_count = 0
        
        # Get headers from first row
        headers = []
        for cell in worksheet[1]:
            headers.append(cell.value)
        
        logger.info(f"Headers found: {headers}")
        
        # Process data rows
        for row_idx, row in enumerate(worksheet.iter_rows(min_row=2, values_only=True), start=2):
            if not any(row):  # Skip empty rows
                continue
            
            row_dict = dict(zip(headers, row))
            
            # Map fields
            first_name = row_dict.get('First Name', '')
            last_name = row_dict.get('Last Name', '')
            name = f"{first_name} {last_name}".strip() or "Unnamed Student"
            
            assignments = f"{row_dict.get('Book') or 'N/A'} (p. {row_dict.get('Current book page') or 'N/A'})\nPieces: {row_dict.get('Current Pieces') or 'N/A'}".strip()
            
            # Map skill level
            skill_level_input = row_dict.get('Skill Level')
            skill_level_map = {
                '1': 'Beginner',
                '2': 'Early Intermediate',
                '3': 'Intermediate',
                '4': 'Advanced'
            }
            skill_level = skill_level_map.get(str(skill_level_input).lower()[:1], 'Intermediate')
            
            student_id = generate_id()
            students_dict[student_id] = {
                'id': student_id,
                'name': name,
                'age': row_dict.get('Age'),
                'instrument': row_dict.get('Instrument', 'Unknown'),
                'skillLevel': skill_level,
                'currentAssignments': assignments,
                'currentGoals': row_dict.get('Goals', ''),
                'lessonNoteHistory': '',
                'recommendations': json.dumps([]),
                'lessonPlan': '',
                'timestamp': datetime.now().isoformat(),
                'ownerId': 'local-user'
            }
            imported_count += 1
        
        save_students(students_dict)
        logger.info(f"✓ Imported {imported_count} students")
        return jsonify({'success': True, 'count': imported_count}), 200
    except Exception as e:
        logger.error(f"❌ Error importing XLSX: {e}", exc_info=True)
        return jsonify({'error': str(e)}), 500

@app.route('/download-sample', methods=['GET'])
def download_sample():
    """Download sample import CSV file."""
    try:
        sample_file = Path(__file__).parent / 'samples' / 'sample_import.csv'
        
        if not sample_file.exists():
            return jsonify({'error': 'Sample file not found'}), 404
        
        return send_file(
            sample_file,
            mimetype='text/csv',
            as_attachment=True,
            download_name='sample_import.csv'
        )
    except Exception as e:
        logger.error(f"Error downloading sample: {e}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    logger.info("Starting Flask app...")
    app.run(debug=True, host='127.0.0.1', port=5000)
