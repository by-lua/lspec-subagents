# @lspec/subagents

> **9 specialized sub-agents for PI.dev** — baseado no `@tintinweb/pi-subagents` com modelo centralizado de configuração (inspirado no oh-my-opencode-slim).

Substitui os 3 agentes padrão (general-purpose, Explore, Plan) por **9 agentes especializados** para o fluxo L-Spec (Lua Spec-Driven Development).

## Agentes

|| Agente | Função | Modelo Padrão (referência) |
|---|---|---|---|
|| `orchestrator` | Coordenador central do fluxo L-Spec | `claude-sonnet-4` (advanced) |
|| `explorer` | Navegação rápida no codebase (read-only) | `gpt-4o-mini` (basic) |
|| `librarian` | Pesquisa de docs externas e APIs | `claude-sonnet-4` (advanced) |
|| `oracle` | Arquiteto sênior, code review (read-only) | `claude-opus-4` (elite) |
|| `designer` | UI/UX specialist | `claude-sonnet-4` (advanced) |
|| `fixer` | Implementador rápido de tarefas definidas | `claude-sonnet-4` (advanced) |
|| `observer` | Análise visual (imagens, PDFs, screenshots) | `gpt-4o-mini` (basic, vision-capable) |
|| `council` | Consenso multi-modelo (spawna councillors) | `claude-opus-4` (elite) |
|| `councillor` | Membro individual do conselho | `gpt-4o-mini` (basic) |

## Configuração Centralizada de Modelos

Diferente do pi-subagents original (que tem modelos fixos no código), aqui os modelos são **placeholders** (`{{model:orchestrator}}`) resolvidos em runtime a partir de um arquivo JSON.

### Como configurar

Crie `lspec-model-config.json` em:

- **Global**: `~/.pi/agent/lspec-model-config.json`
- **Projeto**: `.pi/lspec-model-config.json` (sobrescreve o global)

```json
{
  "agents": {
    "orchestrator": "claude-sonnet-4",
    "explorer": "gpt-4o-mini",
    "librarian": "claude-sonnet-4",
    "oracle": "claude-opus-4",
    "designer": "claude-sonnet-4",
    "fixer": "claude-sonnet-4",
    "observer": "gpt-4o-mini",
    "council": "claude-opus-4",
    "councillor": "gpt-4o-mini"
  }
}
```

Pode usar qualquer modelo disponível no seu provedor, ex: `"anthropic/claude-sonnet-4"`, `"openai/gpt-4o"`, etc. O observer usa um modelo com **visão** (`gpt-4o-mini` no exemplo) pra analisar screenshots.

### Ordem de resolução

1. Projeto (`.pi/lspec-model-config.json`) — **maior prioridade**
2. Global (`~/.pi/agent/lspec-model-config.json`)
3. Defaults embutidos (claude-sonnet-4, gpt-4o-mini, claude-opus-4)

## Instalação rápida

```bash
curl -fsSL https://raw.githubusercontent.com/by-lua/lspec-subagents/main/install.sh | bash
```

O instalador faz **3 passos**:
1. `npm install @tintinweb/pi-subagents` — instala a extensão oficial (registra o `/agents` no PI)
2. Remove os 3 agentes padrão (general-purpose, Explore, Plan)
3. Copia os 9 agentes L-Spec (`.md`) pra `~/.pi/agents/` + cria `lspec-model-config.json` (se não existir)

Requer: `git`, `node`, `npm`.

### Atualizar

```bash
curl -fsSL https://raw.githubusercontent.com/by-lua/lspec-subagents/main/update.sh | bash
```

Reinstala a extensão npm (pega versão mais recente), remove padrão, reinstala agentes L-Spec. Preserva `lspec-model-config.json`.

### Desinstalar

```bash
curl -fsSL https://raw.githubusercontent.com/by-lua/lspec-subagents/main/uninstall.sh | bash
```

Remove os 9 agentes `.md` L-Spec. A extensão npm e a config são preservadas.

Para remover tudo:
```bash
npm uninstall @tintinweb/pi-subagents  # remove extensão
rm ~/.pi/agent/lspec-model-config.json  # remove config
```

### Instalação manual

```bash
cd ~/.pi/agent/npm && npm install @tintinweb/pi-subagents@0.7.3  # extensão
rm ~/.pi/agents/{general-purpose,Explore,Plan}.md 2>/dev/null     # padrão
git clone --depth 1 https://github.com/by-lua/lspec-subagents.git /tmp/lspec-sub
cp /tmp/lspec-sub/.pi/agents/*.md ~/.pi/agents/                   # nossos
cp /tmp/lspec-sub/lspec-model-config.example.json ~/.pi/agent/lspec-model-config.json  # config
rm -rf /tmp/lspec-sub
```

## Como usar

No PI, use o tool `Agent` com o tipo do agente:

```
Agent(agent_type="explorer", prompt="Find all React components in src/")
Agent(agent_type="orchestrator", prompt="Run L-Spec Discovery for the auth feature")
```

Ou customize agentes `.md` em `.pi/agents/` para sobrescrever os defaults.

## Diferenças do pi-subagents original

- ✅ **9 agentes** em vez de 3
- ✅ **Placeholders de modelo** (`{{model:orchestrator}}`)
- ✅ **Config JSON centralizada** (projeto + global + defaults)
- ✅ **Fallback padrão** mudou de `general-purpose` pra `orchestrator`
- ✅ **Referências** a agentes antigos (Explore/Plan/general-purpose) substituídas

## Licença

MIT — fork de `@tintinweb/pi-subagents` (MIT).
