#!/bin/bash
set -euo pipefail

echo "[pre_start] $(date) - Iniciando sincronização do ambiente virtual..."

if [[ -d "/venv" ]]; then
    echo "[pre_start] Sincronizando /venv → /workspace/venv ..."
    rsync -a /venv/ /workspace/venv/ && rm -rf /venv
else
    echo "[pre_start] Diretório /venv não encontrado — pulando sincronização."
fi

# Atualiza caminhos dentro dos binários
if [[ -d "/workspace/venv/bin" ]]; then
    echo "[pre_start] Corrigindo paths internos de /workspace/venv/bin ..."
    find "/workspace/venv/bin" -type f | while read -r file; do
        if file "$file" | grep -q "text"; then
            sed -i "s|VIRTUAL_ENV='/venv'|VIRTUAL_ENV='/workspace/venv'|g" "$file"
            sed -i "s|VIRTUAL_ENV '/venv'|VIRTUAL_ENV '/workspace/venv'|g" "$file"
            sed -i "s|#!/venv/bin/python|#!/workspace/venv/bin/python|g" "$file"
        fi
    done
    echo "[pre_start] Paths atualizados com sucesso."
else
    echo "[pre_start] Diretório /workspace/venv/bin inexistente — nada a corrigir."
fi

echo "[pre_start] Finalizado."