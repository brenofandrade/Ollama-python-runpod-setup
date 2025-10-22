#!/bin/bash
set -euo pipefail
echo "[post_start] $(date) - Pós-inicialização: preparando modelos..."

mkdir -p /workspace/models

if [[ -n "${OLLAMA_PULL_MODELS:-}" ]]; then
  echo "[post_start] Baixando modelos: $OLLAMA_PULL_MODELS"
  for model in $OLLAMA_PULL_MODELS; do
    ollama pull "$model" || echo "Falha ao puxar $model (ignorando)"
  done
else
  echo "[post_start] Nenhum modelo definido em OLLAMA_PULL_MODELS"
fi

echo "[post_start] Concluído."
