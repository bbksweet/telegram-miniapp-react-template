#!/usr/bin/env bash
set -euo pipefail

if [ -f .env.local ]; then
  # shellcheck disable=SC1091
  source .env.local
fi

: "${BOT_TOKEN:?BOT_TOKEN is required (set in .env.local or env)}"
: "${BOT_USERNAME:?BOT_USERNAME is required (set in .env.local or env)}"
: "${WEBAPP_URL:?WEBAPP_URL is required (set in .env.local or env)}"

response=$(curl -sS -X POST "https://api.telegram.org/bot${BOT_TOKEN}/setChatMenuButton" \
  -H 'Content-Type: application/json' \
  --data "{\"menu_button\":{\"type\":\"web_app\",\"text\":\"Abrir app\",\"web_app\":{\"url\":\"${WEBAPP_URL}\"}}}")

ok=$(printf '%s' "$response" | node -e "const fs=require('fs');const j=JSON.parse(fs.readFileSync(0,'utf8'));process.stdout.write(String(Boolean(j.ok)))")
if [ "$ok" != "true" ]; then
  echo "Telegram API error: $response" >&2
  exit 1
fi

cmd_response=$(curl -sS -X POST "https://api.telegram.org/bot${BOT_TOKEN}/setMyCommands" \
  -H 'Content-Type: application/json' \
  --data '{"commands":[{"command":"start","description":"Abrir mini app"}]}')
cmd_ok=$(printf '%s' "$cmd_response" | node -e "const fs=require('fs');const j=JSON.parse(fs.readFileSync(0,'utf8'));process.stdout.write(String(Boolean(j.ok)))")
if [ "$cmd_ok" != "true" ]; then
  echo "Telegram API error (setMyCommands): $cmd_response" >&2
  exit 1
fi

echo "Bot menu configured for @${BOT_USERNAME} -> ${WEBAPP_URL}"
