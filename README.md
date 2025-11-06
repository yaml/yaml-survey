# YAML Infrastructure Surveys

This directory contains survey definitions, the form creation script, and the router page for directing respondents to the appropriate survey.

## Directory Structure

```
survey/
├── index.html                 # Router/landing page
├── requirements.txt           # Python dependencies
├── config.yaml                # Auto-generated URL tracking (created by script)
├── credentials.json           # OAuth credentials (you create this)
├── token.pickle               # Auth tokens (auto-generated)
├── bin/
│   ├── publish-survey        # Form creation script
│   ├── make-index            # Index generation script
│   └── README.md             # Script documentation
├── survey/
│   ├── engineers.yaml         # Engineers survey definition
│   ├── devops-managers.yaml   # DevOps/Platform managers survey
│   └── executives.yaml        # Executives survey definition
└── detailed/
    ├── engineers.md           # Detailed engineers survey (markdown)
    ├── devops-managers.md     # Detailed DevOps/Platform managers survey
    └── executives.md          # Detailed executives survey
```

## Quick Start

### 1. Create Google Forms

```bash
cd bin
# Process all surveys at once
./publish-survey ../survey/*.yaml

# Or run individually
./publish-survey ../survey/engineers.yaml
./publish-survey ../survey/devops-managers.yaml
./publish-survey ../survey/executives.yaml
```

See `bin/README.md` for detailed setup instructions.

All generated URLs will be saved to `config.yaml`.

### 2. Update Router Page

Update `index.html` with the form URLs from `config.yaml`:

1. Open `index.html` in a text editor
2. Find the `FORM_URLS` object in the `<script>` section
3. Replace placeholder URLs with actual URLs from `config.yaml`:

```javascript
const FORM_URLS = {
    engineer: 'YOUR_ENGINEERS_FORM_URL',      // From config.yaml: engineers-form-url
    devops: 'YOUR_DEVOPS_FORM_URL',           // From config.yaml: devops-managers-form-url
    leadership: 'YOUR_EXECUTIVES_FORM_URL'    // From config.yaml: executives-form-url
};
```

4. Enable the survey cards by removing `disabled` class and updating hrefs (see instructions below)

### 3. Deploy Router Page

Host `index.html` using one of these options (see Deployment Options below for details):
- GitHub Pages
- Netlify Drop
- Your own domain

## Survey Router Page

The `index.html` file is a landing page that presents three survey options:
- **Engineers** - For software engineers, developers, and technical contributors
- **DevOps/Platform Teams** - For DevOps engineers, SREs, and platform team leads
- **Engineering Leadership** - For CTOs, VPs of Engineering, and decision-makers

### Enabling Survey Cards

Once you've created a form and have its URL:

1. **Get the form URL** from `config.yaml`
2. **Update the FORM_URLS object** in `index.html`:
   ```javascript
   const FORM_URLS = {
       engineer: 'https://docs.google.com/forms/d/YOUR_ID/viewform',
       devops: 'https://docs.google.com/forms/d/YOUR_ID/viewform',
       leadership: 'https://docs.google.com/forms/d/YOUR_ID/viewform'
   };
   ```

3. **Enable the card** by removing the `disabled` class. For example, to enable DevOps:
   ```html
   <!-- Change from: -->
   <a href="#" class="role-card disabled" onclick="return false;">

   <!-- To: -->
   <a href="DEVOPS_FORM_URL" class="role-card" id="devops-card">
   ```

4. **Remove the "Coming Soon" badge**:
   ```html
   <!-- Delete this line: -->
   <span class="coming-soon">Coming Soon</span>
   ```

5. **Update the JavaScript** to set the href:
   ```javascript
   document.getElementById('devops-card').href = FORM_URLS.devops;
   ```

### Deployment Options

#### Option 1: GitHub Pages (Free & Easy)

1. Push the `index.html` file to a GitHub repository
2. Go to repository Settings > Pages
3. Select the branch and folder containing `index.html`
4. GitHub will provide a URL like: `https://yourusername.github.io/repo-name/survey/`

#### Option 2: Netlify Drop (Free & Instant)

1. Go to [drop.netlify.com](https://app.netlify.com/drop)
2. Drag and drop the `survey` folder (or just `index.html`)
3. Get an instant URL like: `https://random-name.netlify.app`

#### Option 3: Google Cloud Storage

1. Upload `index.html` to a GCS bucket
2. Enable public access
3. Use bucket URL or map to custom domain

#### Option 4: Your Own Domain

1. Host on any web server (nginx, Apache, etc.)
2. Upload `index.html` to your web root
3. Access via your custom domain

### Customization

You can customize the router page by editing `index.html`:

- **Colors**: Modify the gradient colors in the CSS (line ~12-14)
- **Icons**: Change the emoji icons in the role cards (line ~58, ~67, ~76)
- **Text**: Update descriptions, footer content, etc.
- **Branding**: Add your logo or adjust styling to match your brand

### Testing Locally

```bash
# Simple Python HTTP server
cd survey
python3 -m http.server 8000

# Then open: http://localhost:8000/index.html
```

Or just open `index.html` directly in your browser.

## Survey Definitions

Three surveys are available in `survey/`:

### Engineers Survey (`engineers.yaml`)
- **Target audience**: Software engineers, developers, technical contributors
- **Focus**: Technical usage patterns, pain points, tooling needs
- **Estimated time**: 5-7 minutes
- **Sections**: 7 sections covering usage, challenges, security, tooling, and support interest

### DevOps/Platform Managers Survey (`devops-managers.yaml`)
- **Target audience**: DevOps engineers, SREs, platform team leads
- **Focus**: Operational challenges, team efficiency, scale management
- **Estimated time**: 5-7 minutes
- **Sections**: 7 sections covering team info, scale, productivity, security, tooling, and budget

### Executives Survey (`executives.yaml`)
- **Target audience**: CTOs, VPs of Engineering, technology leadership
- **Focus**: Strategic risk assessment, governance, investment decisions
- **Estimated time**: 5 minutes
- **Sections**: 7 sections covering dependencies, risk, compliance, impact, and procurement

## Creating New Surveys

To create additional survey variations:

1. **Create a new YAML file** in `survey/`:
   ```bash
   cp survey/engineers.yaml survey/new-survey.yaml
   ```

2. **Edit the survey structure** following the YAML format (see `bin/README.md` for format details)

3. **Generate the Google Form**:
   ```bash
   cd bin
   ./publish-survey ../survey/new-survey.yaml
   ```

4. **URLs are automatically saved** to `config.yaml`

5. **Update the router page** if needed

## Distribution

Once deployed, you can:
- Share the router page URL at conferences (like KubeCon)
- Include it in email campaigns
- Add QR codes on printed materials pointing to the page
- Embed it on yaml.com or other websites
- Share on social media or community forums

The router ensures respondents take the survey most relevant to their role, improving response quality and data organization.

## URL Management

The script automatically tracks all generated URLs in `config.yaml`:

```yaml
engineers-form-url: https://docs.google.com/forms/d/.../viewform
engineers-edit-url: https://docs.google.com/forms/d/.../edit
engineers-sheet-url: https://docs.google.com/spreadsheets/d/.../edit
devops-managers-form-url: https://...
devops-managers-edit-url: https://...
devops-managers-sheet-url: https://...
executives-form-url: https://...
executives-edit-url: https://...
executives-sheet-url: https://...
```

**Key types:**
- `-form-url`: Public URL for respondents to fill out the survey
- `-edit-url`: Admin URL for customizing the form
- `-sheet-url`: Response spreadsheet for viewing/analyzing data

This makes it easy to:
- Reference URLs without searching through terminal output
- Update the router page (`index.html`)
- Share the correct URLs with different stakeholders
- Keep track of multiple survey versions

## Next Steps

1. **Set up Google Cloud credentials** (see `bin/README.md`)
2. **Create all three forms** using the script
3. **Link response spreadsheets** (manual step in Google Forms UI)
4. **Update router page** with form URLs from `config.yaml`
5. **Deploy router page** to hosting service
6. **Test all forms** before sharing publicly
7. **Configure form settings** (sharing, collection, notifications)

## Getting Help

- **Script issues**: See `bin/README.md` troubleshooting section
- **YAML format questions**: See `bin/README.md` YAML format section
- **Router page customization**: Edit `index.html` directly
- **Form configuration**: Use Google Forms UI after creation

## About

These surveys help us understand how organizations use YAML infrastructure and what support they need. Your feedback directly informs product development and support offerings.

**YAML LLC** is being founded by Ingy döt Net (co-creator of YAML) to provide professional maintenance and enterprise support for critical YAML infrastructure.
