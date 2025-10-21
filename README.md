# Ollama-python-runpod-setup

Configuração mínima para subir um servidor Ollama em Docker, com hook de pós-inicialização para preparar o ambiente e opcionalmente pré‑baixar modelos.

## Requisitos
- Docker 20+

## Construir a imagem
```
docker build -t my-ollama .
```

## Executar
- Porta exposta: `11434` (HTTP API do Ollama)
- Diretório de modelos: `/workspace/models`

Execução simples:
```
docker run --rm -p 11434:11434 my-ollama
```

Persistindo modelos em volume local (recomendado):
```
docker run --rm -p 11434:11434 \
  -v "${PWD}/models:/workspace/models" \
  my-ollama
```

Pré‑baixar modelos automaticamente no primeiro start (opcional):
```
docker run --rm -p 11434:11434 \
  -e OLLAMA_PULL_MODELS="llama3.1 qwen2.5:latest" \
  my-ollama
```

O script `post_start.sh` executa antes do servidor subir, garantindo a criação do diretório de modelos e, se a variável `OLLAMA_PULL_MODELS` estiver definida, fará `ollama pull` para cada modelo listado (se algum falhar, o start continua).

## Notas
- A variável `OLLAMA_MODELS` é definida para `/workspace/models` na imagem e o servidor é iniciado com `--models-dir /workspace/models`.
- Para uso em produção, considere rodar como usuário não‑root e fixar a versão do Ollama no `Dockerfile`.
