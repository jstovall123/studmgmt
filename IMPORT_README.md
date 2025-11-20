# 📊 Importing Students from Excel

Guide for importing student data from Excel (.xlsx) files into the Student Management System.

---

## ✅ Quick Start

1. Prepare an Excel file with the correct column headers
2. Open the Student Management System
3. Click "Import Students" button
4. Select your .xlsx file
5. Students are added automatically!

---

## 📋 Excel File Format

### Required Column Headers

Your Excel file **MUST** have these exact column headers in the first row:

| Column Header | Required | Type | Example |
|---------------|----------|------|---------|
| First Name | ✅ Yes | Text | John |
| Last Name | ✅ Yes | Text | Smith |
| Age | ❌ Optional | Number | 12 |
| Instrument | ✅ Yes | Text | Piano |
| Skill Level | ✅ Yes | Text/Number | 2 or "Beginner" |
| Book | ✅ Yes | Text | Alfred's Method |
| Current book page | ✅ Yes | Number | 45 |
| Current Pieces | ✅ Yes | Text | Fur Elise |
| Goals | ❌ Optional | Text | Improve sight reading |

---

## ⚠️ Important Rules

### 1. **Column Names Must Match Exactly**

✅ **Correct:**
```
First Name
Last Name
Book
Current book page
Current Pieces
```

❌ **Incorrect:**
```
FirstName          (no space)
first_name         (underscore)
firstname          (lowercase)
Book Name          (different wording)
page               (shortened)
```

### 2. **Required Columns Must Have Data**

These columns cannot be blank:
- First Name
- Last Name
- Instrument
- Skill Level
- Book
- Current book page
- Current Pieces

**If any are blank, that row will be skipped.**

### 3. **Skill Level Format**

Can be either numbers OR text:

**As Numbers (1-4):**
```
1 = Beginner
2 = Early Intermediate
3 = Intermediate
4 = Advanced
```

**As Text:**
```
Beginner
Early Intermediate
Intermediate
Advanced Intermediate
Advanced
```

**Maps To System Levels:**
- 1 → Beginner
- 2 → Early Intermediate
- 3 → Intermediate
- 4 → Advanced Intermediate (if using text)

### 4. **Optional Columns**

These can be left blank:
- Age (can be empty or omitted)
- Goals (can be empty or omitted)

---

## 📝 Example Excel Files

### Example 1: Full Information

```
| First Name | Last Name | Age | Instrument | Skill Level | Book            | Current book page | Current Pieces    | Goals                  |
|------------|-----------|-----|------------|-------------|-----------------|------------------|-------------------|------------------------|
| John       | Smith     | 12  | Piano      | 2           | Alfred's Method | 45                | Fur Elise         | Improve sight reading  |
| Sarah      | Johnson   | 15  | Violin     | Intermediate| Suzuki Book 3   | 20                | Concerto in D     | Learn vibrato          |
| Michael    | Brown     | 10  | Guitar     | 1           | Beginner's Guide| 10                | Basic chords      | Rhythm foundation      |
| Emily      | Davis     | 8   | Flute      | Beginner    | Standard Method | 15                | Mary Had a Lamb   |                        |
```

### Example 2: Minimal Information

```
| First Name | Last Name | Instrument | Skill Level | Book              | Current book page | Current Pieces |
|------------|-----------|------------|-------------|-------------------|------------------|----------------|
| John       | Smith     | Piano      | 2           | Alfred's Method   | 45                | Fur Elise      |
| Sarah      | Johnson   | Violin     | 3           | Suzuki Book 3     | 20                | Concerto       |
| Michael    | Brown     | Guitar     | 1           | Beginner's Guide  | 10                | Basic chords   |
```

### Example 3: With Multiple Pieces

For "Current Pieces", separate multiple pieces with commas:

```
| Current Pieces                           |
|------------------------------------------|
| Fur Elise, Moonlight Sonata, Prelude     |
| Concerto in D, Gavotte                   |
| Basic chords, Wonderwall                 |
```

---

## 🎯 Step-by-Step Import Instructions

### Step 1: Prepare Your Excel File

1. Open Excel or Google Sheets
2. Create columns with exact headers (see format above)
3. Enter student data starting in row 2
4. Save as `.xlsx` format (not `.xls` or `.csv`)

### Step 2: Open Student Management System

1. Navigate to `http://your-server-ip`
2. Scroll down to "Import from .XLSX File" section

### Step 3: Select Your File

1. Click the file input box
2. Select your prepared .xlsx file
3. Click "Import Students" button

### Step 4: Verify Import

1. Check the status message (shows number imported)
2. Scroll to "Student Roster" table
3. Verify your students appear

---

## ✨ What Happens During Import

For each row in your Excel file:

1. **Extracts data** from columns
2. **Validates** required fields are present
3. **Maps skill level** (converts 1-4 to system levels)
4. **Combines** first/last names
5. **Formats assignments** as: "Book (p. page)\nPieces: pieces"
6. **Adds to system** with current timestamp
7. **Stores in** `data/students.json`

---

## 🆘 Troubleshooting

### Issue: "File is empty or could not be read"

**Causes:**
- File is empty (no data rows)
- File is not .xlsx format
- File is corrupted

**Solution:**
- Check file has data in rows 2+
- Verify file is saved as .xlsx
- Try re-saving the file

### Issue: Some students not imported

**Causes:**
- Required columns missing values
- Column headers don't match exactly
- Invalid skill level format

**Solution:**
- Check all required columns have data
- Verify exact column header spelling
- Skill level must be 1-4 or valid text

### Issue: Data formatted incorrectly in system

**Causes:**
- Column headers named differently
- Data in unexpected format

**Solution:**
- Check column headers match exactly
- Verify data format matches examples above
- Re-export with correct formatting

---

## 📊 Column Details

### First Name & Last Name
- **Type**: Text
- **Required**: Yes
- **Combined into**: Student name display
- **Example**: "John Smith"

### Age
- **Type**: Number
- **Required**: No
- **Can be**: Blank or omitted
- **Used for**: Age-specific features (e.g., parent reports)
- **Example**: `12` or leave blank

### Instrument
- **Type**: Text (any instrument name)
- **Required**: Yes
- **Can be**: Any string
- **Examples**: Piano, Violin, Guitar, Flute, Trumpet, Cello, etc.

### Skill Level
- **Type**: Number (1-4) OR Text
- **Required**: Yes
- **Number format**: 1=Beginner, 2=Early Intermediate, 3=Intermediate, 4=Advanced
- **Text format**: "Beginner", "Early Intermediate", "Intermediate", "Advanced Intermediate", "Advanced"
- **Examples**: `2` or `"Intermediate"`

### Book
- **Type**: Text
- **Required**: Yes
- **Can be**: Any book name or method book
- **Examples**: "Alfred's Method", "Suzuki Book 3", "Beginner's Guide"

### Current book page
- **Type**: Number
- **Required**: Yes
- **Can be**: Any page number
- **Examples**: `45`, `10`, `100`
- **Note**: Combined with book name in system

### Current Pieces
- **Type**: Text (can include multiple, comma-separated)
- **Required**: Yes
- **Can be**: Single or multiple pieces
- **Examples**: 
  - `"Fur Elise"` (single)
  - `"Fur Elise, Moonlight Sonata, Prelude"` (multiple)

### Goals
- **Type**: Text
- **Required**: No
- **Can be**: Blank, omitted, or any goal description
- **Examples**: 
  - `"Improve sight reading"`
  - `"Learn vibrato"`
  - (leave blank if no specific goal)

---

## 🎓 Tips & Best Practices

### 1. **Start Small**
Test import with 2-3 students first before importing large batches.

### 2. **Use Consistent Formatting**
- Keep instrument names consistent (e.g., "Piano" not "piano", "PIANO")
- Use same book naming convention
- Choose either numbers or text for skill levels (don't mix)

### 3. **Review Before Importing**
Double-check your Excel file for:
- Correct column headers
- No blank required cells
- Consistent formatting

### 4. **Backup Before Import**
Before importing large batches, backup your data:
```bash
cp /opt/studmgmt/data/students.json /opt/studmgmt/data/students.json.backup
```

### 5. **Multiple Pieces**
If a student is working on multiple pieces, separate with commas:
```
Fur Elise, Moonlight Sonata, Prelude
```

### 6. **Edit After Import**
If you need to adjust a student after import, just click "Edit" on their row!

---

## 📥 Google Sheets & LibreOffice

### Google Sheets
1. Create/prepare in Google Sheets
2. Download as .xlsx (File → Download → Microsoft Excel)
3. Import into Student Management System

### LibreOffice Calc
1. Create/prepare in LibreOffice
2. Save as .xlsx format
3. Import into Student Management System

---

## 🔄 Re-importing Students

You can import the same students multiple times. The system will:
- ✅ Create new entries each time
- ⚠️ Won't check for duplicates
- 💡 Tip: Edit or delete manually if needed

---

## 📞 Support

### Import not working?
1. Check all column headers match exactly
2. Verify file is .xlsx format
3. Ensure all required columns have data
4. Try with a small test file (2-3 rows)

### Still having issues?
Check the browser console (F12) for error messages, or check the server logs:
```bash
sudo tail -50 /var/log/studmgmt/error.log
```

---

*Last Updated: January 19, 2025*  
*Student Management System v1.0*

