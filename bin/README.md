# Google Forms Creation Scripts

This directory contains scripts to automatically create Google Forms from YAML survey definitions.

## Setup

### 1. Enable Required APIs

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the following APIs (repeat for each):
   - Go to "APIs & Services" > "Library"
   - Search for the API name and click "Enable"

   **Required APIs:**
   - **Google Forms API** - For creating and managing forms
   - **Google Sheets API** - For creating response spreadsheets
   - **Google Drive API** - For file management

### 2. Create OAuth 2.0 Credentials

1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "OAuth client ID"
3. If prompted, configure the OAuth consent screen:
   - Choose "External" user type
   - Fill in required fields (app name, user support email, developer email)
   - Add your email as a test user
   - Save and continue through the scopes section (no scopes needed)
4. Back in "Create OAuth client ID":
   - Application type: "Desktop app"
   - Name: "YAML Survey Form Creator" (or any name)
   - Click "Create"
5. Download the credentials JSON file
6. Rename it to `credentials.json` and place it in this `bin` directory

### 3. Install Python Dependencies

```bash
cd survey
pip install -r requirements.txt
```

Or if using a virtual environment (recommended):

```bash
cd survey
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

## Usage

### Creating a Google Form from YAML

The script reads one or more YAML files and creates a Google Form for each.

**Single file:**
```bash
./publish-survey ../survey/engineers.yaml
```

**Multiple files:**
```bash
./publish-survey ../survey/*.yaml
./publish-survey ../survey/engineers.yaml ../survey/devops-managers.yaml
```

**First time running:**
1. The script will open a browser window asking you to authenticate
2. Sign in with your Google account
3. Grant the requested permissions (Forms, Sheets, Drive)
4. The script will save authentication tokens locally for future use

**What the script does:**
- Creates a Google Form with all questions from your YAML file
- Automatically creates a Google Sheet for collecting responses
- Provides URLs for both the form and spreadsheet
- **Saves all URLs to `config.yaml` for easy reference**

**Output:**
```
Form created! ID: 1a2b3c4d5e6f7g8h9i0j
Edit URL: https://docs.google.com/forms/d/1a2b3c4d5e6f7g8h9i0j/edit
Response URL: https://docs.google.com/forms/d/1a2b3c4d5e6f7g8h9i0j/viewform

Adding questions to the form...
Successfully added 45 items to the form!

Form is ready to use:
Edit: https://docs.google.com/forms/d/{form_id}/edit
Share: https://docs.google.com/forms/d/{form_id}/viewform

Created response spreadsheet!
Spreadsheet URL: https://docs.google.com/spreadsheets/d/abc123.../edit

Note: Due to Google Forms API limitations, the spreadsheet has been created
but must be linked manually. This takes just a few seconds:

1. Open the form: https://docs.google.com/forms/d/{form_id}/edit
2. Click the 'Responses' tab
3. Click the Google Sheets icon (green spreadsheet)
4. Choose 'Select existing spreadsheet'
5. Find and select: 'Your Survey Title (Responses)'

URLs saved to /path/to/survey/bin/config.yaml
```

**Note:** While the Forms API can create the spreadsheet, it cannot automatically link it due to API limitations. The manual linking step takes about 10 seconds.

## URL Tracking with config.yaml

The script automatically saves all generated URLs to `config.yaml` in this directory. This makes it easy to reference URLs later without searching through console output.

**Example config.yaml:**
```yaml
devops-managers-edit-url: https://docs.google.com/forms/d/abc.../edit
devops-managers-form-url: https://docs.google.com/forms/d/abc.../viewform
devops-managers-sheet-url: https://docs.google.com/spreadsheets/d/xyz.../edit
engineers-edit-url: https://docs.google.com/forms/d/def.../edit
engineers-form-url: https://docs.google.com/forms/d/def.../viewform
engineers-sheet-url: https://docs.google.com/spreadsheets/d/uvw.../edit
executives-edit-url: https://docs.google.com/forms/d/ghi.../edit
executives-form-url: https://docs.google.com/forms/d/ghi.../viewform
executives-sheet-url: https://docs.google.com/spreadsheets/d/rst.../edit
```

**Key naming convention:**
- Input file: `engineers.yaml`
- Generated keys:
  - `engineers-form-url` - Public form URL for respondents
  - `engineers-edit-url` - Admin URL for editing the form
  - `engineers-sheet-url` - Response spreadsheet URL

The config file persists across runs and accumulates URLs for all surveys you create.

## Creating All Surveys

To create all three survey forms, you can run them individually:

```bash
./publish-survey ../survey/engineers.yaml
./publish-survey ../survey/devops-managers.yaml
./publish-survey ../survey/executives.yaml
```

Or process them all in a single command:

```bash
./publish-survey ../survey/*.yaml
```

All URLs will be saved to `config.yaml` for easy reference.

## YAML Survey Format

### Basic Structure

```yaml
title: "Your Survey Title"
description: |
  Multi-line description
  of your survey

sections:
  - title: "Section 1 Name"
    questions:
      - type: text
        title: Your question here
        required: true
      # ... more questions
```

### Cascading `required` Defaults

To reduce repetition, you can set `required` at the survey, section, or question level. Defaults cascade down, with more specific levels overriding broader ones.

**Section-level default** (most common):
```yaml
sections:
  - title: "Contact Information"
    required: true  # All questions in this section are required by default
    questions:
      - type: text
        title: Name
        # Inherits required: true from section

      - type: text
        title: Email
        # Inherits required: true from section

      - type: text
        title: Phone
        required: false  # Override: this one is optional
```

**Survey-level default:**
```yaml
title: "My Survey"
required: true  # All questions are required by default
sections:
  - title: "Section 1"
    questions:
      - type: text
        title: Question 1
        # Inherits required: true from survey

  - title: "Optional Section"
    required: false  # Override for this section
    questions:
      - type: text
        title: Question 2
        # Inherits required: false from section
```

**Default behavior:** If `required` is not specified at any level, it defaults to `false`.

### Supported Question Types

#### Text (Short Answer)
```yaml
- type: text
  title: What is your name?
  required: true
```

#### Paragraph (Long Answer)
```yaml
- type: paragraph
  title: Please describe your experience
  required: false
```

#### Radio (Single Choice)
```yaml
- type: radio
  title: What is your company size?
  required: true
  options:
    - Small (1-50)
    - Medium (51-200)
    - Large (201+)
  allow_other: true  # Optional: adds "Other" option
```

#### Checkbox (Multiple Choice)
```yaml
- type: checkbox
  title: Which tools do you use? (Check all that apply)
  required: true
  options:
    - Tool A
    - Tool B
    - Tool C
  allow_other: true  # Optional
```

#### Scale (Rating)

Single scale question:
```yaml
- type: scale
  title: How satisfied are you?
  description: "Optional description"
  required: true
  scale:
    low: 1
    high: 5
    low_label: Not satisfied
    high_label: Very satisfied
```

Multiple scale questions (useful for rating multiple items):
```yaml
- type: scale
  title: Rate the following features
  description: "1=Not valuable, 5=Very valuable"
  required: true
  scale:
    low: 1
    high: 5
    low_label: Not valuable
    high_label: Very valuable
  items:
    - Feature A
    - Feature B
    - Feature C
```

#### Dropdown (Single Selection Menu)

A dropdown menu provides a compact way to select a single option from a list. Use this instead of radio buttons when you have many options (typically 7+) to save space.

```yaml
- type: dropdown
  title: Select your country
  required: true
  options:
    - United States
    - Canada
    - United Kingdom
    - Germany
    - France
    - Other
  shuffle: false  # Optional: randomize option order (default: false)
```

#### Date (Date Picker)

Date questions display a calendar picker for selecting dates. You can optionally include time selection and control whether the year is shown.

Basic date picker:
```yaml
- type: date
  title: When would you like to schedule your appointment?
  required: true
  include_time: false  # Optional: adds time picker (default: false)
  include_year: true   # Optional: show year selector (default: true)
```

Date and time combined:
```yaml
- type: date
  title: Select meeting date and time
  required: true
  include_time: true
  include_year: true
```

#### Time (Time Picker)

Time questions allow users to select either a specific time of day or specify a duration/elapsed time.

Time of day:
```yaml
- type: time
  title: What time works best for you?
  required: true
  duration: false  # false = time of day (default)
```

Duration (elapsed time):
```yaml
- type: time
  title: How long did the task take?
  required: false
  duration: true  # true = duration/elapsed time
```

#### Rating (Visual Icon Rating)

Rating questions display visual icons (stars, hearts, or thumbs) for intuitive feedback. Choose from three icon types and configure the scale level (typically 5 or 10).

Star rating:
```yaml
- type: rating
  title: How would you rate our service?
  required: true
  scale_level: 5  # Number of stars (default: 5)
  icon_type: STAR  # STAR, HEART, or THUMB_UP (default: STAR)
```

Heart rating:
```yaml
- type: rating
  title: How much do you love this product?
  required: false
  scale_level: 5
  icon_type: HEART
```

Thumbs rating (typically 1-10):
```yaml
- type: rating
  title: Would you recommend us?
  required: true
  scale_level: 10
  icon_type: THUMB_UP
```

#### Grid Radio (Multiple Choice Grid)

A grid question allows respondents to rate multiple items using the same set of options. Each row can have only one selection (radio button style). This is ideal for rating matrices and comparison surveys.

```yaml
- type: grid_radio
  title: Rate each feature of our product
  required: true
  rows:
    - User interface
    - Performance
    - Reliability
    - Documentation
    - Customer support
  columns:
    - Poor
    - Fair
    - Good
    - Very Good
    - Excellent
  shuffle_rows: false  # Optional: randomize row order (default: false)
```

#### Grid Checkbox (Checkbox Grid)

Similar to grid radio, but allows multiple selections per row. Useful when respondents can select multiple attributes for each item.

```yaml
- type: grid_checkbox
  title: Which features would you use in each product tier?
  required: true
  rows:
    - Basic Tier
    - Professional Tier
    - Enterprise Tier
  columns:
    - API Access
    - Priority Support
    - Custom Integrations
    - Advanced Analytics
  shuffle_rows: false  # Optional
```

#### Text Item (Display Only)

Text items display information without requiring any input. Use them for instructions, explanations, or section introductions. They are not questions and have no "required" field.

```yaml
- type: text_item
  title: "Important Instructions"
  description: |
    Please read the following carefully before proceeding.

    This section contains important information about
    how to complete the rest of the survey.
```

Simple text item:
```yaml
- type: text_item
  title: "Section 2: Technical Questions"
  description: "The following questions are for technical team members only."
```

**Note:** The `required` field defaults to `false` if not specified.

## Post-Creation Steps

After running the script:

### 1. Link the Response Spreadsheet (Required)

The script creates a spreadsheet but due to API limitations, you need to link it manually (takes ~10 seconds):

1. Open the form in edit mode (use the Edit URL from output)
2. Click the **Responses** tab
3. Click the **Google Sheets icon** (green spreadsheet)
4. Choose **"Select existing spreadsheet"**
5. Find and select the spreadsheet named: `[Your Survey Title] (Responses)`

Once linked, all form responses will automatically appear in the spreadsheet!

### 2. Configure Form Settings

Customize your form:

1. **Styling**: Change theme colors, add header image
2. **Settings** (⚙️ icon):
   - Collect email addresses
   - Limit to 1 response per person
   - Shuffle question order
   - Show progress bar
3. **Email notifications**: Get notified of new responses

### 3. Update Router Page

Use the URLs from `config.yaml` to update `../index.html`:

1. Copy the form URLs from `config.yaml`
2. Update the `FORM_URLS` object in `index.html`
3. Remove `disabled` class from the corresponding role card

## Sharing Your Form

The script outputs three URLs:

- **Form Edit URL** (`-edit-url`): For you to customize the form (requires permissions)
- **Form Response URL** (`-form-url`): Share this with respondents to fill out the form
- **Spreadsheet URL** (`-sheet-url`): View and analyze collected responses

**Important:** Check sharing settings to ensure anyone with the link can respond:
1. Open the form in edit mode
2. Click Settings (⚙️) > Responses
3. Uncheck "Restrict to [your organization]" if present

## Response Data

All form responses are automatically saved to:
- **Google Forms**: View in the form's "Responses" tab (summary, individual, or by question)
- **Google Sheets**: Once linked, each response appears as a new row with timestamp and all answers

## Troubleshooting

### "Permission denied" or "Insufficient permissions" errors
- Make sure you've enabled all required APIs: Forms, Sheets, and Drive
- **If you previously used the script**: Delete `token.pickle` and re-authenticate (the script now requires additional permissions for Sheets)
- Verify your credentials.json file is in the correct location

### "Invalid credentials" errors
- Re-download your credentials.json file from Google Cloud Console
- Make sure you're using OAuth 2.0 credentials for a Desktop application

### "API quota exceeded" errors
- Google Forms/Sheets APIs have usage limits
- Wait a few minutes and try again
- Check your quota in the Google Cloud Console

### Spreadsheet not creating
- Ensure Google Sheets API is enabled in your Google Cloud project
- Delete `token.pickle` and re-authenticate to get Sheets permissions
- Check that you have sufficient Google Drive storage space

## Files

**In this directory (bin/):**
- `publish-survey` - Main script to create forms from YAML
- `config.yaml` - Auto-generated URL tracking file
- `credentials.json` - OAuth 2.0 credentials (you need to create this)
- `token.pickle` - Saved authentication tokens (auto-generated after first run)
- `README.md` - This documentation

**In parent directory (survey/):**
- `requirements.txt` - Python package dependencies

## Examples

See `../survey/` for complete examples of multi-section surveys with various question types:
- `engineers.yaml` - Technical contributors survey
- `devops-managers.yaml` - DevOps/Platform managers survey
- `executives.yaml` - Executive leadership survey
