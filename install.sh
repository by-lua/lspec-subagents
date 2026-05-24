#!/usr/bin/env bash
# @lspec/subagents — Instalador
# Uso: curl -fsSL https://raw.githubusercontent.com/by-lua/lspec-subagents/main/install.sh | bash
# Requer: git, Node.js 18+, npm

set -uo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

REPO="https://github.com/by-lua/lspec-subagents.git"

PI_AGENTS_DIR="$HOME/.pi/agents"
PI_AGENT_DIR="$HOME/.pi/agent"

echo ""
echo -e "${BLUE}╔═════════════════════════════════╗${NC}"
echo -e "${BLUE}║   @lspec/subagents — Instalador ║${NC}"
echo -e "${BLUE}╚═════════════════════════════════╝${NC}"
echo ""

# Clonar
REPO_DIR="$(mktemp -d)"
echo -e "${BLUE}→ Baixando repositório...${NC}"
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

# Copiar exemplo de config de modelos (não sobrescreve se já existe)
config_copied=0
if [[ -f "$REPO_DIR/lspec-model-config.example.json" ]]; then
    if [[ ! -f "$PI_AGENT_DIR/lspec-model-config.json" ]]; then
        mkdir -p "$PI_AGENT_DIR"
        cp "$REPO_DIR/lspec-model-config.example.json" "$PI_AGENT_DIR/lspec-model-config.json"
        echo -e "  ${GREEN}✓${NC} lspec-model-config.json (criado com defaults)"
        config_copied=1
    else
        echo -e "  ${BLUE}⊘${NC} lspec-model-config.json (já existe, mantido)"
    fi
fi

# Instalar dependências npm se o pi CLI estiver disponível
npm_installed=0
if command -v pi &>/dev/null; then
    echo -e "${BLUE}→ Instalando dependências npm...${NC}"
    cd "$REPO_DIR" && npm install --production 2>/dev/null && npm_installed=1 || {
        echo -e "  ${BLUE}⊘${NC} npm install falhou — dependências serão instaladas pelo PI.dev"
    }
fi

echo ""
echo -e "${GREEN}✓ @lspec/subagents instalado!${NC} ($agent_count agentes)"
echo ""
echo "Agentes: orchestrator | explorer | librarian | oracle | designer | fixer | observer | council | councillor"
echo "Config:   ~/.pi/agent/lspec-model-config.json"
echo "Atualizar: curl -fsSL https://raw.githubusercontent.com/by-lua/lspec-subagents/main/update.sh | bash"
echo ""

rm -rf "$REPO_DIR"