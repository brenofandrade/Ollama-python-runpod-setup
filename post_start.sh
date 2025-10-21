#!/bin/bash
set -euo pipefail

echo "=== Pós-inicialização do ambiente Ollama ==="

# Opcional: exibir versão
ollama --version || true

# Garante diretório de modelos
mkdir -p /workspace/models

# Opcional: pré-baixar modelos definidos em OLLAMA_PULL_MODELS (se houver)
# Exemplo: OLLAMA_PULL_MODELS="llama3.1 qwen2.5"
if [[ -n "${OLLAMA_PULL_MODELS:-}" ]]; then
  echo "Pré-baixando modelos: $OLLAMA_PULL_MODELS"
  for model in $OLLAMA_PULL_MODELS; do
    echo "Baixando modelo: $model"
    if ! ollama pull "$model"; then
      echo "Aviso: falha ao puxar $model; continuando."
    fi
  done
fi

echo "post_start.sh concluído."

