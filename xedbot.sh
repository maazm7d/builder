#!/bin/env bash
msg="*${TITLE//_/\\_}*
\`\`\`
${2//\\/\\\\}
\`\`\`
[View Workflow Run](${GITHUB_SERVER_URL//_/\\_}/${GITHUB_REPOSITORY//_/\\_}/actions/runs/${GITHUB_RUN_ID})
*Note: Always backup working boot before flash\\.*"

file="$1"
curl -s -F document=@"$file" "https://api.telegram.org/bot$BOT_TOKEN/sendDocument" \
	-F chat_id="$CHAT_ID" \
	-F "disable_web_page_preview=true" \
	-F "parse_mode=markdownv2" \
	-F caption="$msg"
