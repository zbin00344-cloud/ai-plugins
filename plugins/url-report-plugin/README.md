# URL Report Codex Plugin

This is a minimal Codex Plugin example. It accepts a website URL, fetches the final HTTP status code and HTML page title, then outputs a Markdown report.

## Structure

```text
url-report-plugin/
  .codex-plugin/
    plugin.json
  skills/
    url-report/
      SKILL.md
  scripts/
    url_report.sh
  assets/
  README.md
```

## Requirements

- Windows with WSL installed
- Ubuntu WSL distribution named `Ubuntu`
- `bash`, `curl`, and `python3` inside Ubuntu

Install missing Ubuntu packages with:

```bash
sudo apt update
sudo apt install -y curl python3
```

## Run

From this plugin root in PowerShell:

```powershell
wsl -d Ubuntu -- bash ./scripts/url_report.sh "https://example.com"
```

From inside WSL Ubuntu:

```bash
bash ./scripts/url_report.sh "https://example.com"
```

Save the Markdown report to a file:

```bash
bash ./scripts/url_report.sh "https://example.com" -o report.md
```

## Example Output

```markdown
# URL Report

| Field | Value |
| --- | --- |
| URL | `https://example.com` |
| HTTP status | `200` |
| Page title | Example Domain |
| Fetched at | `2026-05-12T00:00:00Z` |
```

## Plugin Manifest

The plugin manifest is stored at `.codex-plugin/plugin.json`. Codex discovers the bundled skill through the `skills` field:

```json
{
  "skills": "./skills/"
}
```

The skill explains when to run `scripts/url_report.sh` and how to call it through WSL Ubuntu.
