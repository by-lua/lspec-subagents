#!/usr/bin/env bash
# lspec-subagents — Atualizador
# Uso: curl -fsSL https://raw.githubusercontent.com/by-lua/lspec-subagents/main/update.sh | bash

set -uo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

REPO="https://github.com/by-lua/lspec-subagents.git"
PI_AGENTS_DIR="$HOME/.pi/agents"
PI_AGENT_DIR="$HOME/.pi/agent"

echo ""
echo -e "${BLUE}╔════════════════════════════════╗${NC}"
echo -e "${BLUE}║  lspec-subagents — Atualizar   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════╝${NC}"
echo ""

# ── Reinstalar extensão ──
echo -e "${BLUE}→ Reinstalando extensão...${NC}"
if command -v pi &>/dev/null; then
    pi remove "git:github.com/by-lua/lspec-subagents" 2>/dev/null
    pi install "git:github.com/by-lua/lspec-subagents" 2>/dev/null
else
    echo -e "${RED}✗ PI não encontrado.${NC}"
    exit 1
fi
echo -e "  ${GREEN}✓${NC} Extensão atualizada"

# ── Reinstalar .md agents ──
echo -e "${BLUE}→ Atualizando agent .md files...${NC}"
lspec_agents=(orchestrator explorer librarian oracle designer fixer observer council councillor)
removed=0
for agent in "${lspec_agents[@]}"; do
    if [[ -f "$PI_AGENTS_DIR/${agent}.md" ]]; then
        rm "$PI_AGENTS_DIR/${agent}.md"
        ((removed++))
    fi
done
echo -e "  ${BLUE}⊘${NC} $removed .md antigos removidos"

REPO_DIR="$(mktemp -d)"
git clone --depth 1 "$REPO" "$REPO_DIR" 2>/dev/null || {
    echo -e "${RED}✗ Erro ao clonar.${NC}"; rm -rf "$REPO_DIR"; exit 1; }

agent_count=0
for agent_file in "$REPO_DIR"/.pi/agents/*.md; do
    [[ -f "$agent_file" ]] || continue
    agent_name=$(basename "$agent_file")
    cp "$agent_file" "$PI_AGENTS_DIR/$agent_name"
    echo -e "  ${GREEN}✓${NC} agents/$agent_name"
    ((agent_count++))
done

rm -rf "$REPO_DIR"

echo ""
echo -e "${GREEN}✓ lspec-subagents atualizado!${NC} ($agent_count .md agents | extensão standalone)"
echo ""
