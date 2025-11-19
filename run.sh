#!/bin/bash

# Music Student Progress Tracker - Quick Start Script

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Music Student Progress Tracker${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

# Check if venv exists
if [ ! -d "$SCRIPT_DIR/venv" ]; then
    echo -e "${YELLOW}Virtual environment not found. Creating...${NC}"
    python3 -m venv "$SCRIPT_DIR/venv"
    echo -e "${GREEN}✓ Virtual environment created${NC}"
fi

# Activate venv
source "$SCRIPT_DIR/venv/bin/activate"
echo -e "${GREEN}✓ Virtual environment activated${NC}"

# Install/update requirements
echo -e "${YELLOW}Installing dependencies...${NC}"
pip install -q -r "$SCRIPT_DIR/requirements.txt"
echo -e "${GREEN}✓ Dependencies installed${NC}"

# Check for .env file
if [ ! -f "$SCRIPT_DIR/.env" ]; then
    echo ""
    echo -e "${RED}⚠ .env file not found!${NC}"
    echo ""
    echo "To use AI features (recommendations, lesson plans, journey reports),"
    echo "you need a Gemini API key."
    echo ""
    echo "1. Visit: https://aistudio.google.com/apikey"
    echo "2. Create a new API key"
    echo "3. Create .env file:"
    echo ""
    echo "    cat > .env << 'EOF'"
    echo "    GEMINI_API_KEY=your_key_here"
    echo "    FLASK_ENV=development"
    echo "    FLASK_DEBUG=True"
    echo "    EOF"
    echo ""
    echo "Then run this script again."
    echo ""
fi

# Create data directory if it doesn't exist
mkdir -p "$SCRIPT_DIR/data"

# Ask user for running method
echo ""
echo -e "${GREEN}Choose how to run:${NC}"
echo "1) Development Server (Flask) - good for testing"
echo "2) Production Server (Gunicorn) - more stable"
echo ""
read -p "Enter choice (1 or 2): " choice

case $choice in
    1)
        echo ""
        echo -e "${GREEN}Starting Flask development server...${NC}"
        echo -e "${GREEN}Available at: http://localhost:5000${NC}"
        echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
        echo ""
        cd "$SCRIPT_DIR"
        python app.py
        ;;
    2)
        echo ""
        echo -e "${GREEN}Starting Gunicorn server...${NC}"
        echo -e "${GREEN}Available at: http://localhost:5000${NC}"
        echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
        echo ""
        cd "$SCRIPT_DIR"
        gunicorn --workers 4 --bind 127.0.0.1:5000 app:app
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

