# ===============================================================
# 🧱 Base Image: Ubuntu 22.04 (LTS, estável e leve)
# ===============================================================
FROM ubuntu:22.04

# ===============================================================
# 🔧 Configurações de ambiente básicas
# ===============================================================
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    OLLAMA_HOST=0.0.0.0 \
    OLLAMA_MODELS=/workspace/models \
    OLLAMA_KEEP_ALIVE=24h \
    PATH="/workspace/venv/bin:$PATH"

# ===============================================================
# 🧰 Dependências de sistema mínimas
# ===============================================================
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        vim \
        htop \
        curl \
        wget \
        git \
        rsync \
        python3 \
        python3-venv \
        python3-pip \
        ca-certificates \
        openssh-server \
        nginx \
        gnupg \
        iputils-ping \
        net-tools \
        lsof \
        procps \
        jq \
    && rm -rf /var/lib/apt/lists/*

# ===============================================================
# 🧠 Instalação do Ollama
# ===============================================================
# O script oficial detecta GPU se disponível.
RUN curl -fsSL https://ollama.com/install.sh | bash

# ===============================================================
# 🧩 Estrutura de diretórios persistentes
# ===============================================================
RUN mkdir -p \
    /workspace \
    /workspace/models \
    /workspace/logs \
    /workspace/startup

# Permissões genéricas
RUN chmod 777 -R /workspace

# ===============================================================
# 🪄 Copia scripts de inicialização
# ===============================================================
COPY pre_start.sh /pre_start.sh
COPY start.sh /start.sh
COPY post_start.sh /post_start.sh

RUN chmod +x /pre_start.sh /start.sh /post_start.sh

# ===============================================================
# ⚙️ Exposição de portas
# ===============================================================
# 11434 → Ollama
# 8888 → Jupyter (via start.sh)
# 22 → SSH (via start.sh)
EXPOSE 11434 8888 22

# ===============================================================
# ❤️ Healthcheck para Ollama
# ===============================================================
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD curl -fsS http://localhost:11434/api/tags || exit 1

# ===============================================================
# 🚀 Comando padrão
# ===============================================================
CMD ["/start.sh"]
