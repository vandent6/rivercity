# River City Invitational

Official tournament guide and resources for the Michigan High School Esports Federation tournament at Grand Rapids Comic-Con.

## 🚀 Quick Start - Running Locally

### Prerequisites
- Python 3.7+ installed
- pip package manager

### Setup Instructions

1. **Navigate to the project directory:**
   ```bash
   cd /home/dakota/rivercity
   ```

2. **Create and activate a virtual environment:**
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Run the development server:**
   ```bash
   ./serve-mkdocs.sh
   ```

   **Alternative (if script has issues):**
   ```bash
   mkdocs serve
   ```

### Access the Site

Once running, the documentation site will be available at:
- **http://127.0.0.1:8000** or **http://localhost:8000**

## 🔧 Troubleshooting

### Script Execution Issues
If you get `cannot execute: required file not found` when running `./serve-mkdocs.sh`:

```bash
# Fix line endings (Windows CRLF to Unix LF)
sed -i 's/\r$//' serve-mkdocs.sh
```

### Virtual Environment Issues
If the script warns about virtual environment not being detected:

```bash
# Make sure virtual environment is properly activated
source .venv/bin/activate
echo $VIRTUAL_ENV  # Should show the venv path
```

### Manual Server Start
If the script continues to have issues:

```bash
# Activate virtual environment
source .venv/bin/activate

# Run MkDocs directly
mkdocs serve --dev-addr=127.0.0.1:8000
```

## 📚 About This Project

This is a **MkDocs static site generator** project that creates documentation for the River City Invitational esports tournament. The site includes:

- Tournament information and schedules
- Rulesets for Valorant, Rocket League, and Super Smash Bros. Ultimate
- Registration details and pricing
- Venue information
- Resources and FAQ

### Features
- Material Design theme with dark/light mode toggle
- Responsive navigation
- Search functionality
- Live reload for development
- Auto-reload: Changes to markdown files automatically refresh the site

### Project Structure
- `docs/` - Contains all the markdown documentation files
- `mkdocs.yml` - Configuration file for MkDocs
- `requirements.txt` - Python dependencies
- `serve-mkdocs.sh` - Convenience script to run the development server

## 🎮 Tournament Information

The River City Invitational is organized by the Michigan High School Esports Federation in partnership with Grand Rapids Comic-Con and Ferris State University.

**Featured Games:**
- Valorant (Tactical 5v5 FPS)
- Rocket League (High-octane 3v3)
- Super Smash Bros. Ultimate (Crew Battle Format)

**Tournament Divisions:**
- Collegiate Invitational
- High School Invitational
- MiHSEF Regionals

For more information, visit the live site at **http://127.0.0.1:8000** when running locally.