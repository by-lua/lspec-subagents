/**
 * default-agents.ts — L-Spec 9 embedded agent configurations.
 *
 * Uses model placeholders ({{model:agent_name}}) resolved at startup
 * from lspec-model-config.json (project or global) or embedded defaults.
 *
 * Based on oh-my-opencode-slim agent roster:
 *   orchestrator, explorer, librarian, oracle, designer,
 *   fixer, observer, council, councillor
 */
import type { AgentConfig } from "./types.js";
export declare const DEFAULT_AGENTS: Map<string, AgentConfig>;
