FROM node:20-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl ca-certificates ripgrep \
    && rm -rf /var/lib/apt/lists/*

# ttyd is not in Debian bookworm repos, so grab the static binary
RUN curl -fsSL -o /usr/local/bin/ttyd \
    "https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.$(uname -m)" \
    && chmod +x /usr/local/bin/ttyd

RUN npm i -g opencode-ai

# run as non-root "node" user (uid 1000)
USER node
ENV HOME=/home/node
WORKDIR /home/node

COPY --chown=node:node start.sh /home/node/start.sh
RUN chmod +x /home/node/start.sh

EXPOSE 10000
CMD ["/home/node/start.sh"]
