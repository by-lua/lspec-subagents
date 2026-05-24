# lspec-subagents

> **9 specialized sub-agents for PI.dev** — extensão standalone com modelo centralizado de configuração (inspirado no oh-my-opencode-slim). Fork do `@tintinweb/pi-subagents`.

9 agentes especializados para o fluxo L-Spec (Lua Spec-Driven Development). Os 3 agentes padrão do original (general-purpose, Explore, Plan) foram **completamente removidos** — só os 9 L-Spec existem no código.

## Agentes

- **orchestrator** — Coordenador central do fluxo L-Spec (`claude-sonnet-4`)
- **explorer** — Navegação rápida no codebase, read-only (`gpt-4o-mini`)
- **librarian** — Pesquisa de docs externas e APIs (`claude-sonnet-4`)
- **oracle** — Arquiteto sênior, code review, read-only (`claude-opus-4`)
- **designer** — UI/UX specialist (`claude-sonnet-4`)
- **fixer** — Implementador rápido de tarefas definidas (`claude-sonnet-4`)
- **observer** — Análise visual (imagens, PDFs, screenshots) (`gpt-4o-mini`, vision-capable)
- **council** — Consenso multi-modelo (spawna councillors) (`claude-opus-4`)
- **councillor** — Membro individual do conselho (`gpt-4o-mini`)

## Configuração Centralizada de Modelos

Modelos são **placeholders** (`{{model:orchestrator}}`) resolvidos em runtime via JSON.

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

Pode usar qualquer modelo disponível no seu provedor. O observer precisa de um modelo com **visão**.

### Ordem de resolução

1. Projeto (`.pi/lspec-model-config.json`) — **maior prioridade**
2. Global (`~/.pi/agent/lspec-model-config.json`)
3. Defaults embutidos (claude-sonnet-4, gpt-4o-mini, claude-opus-4)

## Instalação

```bash
curl -fsSL https://raw.githubusercontent.com/by-lua/lspec-subagents/main/install.sh | bash
```

O instalador faz 2 passos:
1. `pi install git:github.com/by-lua/lspec-subagents` — instala a extensão standalone
2. Copia os 9 agent `.md` files pra `~/.pi/agents/` + cria `lspec-model-config.json` (se não existir)

Requer: `git`, `pi` (PI.dev).

### Atualizar

```bash
curl -fsSL https://raw.githubusercontent.com/by-lua/lspec-subagents/main/update.sh | bash
```

### Desinstalar

```bash
curl -fsSL https://raw.githubusercontent.com/by-lua/lspec-subagents/main/uninstall.sh | bash
```

Remove extensão + 9 agent .md files. Preserva `lspec-model-config.json`.

### Instalação manual

```bash
pi install git:github.com/by-lua/lspec-subagents          # extensão standalone
git clone --depth 1 https://github.com/by-lua/lspec-subagents.git /tmp/lspec-sub
cp /tmp/lspec-sub/.pi/agents/*.md ~/.pi/agents/          # .md overrides
cp /tmp/lspec-sub/lspec-model-config.example.json ~/.pi/agent/lspec-model-config.json
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

- ✅ **9 agentes L-Spec** embutidos no código (não override por .md)
- ✅ **Zero agentes padrão** — general-purpose/Explore/Plan removidos do source
- ✅ **Placeholders de modelo** (`{{model:orchestrator}}`)
- ✅ **Config JSON centralizada** (projeto + global + defaults)
- ✅ **Fallback** mudou de `general-purpose` pra `orchestrator`
- ✅ **Extensão standalone** — não depende do pacote npm @tintinweb

## Licença

MIT — fork de `@tintinweb/pi-subagents` (MIT).