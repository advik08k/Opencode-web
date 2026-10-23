#!/bin/bash
# Env vars needed: TERM_USER, TERM_PASS
# Optional (GitHub storage): GH_TOKEN, GH_REPO (like username/repo)

if [ -z "$TERM_USER" ] || [ -z "$TERM_PASS" ]; then
  echo "Set TERM_USER and TERM_PASS env vars. Exiting."
  exit 1
fi

WORK=/root/work
git config --global user.email "bot@render.local"
git config --global user.name "render-bot"

if [ -n "$GH_TOKEN" ] && [ -n "$GH_REPO" ]; then
  if git clone "https://x-access-token:${GH_TOKEN}@github.com/${GH_REPO}.git" "$WORK"; then
    # auto-save to GitHub every 2 minutes
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
  else
    echo "GitHub clone failed, check GH_TOKEN / GH_REPO. Continuing without sync."
    mkdir -p "$WORK"
  fi
else
  mkdir -p "$WORK"
fi

cd "$WORK"
export TERM=xterm-256color
export COLORTERM=truecolor
exec ttyd -p "${PORT:-10000}" -W -P 20 \
  -t rendererType=dom -t fontSize=15 -t disableLeaveAlert=true \
  -c "${TERM_USER}:${TERM_PASS}" bash
