#!/usr/bin/env bash
# lspec-subagents — Desinstalador
# Uso: curl -fsSL https://raw.githubusercontent.com/by-lua/lspec-subagents/main/uninstall.sh | bash

set -uo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

PI_AGENTS_DIR="$HOME/.pi/agents"
PI_AGENT_DIR="$HOME/.pi/agent"

echo ""
echo -e "${BLUE}╔═════════════════════════════════╗${NC}"
echo -e "${BLUE}║  lspec-subagents — Desinstalar  ║${NC}"
echo -e "${BLUE}╚═════════════════════════════════╝${NC}"
echo ""

# ── Remover extensão ──
echo -e "${BLUE}→ Removendo extensão...${NC}"
if command -v pi &>/dev/null; then
    pi remove "npm:bylua-lspec-subagents" 2>/dev/null
    pi remove "git:github.com/by-lua/lspec-subagents" 2>/dev/null
    echo -e "  ${GREEN}✓${NC} Extensão removida"
else
    echo -e "  ${YELLOW}⊘${NC} PI não encontrado (extensão já pode ter sido removida)"
fi

# ── Remover .md agents ──
echo -e "${BLUE}→ Removendo agent .md files...${NC}"
lspec_agents=(orchestrator explorer librarian oracle designer fixer observer council councillor)
removed=0
for agent in "${lspec_agents[@]}"; do
    if [[ -f "$PI_AGENTS_DIR/${agent}.md" ]]; then
        rm "$PI_AGENTS_DIR/${agent}.md"
        echo -e "  ${YELLOW}✗${NC} Removido: ${agent}.md"
        ((removed++))
    fi
done

if [[ $removed -eq 0 ]]; then
    echo -e "  ${BLUE}⊘${NC} Nenhum .md agent encontrado"
fi

# ── Preservar config ──
CONFIG="$PI_AGENT_DIR/lspec-model-config.json"
if [[ -f "$CONFIG" ]]; then
    echo -e "  ${BLUE}⊘${NC} lspec-model-config.json preservado (apague manualmente se quiser)"
fi

echo ""
echo -e "${GREEN}✓ lspec-subagents desinstalado!${NC} ($removed .md agents removidos | extensão removida)"
echo ""
