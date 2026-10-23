#!/bin/bash
# Required secrets (HF Space > Settings > Secrets):
#   TERM_USER, TERM_PASS  -> login for the web terminal (REQUIRED, don't skip)
#   GH_TOKEN              -> GitHub personal access token (repo scope)
#   GH_REPO               -> e.g. yourname/yourrepo
#   + your model API key, e.g. ANTHROPIC_API_KEY / OPENAI_API_KEY / OPENROUTER_API_KEY

if [ -z "$TERM_USER" ] || [ -z "$TERM_PASS" ]; then
  echo "Set TERM_USER and TERM_PASS secrets first. Exiting."
  exit 1
fi

WORK=/home/node/work
git config --global user.email "bot@space.local"
git config --global user.name "space-bot"

# Restore files from GitHub on every start
if [ -n "$GH_TOKEN" ] && [ -n "$GH_REPO" ]; then
  git clone "https://x-access-token:${GH_TOKEN}@github.com/${GH_REPO}.git" "$WORK" \
    || mkdir -p "$WORK"
else
  mkdir -p "$WORK"
fi
cd "$WORK"

# Auto-save loop: commit + push every 2 minutes
(
  while true; do
    sleep 120
    cd "$WORK" || continue
    if [ -n "$(git status --porcelain)" ]; then
      git add -A
      git commit -m "auto-save $(date -u +%F_%T)" >/dev/null 2>&1
      git push >/dev/null 2>&1
    fi
  done
) &

# Web terminal on port 7860 (HF default), opens opencode; falls back to bash if it exits
exec ttyd -p "${PORT:-10000}" -W -c "${TERM_USER}:${TERM_PASS}" bash -c "opencode; exec bash"
