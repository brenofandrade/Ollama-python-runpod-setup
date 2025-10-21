#!/bin/bash
set -euo pipefail

echo "=== Iniciando o ambiente Ollama ==="

# Opcional: exibir versão
ollama --version || true

# Garante diretório de modelos
mkdir -p /workspace/models

echo "Executando post_start.sh antes do servidor..."
/post_start.sh

echo "Iniciando Ollama server (em primeiro plano)..."
exec ollama serve --host 0.0.0.0 --models-dir /workspace/models

