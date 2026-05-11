#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  url_report.sh <url> [-o output.md]

Examples:
  bash ./scripts/url_report.sh "https://example.com"
  bash ./scripts/url_report.sh "https://example.com" -o report.md
USAGE
}

URL=""
OUTPUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -o|--output)
      if [[ $# -lt 2 ]]; then
        echo "error: missing output path after $1" >&2
        exit 2
      fi
      OUTPUT="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "error: unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      if [[ -n "$URL" ]]; then
        echo "error: only one URL is supported" >&2
        usage >&2
        exit 2
      fi
      URL="$1"
      shift
      ;;
  esac
done

if [[ -z "$URL" ]]; then
  echo "error: URL is required" >&2
  usage >&2
  exit 2
fi

if [[ ! "$URL" =~ ^https?:// ]]; then
  echo "error: URL must start with http:// or https://" >&2
  exit 2
fi

command -v curl >/dev/null 2>&1 || {
  echo "error: curl is required in WSL Ubuntu" >&2
  exit 127
}

PYTHON_BIN=""
for candidate in python3 python; do
  if command -v "$candidate" >/dev/null 2>&1 && "$candidate" -c 'import sys' >/dev/null 2>&1; then
    PYTHON_BIN="$candidate"
    break
  fi
done

if [[ -z "$PYTHON_BIN" ]]; then
  echo "error: python3 is required in WSL Ubuntu" >&2
  exit 127
fi

BODY_FILE="$(mktemp)"
HEADER_FILE="$(mktemp)"
trap 'rm -f "$BODY_FILE" "$HEADER_FILE"' EXIT

HTTP_CODE="$(
  curl \
    --location \
    --silent \
    --show-error \
    --max-time 30 \
    --connect-timeout 10 \
    --user-agent "codex-url-report-plugin/0.1.0" \
    --dump-header "$HEADER_FILE" \
    --output "$BODY_FILE" \
    --write-out "%{http_code}" \
    "$URL"
)"

TITLE="$(
  "$PYTHON_BIN" - "$BODY_FILE" <<'PY'
import html
import sys
from html.parser import HTMLParser


class TitleParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.in_title = False
        self.parts = []

    def handle_starttag(self, tag, attrs):
        if tag.lower() == "title":
            self.in_title = True

    def handle_endtag(self, tag):
        if tag.lower() == "title":
            self.in_title = False

    def handle_data(self, data):
        if self.in_title:
            self.parts.append(data)


path = sys.argv[1]
parser = TitleParser()
with open(path, "rb") as f:
    data = f.read(2_000_000)

text = data.decode("utf-8", errors="replace")
parser.feed(text)
title = " ".join(" ".join(parser.parts).split())
print(html.unescape(title) if title else "N/A")
PY
)"

FETCHED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

REPORT="$(
  cat <<EOF
# URL Report

| Field | Value |
| --- | --- |
| URL | \`$URL\` |
| HTTP status | \`$HTTP_CODE\` |
| Page title | $TITLE |
| Fetched at | \`$FETCHED_AT\` |

EOF
)"

if [[ -n "$OUTPUT" ]]; then
  printf "%s" "$REPORT" > "$OUTPUT"
  echo "Wrote Markdown report to $OUTPUT" >&2
else
  printf "%s" "$REPORT"
fi
