#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MCP_FILE="$ROOT_DIR/.vscode/mcp.json"
CONTEXT_FILE="$ROOT_DIR/docs/mcp-questions.yaml"
ENV_FILE="$ROOT_DIR/.secrets/.env"

if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
  echo "[MCP] Variaveis carregadas de .secrets/.env"
else
  echo "[MCP] .secrets/.env nao encontrado. Prosseguindo sem variaveis extras."
fi

if [[ ! -f "$MCP_FILE" ]]; then
  echo "[MCP] ERRO: arquivo .vscode/mcp.json nao encontrado."
  exit 1
fi

if [[ ! -f "$CONTEXT_FILE" ]]; then
  echo "[MCP] ERRO: arquivo docs/mcp-questions.yaml nao encontrado."
  exit 1
fi

echo "[MCP] Configuracao MCP detectada: .vscode/mcp.json"
echo "[MCP] Contexto carregado: docs/mcp-questions.yaml"
echo "[MCP] Projeto pronto para uso de MCP no VS Code."
