# syntax=docker/dockerfile:1
###############################################################################
# Amazon Q Developer CLI (headless) + AWS Diagram & Docs MCP servers
# Build :  docker build -t amazon-q-diagrams .
# Run   :  docker run -it --rm -v $PWD:/work amazon-q-diagrams chat
###############################################################################

FROM ubuntu:22.04

# ─────────────────────────────────────────────────────────────────────────────
# 1. Base OS packages – curl/unzip, Python 3.11, GraphViz
# ─────────────────────────────────────────────────────────────────────────────
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl unzip ca-certificates \
        python3.11 python3.11-venv python3-pip \
        graphviz && \
    ln -s /usr/bin/python3.11 /usr/local/bin/python && \
    rm -rf /var/lib/apt/lists/*

# ─────────────────────────────────────────────────────────────────────────────
# 2. Fast Python tooling (uv + uvx)
# ─────────────────────────────────────────────────────────────────────────────
RUN pip install --no-cache-dir uv              # uv also provides the `uvx` launcher

# ─────────────────────────────────────────────────────────────────────────────
# 3. Amazon Q Developer CLI – musl build (non-interactive, root-safe install)
# ─────────────────────────────────────────────────────────────────────────────
ENV Q_VERSION=latest
RUN curl -fsSL \
      "https://desktop-release.q.us-east-1.amazonaws.com/${Q_VERSION}/q-x86_64-linux-musl.zip" \
      -o /tmp/q.zip && \
    unzip -q /tmp/q.zip -d /opt && \
    bash /opt/q/install.sh --no-confirm --force && \
    ln -s /root/.local/bin/q /usr/local/bin/q && \
    rm -rf /tmp/q.zip /opt/q

# ─────────────────────────────────────────────────────────────────────────────
# 4. AWS Diagram & Documentation MCP servers
# ─────────────────────────────────────────────────────────────────────────────
RUN uv pip install --system --no-cache-dir \
        awslabs.aws-diagram-mcp-server \
        awslabs.aws-documentation-mcp-server

# Pre-seed Q with an MCP manifest so both servers autostart
COPY mcp.json /root/.aws/amazonq/mcp.json

# ─────────────────────────────────────────────────────────────────────────────
# 5. Entrypoint
# ─────────────────────────────────────────────────────────────────────────────
WORKDIR /work
ENTRYPOINT ["q"]
CMD ["chat"]
