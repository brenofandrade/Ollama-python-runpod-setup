#!/bin/bash
set -e

echo "=== Iniciando o ambiente Ollama ==="

# Opcional: exibir versão
ollama --version || true

echo "Executando post_start.sh..."
/post_start.sh

echo "Iniciando Ollama server em primeiro plano..."
# Substitui o shell pelo processo Ollama
exec ollama serve --host 0.0.0.0 --models-dir /workspace/models
