# @lspec/subagents

> **9 specialized sub-agents for PI.dev** — baseado no `@tintinweb/pi-subagents` com modelo centralizado de configuração (inspirado no oh-my-opencode-slim).

Substitui os 3 agentes padrão (general-purpose, Explore, Plan) por **9 agentes especializados** para o fluxo L-Spec (Lua Spec-Driven Development).

## Agentes

| Agente | Função | Modelo Padrão |
|---|---|---|
| `orchestrator` | Coordenador central do fluxo L-Spec | CODING-ADVANCED |
| `explorer` | Navegação rápida no codebase (read-only) | CODING-BASIC |
| `librarian` | Pesquisa de docs externas e APIs | CODING-ADVANCED |
| `oracle` | Arquiteto sênior, code review (read-only) | CODING-ELITE |
| `designer` | UI/UX specialist | CODING-ADVANCED |
| `fixer` | Implementador rápido de tarefas definidas | CODING-ADVANCED |
| `observer` | Análise visual (imagens, PDFs, screenshots) | CODING-BASIC |
| `council` | Consenso multi-modelo (spawna councillors) | CODING-ELITE |
| `councillor` | Membro individual do conselho | CODING-BASIC |

## Configuração Centralizada de Modelos

Diferente do pi-subagents original (que tem modelos fixos no código), aqui os modelos são **placeholders** (`{{model:orchestrator}}`) resolvidos em runtime a partir de um arquivo JSON.

### Como configurar

Crie `lspec-model-config.json` em:

- **Global**: `~/.pi/agent/lspec-model-config.json`
- **Projeto**: `.pi/lspec-model-config.json` (sobrescreve o global)

```json
{
  "agents": {
    "orchestrator": "CODING-ADVANCED",
    "explorer": "CODING-BASIC",
    "librarian": "CODING-ADVANCED",
    "oracle": "CODING-ELITE",
    "designer": "CODING-ADVANCED",
    "fixer": "CODING-ADVANCED",
    "observer": "CODING-BASIC",
    "council": "CODING-ELITE",
    "councillor": "CODING-BASIC"
  }
}
```

Pode usar qualquer modelo disponível no seu PI, ex: `"anthropic/claude-sonnet-4"`, `"openai/gpt-4o"`, `"CODING-ADVANCED"`, etc.

### Ordem de resolução

1. Projeto (`.pi/lspec-model-config.json`) — **maior prioridade**
2. Global (`~/.pi/agent/lspec-model-config.json`)
3. Defaults embutidos (CODING-*)

## Instalação

```bash
# Via npm (quando publicado)
pi install npm:@lspec/subagents

# Local (tar.gz)
pi install /caminho/para/lspec-subagents.tar.gz
```

## Como usar

No PI, use o tool `Agent` com o tipo do agente:

```
Agent(agent_type="explorer", prompt="Find all React components in src/")
Agent(agent_type="orchestrator", prompt="Run L-Spec Discovery for the auth feature")
```

Ou customize agentes `.md` em `.pi/agents/` para sobrescrever os defaults.

## Diferenças do pi-subagents original

- ❌ **Provider Ominiroute removido** — vc configura manualmente
- ✅ **9 agentes** em vez de 3
- ✅ **Placeholders de modelo** (`{{model:orchestrator}}`)
- ✅ **Config JSON centralizada** (projeto + global + defaults)
- ✅ **Fallback padrão** mudou de `general-purpose` pra `orchestrator`
- ✅ **Referências** a agentes antigos (Explore/Plan/general-purpose) substituídas

## Licença

MIT — fork de `@tintinweb/pi-subagents` (MIT).
