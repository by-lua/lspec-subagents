#!/usr/bin/env bash
# @lspec/subagents — Atualizador (desinstala tudo e reinstala limpo)
# Uso: curl -fsSL https://raw.githubusercontent.com/by-lua/lspec-subagents/main/update.sh | bash

set -uo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

REPO="https://github.com/by-lua/lspec-subagents.git"

PI_AGENTS_DIR="$HOME/.pi/agents"
PI_AGENT_DIR="$HOME/.pi/agent"

echo ""
echo -e "${YELLOW}╔══════════════════════════════════╗${NC}"
echo -e "${YELLOW}║   @lspec/subagents — Atualizando ║${NC}"
echo -e "${YELLOW}╚══════════════════════════════════╝${NC}"
echo ""

# Remover agentes lspec existentes
echo -e "${BLUE}→ Removendo versão anterior...${NC}"
for agent_file in "$PI_AGENTS_DIR"/orchestrator.md "$PI_AGENTS_DIR"/explorer.md "$PI_AGENTS_DIR"/librarian.md "$PI_AGENTS_DIR"/oracle.md "$PI_AGENTS_DIR"/designer.md "$PI_AGENTS_DIR"/fixer.md "$PI_AGENTS_DIR"/observer.md "$PI_AGENTS_DIR"/council.md "$PI_AGENTS_DIR"/councillor.md; do
    [[ -f "$agent_file" ]] || continue
    agent_name=$(basename "$agent_file")
    rm "$agent_file"
    echo -e "  ${GREEN}✓${NC} Removido: agents/$agent_name"
done

# Clonar versão nova
REPO_DIR="$(mktemp -d)"
echo -e "${BLUE}→ Baixando versão nova...${NC}"
git clone --depth 1 "$REPO" "$REPO_DIR" 2>/dev/null || {
    echo -e "${RED}✗ Erro ao clonar. Git instalado?${NC}"; rm -rf "$REPO_DIR"; exit 1; }

# Copiar agentes (.pi/agents/)
agent_count=0
if [[ -d "$REPO_DIR/.pi/agents" ]]; then
    mkdir -p "$PI_AGENTS_DIR"
    echo -e "${BLUE}→ Instalando agentes...${NC}"
    for agent_file in "$REPO_DIR"/.pi/agents/*.md; do
        [[ -f "$agent_file" ]] || continue
        agent_name=$(basename "$agent_file")
        cp "$agent_file" "$PI_AGENTS_DIR/$agent_name"
        echo -e "  ${GREEN}✓${NC} agents/$agent_name"
        ((agent_count++))
    done
fi

# Copiar config de modelos (não sobrescreve)
if [[ -f "$REPO_DIR/lspec-model-config.example.json" ]]; then
    if [[ ! -f "$PI_AGENT_DIR/lspec-model-config.json" ]]; then
        mkdir -p "$PI_AGENT_DIR"
        cp "$REPO_DIR/lspec-model-config.example.json" "$PI_AGENT_DIR/lspec-model-config.json"
        echo -e "  ${GREEN}✓${NC} lspec-model-config.json (criado com defaults)"
    else
        echo -e "  ${BLUE}⊘${NC} lspec-model-config.json (já existe, mantido)"
    fi
fi

echo ""
echo -e "${GREEN}✓ @lspec/subagents atualizado!${NC} ($agent_count agentes)"
echo ""
echo "Agentes: orchestrator | explorer | librarian | oracle | designer | fixer | observer | council | councillor"
echo "Config:   ~/.pi/agent/lspec-model-config.json"
echo ""

rm -rf "$REPO_DIR"