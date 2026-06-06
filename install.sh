#!/usr/bin/env bash
# lspec-subagents — Instalador
# Uso: curl -fsSL https://raw.githubusercontent.com/by-lua/lspec-subagents/main/install.sh | bash
# Alternativa npm: curl -fsSL https://raw.githubusercontent.com/by-lua/lspec-subagents/main/install.sh | bash -s npm
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
echo -e "${BLUE}╔════════════════════════════════╗${NC}"
echo -e "${BLUE}║  lspec-subagents — Instalador  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════╝${NC}"
echo ""

if ! command -v pi &>/dev/null; then
    echo -e "${RED}✗ PI não encontrado. Instale em https://pi.dev${NC}"
    exit 1
fi

# ── Passo 0: Remover extensões conflitantes ──
echo -e "${BLUE}→ Removendo extensões conflitantes...${NC}"
pi remove "npm:@tintinweb/pi-subagents" 2>/dev/null && echo -e "  ${YELLOW}⊘${NC} Removido npm:@tintinweb/pi-subagents (conflito)"
pi remove "git:github.com/by-lua/lspec-subagents" 2>/dev/null
pi remove "npm:@by-lua/lspec-subagents" 2>/dev/null

# ── Passo 1: Instalar extensão via npm ──
echo -e "${BLUE}→ Instalando @by-lua/lspec-subagents via npm...${NC}"
pi install "npm:@by-lua/lspec-subagents" 2>/dev/null
echo -e "  ${GREEN}✓${NC} Extensão instalada (9 agentes L-Spec + /agents)"

# ── Passo 2: Clonar e copiar .md de agentes ──
echo -e "${BLUE}→ Copiando agent .md files...${NC}"
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
echo -e "${GREEN}✓ lspec-subagents instalado!${NC} ($agent_count .md agents | extensão @by-lua/lspec-subagents)"
echo ""
echo "Agentes: orchestrator | explorer | librarian | oracle | designer | fixer | observer | council | councillor"
echo "Extensão: pi install npm:@by-lua/lspec-subagents"
echo "Config:   ~/.pi/agent/lspec-model-config.json"
echo "Atualizar: curl -fsSL https://raw.githubusercontent.com/by-lua/lspec-subagents/main/update.sh | bash"
echo "Desinstalar: curl -fsSL https://raw.githubusercontent.com/by-lua/lspec-subagents/main/uninstall.sh | bash"
echo ""
rm -rf "$REPO_DIR"
