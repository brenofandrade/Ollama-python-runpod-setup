#!/bin/bash
set -euo pipefail

log() { echo "[start] $(date) - $*"; }

# ---------------------------------------------------------------------------- #
#                          Function Definitions                                #
# ---------------------------------------------------------------------------- #

execute_script() {
    local path="$1"
    local msg="$2"
    if [[ -f "$path" ]]; then
        log "$msg ($path)"
        bash "$path"
    else
        log "Script não encontrado: $path"
    fi
}

setup_ssh() {
    if [[ -n "${PUBLIC_KEY:-}" ]]; then
        log "Configurando acesso SSH..."
        mkdir -p ~/.ssh
        echo "$PUBLIC_KEY" >> ~/.ssh/authorized_keys
        chmod 700 -R ~/.ssh

        for type in rsa dsa ecdsa ed25519; do
            key="/etc/ssh/ssh_host_${type}_key"
            if [[ ! -f "$key" ]]; then
                ssh-keygen -t "$type" -f "$key" -q -N ''
            fi
        done

        service ssh start
        log "Serviço SSH iniciado com sucesso."
    else
        log "PUBLIC_KEY não definido — SSH desativado."
    fi
}

start_jupyter() {
    local LOG_DIR="/workspace/logs"
    mkdir -p "$LOG_DIR"
    cd /workspace || cd /

    local PASSWORD_OPT=""
    if [[ -n "${JUPYTERLAB_PASSWORD:-}" ]]; then
        PASSWORD_OPT="--ServerApp.token=${JUPYTERLAB_PASSWORD}"
        log "JupyterLab iniciado com senha configurada."
    else
        PASSWORD_OPT="--ServerApp.token=''"
        log "JupyterLab iniciado sem senha (JUPYTERLAB_PASSWORD não definido)."
    fi

    nohup jupyter lab \
        --allow-root \
        --no-browser \
        --port=8888 \
        --ip=0.0.0.0 \
        --FileContentsManager.delete_to_trash=False \
        --ContentsManager.allow_hidden=True \
        --ServerApp.allow_origin="*" \
        --ServerApp.preferred_dir=/workspace \
        $PASSWORD_OPT \
        &> "${LOG_DIR}/jupyterlab.log" &

    log "JupyterLab em execução (logs: ${LOG_DIR}/jupyterlab.log)"
}

start_ollama() {
    local LOG_FILE="${OLLAMA_LOG_FILE:-/workspace/logs/ollama.log}"
    local MODELS_DIR="${OLLAMA_MODELS_DIR:-/workspace/models}"

    mkdir -p "$(dirname "$LOG_FILE")" "$MODELS_DIR"
    : > "$LOG_FILE"

    # Evita iniciar múltiplas instâncias
    if pgrep -x "ollama" >/dev/null 2>&1; then
        log "Ollama já está em execução. Pulando inicialização."
        return
    fi

    log "Iniciando Ollama em background..."
    nohup ollama serve --host 0.0.0.0 --models-dir "$MODELS_DIR" > "$LOG_FILE" 2>&1 &
    local pid=$!
    echo "$pid" > /workspace/ollama.pid
    log "Ollama iniciado (PID=$pid). Logs em $LOG_FILE"
}

# ---------------------------------------------------------------------------- #
#                               Main Program                                   #
# ---------------------------------------------------------------------------- #

log "Iniciando processo principal do Pod..."

execute_script "/pre_start.sh" "Executando pre-start script"

setup_ssh
start_jupyter
start_ollama

execute_script "/post_start.sh" "Executando post-start script"

log "Inicialização completa. Aguardando indefinidamente..."
sleep infinity
