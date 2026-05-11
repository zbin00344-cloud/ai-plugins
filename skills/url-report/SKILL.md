---
name: url-report
description: Generate a Markdown report for a website URL by fetching the page title and final HTTP status code with the bundled WSL Ubuntu shell script.
---

# URL Report

Use this skill when the user asks to inspect a website URL and produce a Markdown report containing:

- The input URL
- The final HTTP status code
- The page title
- The fetch timestamp

## Requirements

- Run the script through WSL Ubuntu.
- The Ubuntu environment must have `bash`, `curl`, and `python3`.
- Network access must be available from WSL.

## Usage

From the plugin root on Windows, run:

```powershell
wsl -d Ubuntu -- bash ./scripts/url_report.sh "https://example.com"
```

From inside WSL Ubuntu, run:

```bash
bash ./scripts/url_report.sh "https://example.com"
```

To write the report to a file:

```bash
bash ./scripts/url_report.sh "https://example.com" -o report.md
```

## Workflow

1. Accept one website URL from the user.
2. Run `scripts/url_report.sh` in WSL Ubuntu with that URL.
3. Return the Markdown output directly to the user, or save it when the user asks for a file.
4. If the command fails, explain the command error and mention whether the URL, WSL Ubuntu, `curl`, `python3`, or network access appears to be the issue.
