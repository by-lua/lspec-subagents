#!/usr/bin/env bash
# @lspec/subagents — Atualizador
# Uso: curl -fsSL https://raw.githubusercontent.com/by-lua/lspec-subagents/main/update.sh | bash
# Requer: git, pi (PI.dev)

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
echo -e "${BLUE}╔══════════════════════════════════╗${NC}"
echo -e "${BLUE}║   @lspec/subagents — Atualizador ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════╝${NC}"
echo ""

# ── Reinstalar extensão ──
echo -e "${BLUE}→ Reinstalando extensão @tintinweb/pi-subagents...${NC}"
if command -v pi &>/dev/null; then
    pi install npm:@tintinweb/pi-subagents 2>/dev/null
elif [[ -d "$HOME/.pi/agent/npm" ]]; then
    cd "$HOME/.pi/agent/npm" && npm install @tintinweb/pi-subagents@0.7.3 2>/dev/null
fi

if [[ ! -d "$HOME/.pi/agent/npm/node_modules/@tintinweb/pi-subagents" ]]; then
    echo -e "${RED}✗ Extensão não reinstalou.${NC}"; exit 1
fi
echo -e "  ${GREEN}✓${NC} Extensão atualizada"

# ── Remover agentes padrão (podem voltar no pi install) ──
default_agents=("general-purpose" "Explore" "Plan")
for agent in "${default_agents[@]}"; do
    if [[ -f "$PI_AGENTS_DIR/${agent}.md" ]]; then
        rm "$PI_AGENTS_DIR/${agent}.md"
        echo -e "  ${YELLOW}✗${NC} Removido: ${agent}.md"
    fi
done

# ── Baixar e reinstalar nossos agentes ──
echo -e "${BLUE}→ Baixando agentes L-Spec...${NC}"
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

# Preservar config existente
if [[ -f "$REPO_DIR/lspec-model-config.example.json" ]]; then
    if [[ ! -f "$PI_AGENT_DIR/lspec-model-config.json" ]]; then
        cp "$REPO_DIR/lspec-model-config.example.json" "$PI_AGENT_DIR/lspec-model-config.json"
        echo -e "  ${GREEN}✓${NC} lspec-model-config.json (criado com defaults)"
    else
        echo -e "  ${BLUE}⊘${NC} lspec-model-config.json (já existe, mantido)"
    fi
fi

echo ""
echo -e "${GREEN}✓ @lspec/subagents atualizado!${NC} ($agent_count agentes)"
echo ""

rm -rf "$REPO_DIR"