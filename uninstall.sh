#!/usr/bin/env bash
# @lspec/subagents — Desinstalador
# Uso: curl -fsSL https://raw.githubusercontent.com/by-lua/lspec-subagents/main/uninstall.sh | bash

set -uo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

PI_AGENTS_DIR="$HOME/.pi/agents"
PI_AGENT_DIR="$HOME/.pi/agent"

echo ""
echo -e "${BLUE}╔═════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   @lspec/subagents — Desinstalador  ║${NC}"
echo -e "${BLUE}╚═════════════════════════════════════╝${NC}"
echo ""

lspec_agents=("orchestrator" "explorer" "librarian" "oracle" "designer" "fixer" "observer" "council" "councillor")
removed=0

for agent in "${lspec_agents[@]}"; do
    if [[ -f "$PI_AGENTS_DIR/${agent}.md" ]]; then
        rm "$PI_AGENTS_DIR/${agent}.md"
        echo -e "  ${YELLOW}✗${NC} agents/${agent}.md"
        ((removed++))
    fi
done

# Remover config
if [[ -f "$PI_AGENT_DIR/lspec-model-config.json" ]]; then
    echo -e "  ${YELLOW}⚠${NC} lspec-model-config.json mantido (pode ter config do usuário)"
fi

echo ""
echo -e "${GREEN}✓ $removed agentes L-Spec removidos${NC}"
echo -e "${BLUE}Extensão @tintinweb/pi-subagents mantida no npm (use npm uninstall se quiser remover)${NC}"
echo ""