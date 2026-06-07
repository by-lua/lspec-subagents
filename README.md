# lspec-subagents

**9 specialized sub-agents for PI.dev** — standalone extension with centralized configuration model.

Inspired by oh-my-opencode-slim. Fork of `@tintinweb/pi-subagents` — default agents (general-purpose, Explore, Plan) **completely removed**, only the 9 L-Spec agents exist.

## Install, Update, Uninstall

```bash
# Install
pi install npm:@by-lua/lspec-subagents

# Update
pi update npm:@by-lua/lspec-subagents

# Uninstall
pi uninstall npm:@by-lua/lspec-subagents
```

> Alternative (Git): `curl -fsSL https://raw.githubusercontent.com/by-lua/lspec-subagents/main/install.sh | bash`

## Agents

- **orchestrator** — Central L-Spec workflow coordinator (`claude-sonnet-4`)
- **explorer** — Fast codebase navigation, read-only (`gpt-4o-mini`)
- **librarian** — External docs and APIs research (`claude-sonnet-4`)
- **oracle** — Senior architect, code review, read-only (`claude-opus-4`)
- **designer** — UI/UX specialist (`claude-sonnet-4`)
- **fixer** — Fast task implementation (`claude-sonnet-4`)
- **observer** — Visual analysis (images, PDFs, screenshots) (`gpt-4o-mini`, vision-capable)
- **council** — Multi-model consensus (spawns councillors) (`claude-opus-4`)
- **councillor** — Individual council member (`gpt-4o-mini`)

## Centralized Model Configuration

Models are **placeholders** (`{{model:orchestrator}}`) resolved at runtime via JSON.

### How to configure

Create `lspec-model-config.json` in:
- **Global**: `~/.pi/agent/lspec-model-config.json`
- **Project**: `.pi/lspec-model-config.json` (overrides global)

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

You can use any model available from your provider. The observer requires a model with **vision**.

### Resolution order

1. Project (`.pi/lspec-model-config.json`) — **highest priority**
2. Global (`~/.pi/agent/lspec-model-config.json`)
3. Built-in defaults (claude-sonnet-4, gpt-4o-mini, claude-opus-4)

## How to use

In PI, use the `Agent` tool with the agent type:

```
Agent(agent_type="explorer", prompt="Find all React components in src/")
Agent(agent_type="orchestrator", prompt="Run L-Spec Discovery for the auth feature")
```

Or customize agent `.md` files in `.pi/agents/` to override defaults.

## Differences from original pi-subagents

- ✅ **9 L-Spec agents** built into code (not override by .md)
- ✅ **Zero default agents** — general-purpose/Explore/Plan removed from source
- ✅ **Model placeholders** (`{{model:orchestrator}}`)
- ✅ **Centralized JSON config** (project + global + defaults)
- ✅ **Fallback** changed from `general-purpose` to `orchestrator`
- ✅ **Standalone extension** — does not depend on npm package @tintinweb

## Manual installation (without npm)

```bash
pi install git:github.com/by-lua/lspec-subagents          # standalone extension
git clone --depth 1 https://github.com/by-lua/lspec-subagents.git /tmp/lspec-sub
cp /tmp/lspec-sub/.pi/agents/*.md ~/.pi/agents/          # .md overrides
cp /tmp/lspec-sub/lspec-model-config.example.json ~/.pi/agent/lspec-model-config.json
rm -rf /tmp/lspec-sub
```

## Update / Uninstall

```bash
# Update
curl -fsSL https://raw.githubusercontent.com/by-lua/lspec-subagents/main/update.sh | bash

# Uninstall
curl -fsSL https://raw.githubusercontent.com/by-lua/lspec-subagents/main/uninstall.sh | bash
```

Removes extension + 9 agent .md files. Preserves `lspec-model-config.json`.

## License

MIT — fork of `@tintinweb/pi-subagents` (MIT).
