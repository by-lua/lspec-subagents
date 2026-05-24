#!/usr/bin/env bash
# @lspec/subagents — Instalador
# Uso: curl -fsSL https://raw.githubusercontent.com/by-lua/lspec-subagents/main/install.sh | bash
# Requer: git, node, npm

set -uo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

REPO="https://github.com/by-lua/lspec-subagents.git"

PI_AGENTS_DIR="$HOME/.pi/agents"
PI_AGENT_DIR="$HOME/.pi/agent"
PI_NPM_DIR="$PI_AGENT_DIR/npm"

echo ""
echo -e "${BLUE}╔═════════════════════════════════╗${NC}"
echo -e "${BLUE}║   @lspec/subagents — Instalador ║${NC}"
echo -e "${BLUE}╚═════════════════════════════════╝${NC}"
echo ""

# ── Passo 1: Instalar extensão oficial via npm ──
echo -e "${BLUE}→ Instalando extensão @tintinweb/pi-subagents via npm...${NC}"
mkdir -p "$PI_NPM_DIR"
cd "$PI_NPM_DIR"

if ! npm install @tintinweb/pi-subagents@0.7.3 2>/dev/null; then
    echo -e "${RED}✗ Erro ao instalar via npm. Node/npm instalados?${NC}"
    exit 1
fi
echo -e "  ${GREEN}✓${NC} Extensão instalada (node_modules/@tintinweb/pi-subagents)"

# ── Passo 2: Remover agentes padrão ──
echo -e "${BLUE}→ Removendo agentes padrão...${NC}"
default_agents=("general-purpose" "Explore" "Plan")
removed=0
for agent in "${default_agents[@]}"; do
    if [[ -f "$PI_AGENTS_DIR/${agent}.md" ]]; then
        rm "$PI_AGENTS_DIR/${agent}.md"
        echo -e "  ${YELLOW}✗${NC} Removido: ${agent}.md"
        ((removed++))
    fi
done
if [[ $removed -eq 0 ]]; then
    echo -e "  ${BLUE}⊘${NC} Nenhum agente padrão encontrado"
fi

# ── Passo 3: Clonar e copiar nossos agentes ──
echo -e "${BLUE}→ Baixando agentes L-Spec...${NC}"
REPO_DIR="$(mktemp -d)"
git clone --depth 1 "$REPO" "$REPO_DIR" 2>/dev/null || {
    echo -e "${RED}✗ Erro ao clonar. Git instalado?${NC}"; rm -rf "$REPO_DIR"; exit 1; }

mkdir -p "$PI_AGENTS_DIR" "$PI_AGENT_DIR"

agent_count=0
for agent_file in "$REPO_DIR"/.pi/agents/*.md; do
    [[ -f "$agent_file" ]] || continue
    agent_name=$(basename "$agent_file")
    cp "$agent_file" "$PI_AGENTS_DIR/$agent_name"
    echo -e "  ${GREEN}✓${NC} agents/$agent_name"
    ((agent_count++))
done

# Copiar config de modelos (não sobrescreve se já existe)
if [[ -f "$REPO_DIR/lspec-model-config.example.json" ]]; then
    if [[ ! -f "$PI_AGENT_DIR/lspec-model-config.json" ]]; then
        cp "$REPO_DIR/lspec-model-config.example.json" "$PI_AGENT_DIR/lspec-model-config.json"
        echo -e "  ${GREEN}✓${NC} lspec-model-config.json (criado com defaults)"
    else
        echo -e "  ${BLUE}⊘${NC} lspec-model-config.json (já existe, mantido)"
    fi
fi

echo ""
echo -e "${GREEN}✓ @lspec/subagents instalado!${NC} ($agent_count agentes | extensão via npm)"
echo ""
echo "Agentes: orchestrator | explorer | librarian | oracle | designer | fixer | observer | council | councillor"
echo "Extensão: node_modules/@tintinweb/pi-subagents"
echo "Config:   ~/.pi/agent/lspec-model-config.json"
echo "Atualizar: curl -fsSL https://raw.githubusercontent.com/by-lua/lspec-subagents/main/update.sh | bash"
echo ""

rm -rf "$REPO_DIR"