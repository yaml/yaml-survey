# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a survey management system for YAML infrastructure surveys. It automates the creation of Google Forms from YAML definitions and provides a router landing page to direct respondents to role-specific surveys (Engineers, DevOps/Platform Managers, Executives).

### Key Components

1. **Survey Definitions** (`survey/*.yaml`) - YAML files defining survey structure, questions, and options
2. **Google Forms Publisher** (`bin/publish-survey`) - Python script that creates Google Forms from YAML definitions using the Google Forms API
3. **Index Generator** (`bin/make-index`) - YS script that generates the router landing page from a template
4. **Router Page** (`index.html`) - Static landing page that routes users to appropriate surveys
5. **URL Configuration** (`config.yaml`) - Auto-generated file tracking all Google Forms URLs

### Build System

This project uses [Makes](https://github.com/makeplus/makes), a GNU Makefile framework that auto-installs dependencies locally in `.cache/`:
- Python 3.14 with virtual environment
- YS (YAML Script) interpreter
- All dependencies are installed in `.cache/` on first use

## Common Commands

### Publishing Surveys

```bash
# Publish all surveys at once
make publish

# Publish specific survey(s)
cd bin
./publish-survey ../survey/engineers.yaml
./publish-survey ../survey/devops-managers.yaml ../survey/executives.yaml
./publish-survey ../survey/*.yaml
```

The `publish-survey` script will:
- Create Google Forms from YAML definitions
- Create response spreadsheets
- Save URLs to `config.yaml` (keys: `{basename}-form-url`, `{basename}-edit-url`, `{basename}-sheet-url`)
- On first run, prompt for Google OAuth authentication

### Generating the Router Page

```bash
# Generate index.html from template and config
make
```

This runs `bin/make-index` which reads `index-template.html` and `config.yaml`, replacing placeholder URLs with actual form URLs.

### Cleaning

```bash
# Clean all generated files
make clean

# Remove everything including credentials and cached dependencies
make realclean
```

## Architecture

### Survey YAML Format

Surveys are defined in `survey/*.yaml` with this structure:

```yaml
title: "Survey Title"
description: "Multi-line description"
required: true|false       # Optional: survey-level default for all questions
sections:
  - title: "Section Name"
    required: true|false   # Optional: section-level default (overrides survey default)
    questions:
      - type: text|paragraph|radio|checkbox|dropdown|scale|date|time|rating|grid_radio|grid_checkbox|text_item
        title: "Question text"
        required: true|false # Optional: question-level (overrides section/survey defaults)
        options: [...]        # for radio/checkbox/dropdown
        scale: {...}          # for scale questions
        items: [...]          # for multi-item scale questions
        rows: [...]           # for grid questions
        columns: [...]        # for grid questions
        include_time: bool    # for date questions
        include_year: bool    # for date questions
        duration: bool        # for time questions
        scale_level: int      # for rating questions
        icon_type: str        # for rating questions (STAR/HEART/THUMB_UP)
```

**Cascading `required` defaults:** The `required` field can be set at survey, section, or question level. Defaults cascade down (survey → section → question), with more specific levels overriding broader ones. If not specified at any level, defaults to `false`.

Supported question types:
- `text` - Short answer
- `paragraph` - Long answer
- `radio` - Single choice (with optional `allow_other: true`)
- `checkbox` - Multiple choice (with optional `allow_other: true`)
- `dropdown` - Dropdown menu for single selection (compact alternative to radio)
- `scale` - Linear scale with configurable range and labels (supports single or multiple items)
- `date` - Date picker with optional time and year
- `time` - Time picker for time of day or duration
- `rating` - Visual rating with stars, hearts, or thumbs (configurable scale level)
- `grid_radio` - Multiple choice grid/matrix (single selection per row)
- `grid_checkbox` - Checkbox grid/matrix (multiple selections per row)
- `text_item` - Display text/instructions without requiring input

### Google Forms Integration

The `publish-survey` script (`bin/publish-survey`):
- Authenticates via OAuth 2.0 (credentials in `credentials.json`, tokens cached in `token.pickle`)
- Uses Google Forms API, Sheets API, and Drive API
- Creates forms with sections (page breaks) and questions via batch updates
- Creates response spreadsheets (must be manually linked in Forms UI due to API limitations)
- Saves all URLs to `config.yaml` with consistent naming: `{basename}-{type}-url`

### URL Management

`config.yaml` tracks all generated URLs:
- `{survey}-form-url` - Public URL for respondents
- `{survey}-edit-url` - Admin URL for editing
- `{survey}-sheet-url` - Response spreadsheet URL

The index generator (`bin/make-index`) is a YS script that substitutes these URLs into `index-template.html`.

### Router Page Architecture

The router page (`index.html`):
- Pure HTML/CSS/JS static page
- Presents three role-based cards (Engineers, DevOps, Leadership)
- Uses JavaScript `FORM_URLS` object populated from `config.yaml` via template substitution
- Can be deployed to GitHub Pages, Netlify, or any static hosting

## Development Workflow

### Creating/Modifying Surveys

1. Edit YAML files in `survey/` directory
2. Run `bin/publish-survey` to create/update Google Forms
3. Manually link response spreadsheet in Google Forms UI (Responses tab → Sheets icon → Select existing spreadsheet)
4. Run `make` to regenerate `index.html` with updated URLs

### Python Dependencies

Dependencies are managed via `requirements.txt`:
- `google-api-python-client` - Google API client
- `google-auth-*` - OAuth authentication
- `PyYAML` - YAML parsing

The Makefile handles virtual environment creation and installation automatically via Makes framework.

### Credentials Setup

Required for first-time use:
1. Create Google Cloud project
2. Enable APIs: Google Forms, Sheets, Drive
3. Create OAuth 2.0 Desktop credentials
4. Download as `credentials.json` in project root
5. Run `bin/publish-survey` - it will prompt for authentication and save tokens

## File Organization

```
.
├── survey/           # YAML survey definitions
├── bin/              # Scripts (publish-survey, make-index)
├── intro/            # Survey intro markdown files (documentation)
├── detailed/         # Detailed survey markdown files (documentation)
├── index-template.html  # Template for router page
├── index.html        # Generated router page
├── config.yaml       # Generated URL tracking
├── credentials.json  # Google OAuth credentials (gitignored)
├── token.pickle      # OAuth tokens (gitignored)
└── .cache/           # Makes dependencies (gitignored)
```

## Important Notes

- The Google Forms API cannot programmatically link spreadsheets to forms - this must be done manually through the Forms UI
- All dependencies are installed locally in `.cache/` via Makes - no system-level installations required
- The router page is purely static and can be hosted anywhere
- Survey definitions can have multiple scale items under a single question for rating matrices
- The `bin/make-index` script uses YS (YAML Script), a functional language that operates on YAML data
