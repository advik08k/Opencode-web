FROM node:20-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl ca-certificates ttyd ripgrep \
    && rm -rf /var/lib/apt/lists/*

RUN npm i -g opencode-ai

# HF Spaces runs as uid 1000 = "node" user
USER node
ENV HOME=/home/node
WORKDIR /home/node

COPY --chown=node:node start.sh /home/node/start.sh
RUN chmod +x /home/node/start.sh

EXPOSE 10000
CMD ["/home/node/start.sh"]
