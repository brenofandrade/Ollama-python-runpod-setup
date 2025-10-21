FROM ubuntu:22.04

# Dependências básicas sem recomendações extras e limpeza de cache para imagem menor
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       vim htop curl tar gzip ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Instala o Ollama
RUN curl -fsSL https://ollama.com/install.sh | sh

WORKDIR /

# Diretórios de trabalho e modelos
RUN mkdir -p /workspace /workspace/models
ENV OLLAMA_MODELS=/workspace/models

COPY start.sh /start.sh
COPY post_start.sh /post_start.sh
RUN chmod +x /start.sh /post_start.sh

# Porta padrão do Ollama
EXPOSE 11434

# Healthcheck simples (opcional)
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -fsS http://localhost:11434/api/tags || exit 1

CMD ["/start.sh"]
