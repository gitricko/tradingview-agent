ARG HERMES_VERSION="v2026.5.7"
ARG OMNIROUTE_VERSION=3.7.9
ARG MODELRELAY_VERSION=1.17.1
ARG OLLAMA_VERSION=0.21.0
ARG NODE_VERSION=24
ARG CODE_SERVER_VERSION=4.118.0
ARG MNEMON_VERSION=0.1.3
ARG TARGETARCH

# Get the binaries from official Node image
FROM node:${NODE_VERSION}-slim AS node-bin

# Use your preferred Webtop flavor as the base (e.g., Ubuntu, Alpine)
FROM lscr.io/linuxserver/webtop:ubuntu-mate

# Install help utilities, Firefox, and clean up apt cache to reduce image size
# Remove Chromium if present (webtop includes it by default)
RUN apt-get update && \
    apt-get install -y htop zsh firefox && \
    apt-get remove -y chromium chromium-browser chromium-common libchromium* 2>/dev/null || true && \
    rm -rf /var/lib/apt/lists/*

# Copy Node.js binaries and libraries
COPY --from=node-bin --chown=abc:abc /usr/local/bin/node /usr/local/bin/
COPY --from=node-bin --chown=abc:abc /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm

# Start desktop launchers and bootstrap scripts automatically when the desktop loads
RUN mkdir -p /custom-cont-init.d
COPY --chown=abc:abc *.desktop /custom-cont-init.d
COPY --chown=abc:abc *.sh /custom-cont-init.d
COPY --chown=abc:abc *.json /custom-cont-init.d


# Install ModelRelay and start automatically when desktop loads
ARG MODELRELAY_VERSION
RUN npm install -g modelrelay@${MODELRELAY_VERSION} && \
    npm cache clean --force && \
    chown abc:abc -R /usr/local/lib/node_modules/modelrelay /usr/local/bin/modelrelay

# Install OmniRoute and start automatically when desktop loads
ARG OMNIROUTE_VERSION
RUN npm install -g omniroute@${OMNIROUTE_VERSION} && \
    npm cache clean --force && \
    mkdir -p /usr/local/lib/node_modules/omniroute/app/logs/application && \
    chown abc:abc -R /usr/local/lib/node_modules/omniroute /usr/local/bin/omniroute

# Install code-server and start automatically when desktop loads
ARG CODE_SERVER_VERSION
RUN curl -fsSL https://code-server.dev/install.sh | sh -s -- --version=${CODE_SERVER_VERSION} --method=standalone --prefix=/usr/local && \
    ln -fs /usr/local/lib/code-server-${CODE_SERVER_VERSION} /usr/local/lib/code-server && \
    ln -fs /usr/local/lib/code-server/bin/code-server /usr/local/bin/code && \
    rm -rf ~/.cache
COPY default.conf /defaults/default.conf

# Switch to the abc user and set zsh as the default shell for both root and abc
RUN usermod -s $(which zsh) root; usermod -s $(which zsh) abc

# ---------------------------------------------------------------------------
# Install TradingView Linux Desktop
# ---------------------------------------------------------------------------
# URL discovered from TradingView's JS bundle:
# https://tvd-packages.tradingview.com/ubuntu/stable/latest/jammy/tradingview_amd64.deb
RUN echo "Installing TradingView Linux Desktop..." && \
    curl -fsSL \
        "https://tvd-packages.tradingview.com/ubuntu/stable/latest/jammy/tradingview_amd64.deb" \
        -o /tmp/TradingView.deb \
    && apt-get update \
    && apt-get install -y --no-install-recommends /tmp/TradingView.deb \
    && rm -f /tmp/TradingView.deb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && chown -R abc:abc /opt/TradingView \ 
    && echo "[TradingView] Installed successfully"
    
EXPOSE 8888
