#!/usr/bin/env bash
# @lspec/subagents — Desinstalador
# Uso: curl -fsSL https://raw.githubusercontent.com/by-lua/lspec-subagents/main/uninstall.sh | bash

set -uo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PI_AGENTS_DIR="$HOME/.pi/agents"
PI_AGENT_DIR="$HOME/.pi/agent"

echo ""
echo -e "${YELLOW}Desinstalando @lspec/subagents...${NC}"

# Remover todos os agentes lspec
for agent_file in "$PI_AGENTS_DIR"/orchestrator.md "$PI_AGENTS_DIR"/explorer.md "$PI_AGENTS_DIR"/librarian.md "$PI_AGENTS_DIR"/oracle.md "$PI_AGENTS_DIR"/designer.md "$PI_AGENTS_DIR"/fixer.md "$PI_AGENTS_DIR"/observer.md "$PI_AGENTS_DIR"/council.md "$PI_AGENTS_DIR"/councillor.md; do
    [[ -f "$agent_file" ]] || continue
    agent_name=$(basename "$agent_file")
    rm "$agent_file"
    echo -e "  ${GREEN}✓${NC} Removido: agents/$agent_name"
done

# Config de modelos é preservado (pode ser usado por outros projetos)
if [[ -f "$PI_AGENT_DIR/lspec-model-config.json" ]]; then
    echo -e "  ${BLUE}⊘${NC} lspec-model-config.json mantido (config do usuário)"
fi

echo ""
echo -e "${GREEN}✓ @lspec/subagents desinstalado.${NC}"
echo -e "${BLUE}ℹ${NC} Para remover também a config: rm ~/.pi/agent/lspec-model-config.json"
echo ""