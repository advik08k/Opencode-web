FROM node:20-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl ca-certificates nano unzip \
    && rm -rf /var/lib/apt/lists/*

# ttyd = web terminal (static binary)
RUN curl -fsSL -o /usr/local/bin/ttyd \
    "https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.$(uname -m)" \
    && chmod +x /usr/local/bin/ttyd

# OpenCode
RUN curl -fsSL https://opencode.ai/install | bash
ENV PATH="/root/.opencode/bin:${PATH}"

WORKDIR /root
COPY start.sh /root/start.sh
RUN chmod +x /root/start.sh

EXPOSE 10000
CMD ["/root/start.sh"]
