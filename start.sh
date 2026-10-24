#!/bin/bash
# Env vars:
#   TERM_USER, TERM_PASS   login (required)
#   MODE                   "web" (default, mobile UI) or "terminal" (plain bash)
#   GH_TOKEN, GH_REPO      optional GitHub storage (GH_REPO like username/repo)
#   + your model API key if you want (or use /connect inside OpenCode)

if [ -z "$TERM_USER" ] || [ -z "$TERM_PASS" ]; then
  echo "Set TERM_USER and TERM_PASS env vars. Exiting."
  exit 1
fi

WORK=/root/work
git config --global user.email "bot@render.local"
git config --global user.name "render-bot"

if [ -n "$GH_TOKEN" ] && [ -n "$GH_REPO" ]; then
  if git clone "https://x-access-token:${GH_TOKEN}@github.com/${GH_REPO}.git" "$WORK"; then
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

if [ "${MODE:-web}" = "terminal" ]; then
  # wrapper written at runtime: tmux if available, else plain bash
  cat > /root/shell.sh << 'WRAP'
#!/bin/bash
cd /root/work 2>/dev/null || cd /root
if command -v tmux >/dev/null 2>&1; then
  exec tmux new-session -A -s main
else
  exec /bin/bash -l
fi
WRAP
  chmod +x /root/shell.sh
  exec ttyd -p "${PORT:-10000}" -W -P 15 -r 3 \
    -t rendererType=dom -t fontSize=15 -t disableLeaveAlert=true \
    -c "${TERM_USER}:${TERM_PASS}" /bin/bash /root/shell.sh
else
  export OPENCODE_SERVER_USERNAME="$TERM_USER"
  export OPENCODE_SERVER_PASSWORD="$TERM_PASS"
  exec opencode web --hostname 0.0.0.0 --port "${PORT:-10000}"
fi
