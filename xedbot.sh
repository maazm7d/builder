#!/bin/env bash
set -euo pipefail

echo "🔧 Starting xedbot.sh..."

file="$1"
build_info="$2"

echo "📄 File to upload: $file"
echo "📝 Build info:"
echo "$build_info"

# Check if required env variables are set
if [[ -z "${BOT_TOKEN:-}" || -z "${CHAT_ID:-}" ]]; then
  echo "❌ BOT_TOKEN or CHAT_ID not set."
  exit 26
fi

# Check if file exists
if [[ ! -f "$file" ]]; then
  echo "❌ ZIP file not found at path: $file"
  exit 26
else
  echo "✅ Found ZIP file: $(basename "$file") (Size: $(du -h "$file" | cut -f1))"
fi

# Escape build info for MarkdownV2
escaped_build_info="${build_info//\\/\\\\}"

# Escape underscores in URL and Title
escaped_title="${TITLE//_/\\_}"
escaped_repo_url="${GITHUB_SERVER_URL//_/\\_}/${GITHUB_REPOSITORY//_/\\_}/actions/runs/${GITHUB_RUN_ID}"
escaped_ks_url="${K_S//_/\\_}"

# Create message caption
msg="*${escaped_title}*
\`\`\`
$escaped_build_info
\`\`\`
[View Workflow Run]($escaped_repo_url)
[Kernel Source]($escaped_ks_url)
*Note: Always backup working boot before flash\\.*"

echo "✉️ Sending message to Telegram..."
response=$(curl -s -w "\n%{http_code}" -F document=@"$file" \
  -F chat_id="$CHAT_ID" \
  -F "disable_web_page_preview=true" \
  -F "parse_mode=markdownv2" \
  -F caption="$msg" \
  "https://api.telegram.org/bot$BOT_TOKEN/sendDocument")

# Split curl response and HTTP status
body=$(echo "$response" | sed '$d')
http_code=$(echo "$response" | tail -n1)

if [[ "$http_code" -ne 200 ]]; then
  echo "❌ Telegram upload failed with HTTP $http_code"
  echo "🔎 Response: $body"
  exit 26
fi

echo "✅ Telegram upload succeeded!"
