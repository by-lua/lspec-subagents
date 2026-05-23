/**
 * model-config-loader.ts — Load centralized model configuration for L-Spec subagents.
 *
 * Inspired by oh-my-opencode-slim's model config approach.
 *
 * Resolution order (highest priority wins):
 *   1. Project:  <cwd>/.pi/lspec-model-config.json
 *   2. Global:   ~/.pi/agent/lspec-model-config.json
 *   3. Embedded: hardcoded defaults in this file
 */

import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { getAgentDir } from "@mariozechner/pi-coding-agent";

export interface ModelConfig {
  /** Map of agent name → model string (e.g. "CODING-ADVANCED" or "provider/modelId") */
  agents: Record<string, string>;
}

/** Embedded defaults — used when no config file exists. */
const EMBEDDED_DEFAULTS: ModelConfig = {
  agents: {
    orchestrator: "CODING-ADVANCED",
    explorer: "CODING-BASIC",
    librarian: "CODING-ADVANCED",
    oracle: "CODING-ELITE",
    designer: "CODING-ADVANCED",
    fixer: "CODING-ADVANCED",
    observer: "CODING-BASIC",
    council: "CODING-ELITE",
    councillor: "CODING-BASIC",
  },
};

/** The placeholder marker prefix/suffix used in default-agents.ts */
export const MODEL_PLACEHOLDER_PREFIX = "{{model:";
export const MODEL_PLACEHOLDER_SUFFIX = "}}";

/**
 * Check if a model string is a placeholder like "{{model:explorer}}"
 */
export function isModelPlaceholder(model: string): boolean {
  return model.startsWith(MODEL_PLACEHOLDER_PREFIX) && model.endsWith(MODEL_PLACEHOLDER_SUFFIX);
}

/**
 * Extract agent name from a placeholder like "{{model:explorer}}" → "explorer"
 */
export function parseModelPlaceholder(model: string): string | null {
  if (!isModelPlaceholder(model)) return null;
  return model.slice(MODEL_PLACEHOLDER_PREFIX.length, -MODEL_PLACEHOLDER_SUFFIX.length);
}

/**
 * Load model config from disk, merging global + project overrides.
 * Returns the merged config.
 */
export function loadModelConfig(cwd: string): ModelConfig {
  const config = structuredClone(EMBEDDED_DEFAULTS) as ModelConfig;
  const globalDir = join(getAgentDir());
  const projectDir = join(cwd, ".pi");

  // Load global config (lower priority)
  const globalPath = join(globalDir, "lspec-model-config.json");
  loadAndMerge(globalPath, config);

  // Load project config (higher priority — overwrites)
  const projectPath = join(projectDir, "lspec-model-config.json");
  loadAndMerge(project MyApologies for the interruption — it looks like I got cut off mid-function. Let me complete the model-config-loader correctly and also re-check the agent-types flow before making changes.

Let me step back and write all files carefully:

<｜DSML｜tool_calls>
<｜DSML｜invoke name="write_file">
<｜DSML｜parameter name="content" string="true">/**
 * model-config-loader.ts — Load centralized model configuration for L-Spec subagents.
 *
 * Inspired by oh-my-opencode-slim's model config approach.
 *
 * Resolution order (highest priority wins):
 *   1. Project:  <cwd>/.pi/lspec-model-config.json
 *   2. Global:   ~/.pi/agent/lspec-model-config.json
 *   3. Embedded: hardcoded defaults in this file
 */

import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { getAgentDir } from "@mariozechner/pi-coding-agent";

export interface ModelConfig {
  /** Map of agent name → model string (e.g. "CODING-ADVANCED" or "provider/modelId") */
  agents: Record<string, string>;
}

/** Embedded defaults — used when no config file exists. */
const EMBEDDED_DEFAULTS: ModelConfig = {
  agents: {
    orchestrator: "CODING-ADVANCED",
    explorer: "CODING-BASIC",
    librarian: "CODING-ADVANCED",
    oracle: "CODING-ELITE",
    designer: "CODING-ADVANCED",
    fixer: "CODING-ADVANCED",
    observer: "CODING-BASIC",
    council: "CODING-ELITE",
    councillor: "CODING-BASIC",
  },
};

export const MODEL_PLACEHOLDER_PREFIX = "{{model:";
export const MODEL_PLACEHOLDER_SUFFIX = "}}";

/**
 * Check if a model string is a placeholder like "{{model:explorer}}"
 */
export function isModelPlaceholder(model: string): boolean {
  return model.startsWith(MODEL_PLACEHOLDER_PREFIX) && model.endsWith(MODEL_PLACEHOLDER_SUFFIX);
}

/**
 * Extract agent name from a placeholder like "{{model:explorer}}" → "explorer"
 */
export function parseModelPlaceholder(model: string): string | null {
  if (!isModelPlaceholder(model)) return null;
  return model.slice(MODEL_PLACEHOLDER_PREFIX.length, -MODEL_PLACEHOLDER_SUFFIX.length);
}

/**
 * Resolve a model placeholder to the actual model string from config.
 * Returns the resolved model, or undefined if the placeholder can't be resolved.
 */
export function resolveModelPlaceholder(
  model: string | undefined,
  config: ModelConfig
): string | undefined {
  if (!model) return undefined;
  if (!isModelPlaceholder(model)) return model;

  const agentName = parseModelPlaceholder(model);
  if (!agentName) return undefined;

  return config.agents[agentName];
}

/**
 * Resolve all model placeholders in a map of agent configs.
 * Modifies the map in place.
 */
export function resolveAllPlaceholders(
  agents: Map<string, { model?: string }>,
  config: ModelConfig
): void {
  for (const [, agent] of agents) {
    if (agent.model && isModelPlaceholder(agent.model)) {
      const resolved = resolveModelPlaceholder(agent.model, config);
      if (resolved) {
        agent.model = resolved;
      }
    }
  }
}

/**
 * Load model config from disk, merging global + project overrides.
 * Returns the merged config.
 */
export function loadModelConfig(cwd: string): ModelConfig {
  const config = structuredClone(EMBEDDED_DEFAULTS) as ModelConfig;
  const globalDir = join(getAgentDir());
  const projectDir = join(cwd, ".pi");

  // Load global config (lower priority)
  const globalPath = join(globalDir, "lspec-model-config.json");
  loadAndMerge(globalPath, config);

  // Load project config (higher priority — overwrites)
  const projectPath = join(projectDir, "lspec-model-config.json");
  loadAndMerge(projectPath, config);

  return config;
}

/**
 * Load a JSON config file and merge its agents into the config object.
 */
function loadAndMerge(path: string, config: ModelConfig): void {
  if (!existsSync(path)) return;

  try {
    const raw = readFileSync(path, "utf-8");
    const parsed = JSON.parse(raw) as Partial<ModelConfig>;

    // Skip _note, _docs keys — they're metadata
    if (parsed.agents && typeof parsed.agents === "object") {
      for (const [key, value] of Object.entries(parsed.agents)) {
        if (typeof value === "string") {
          config.agents[key] = value;
        }
      }
    }
  } catch {
    // Silently ignore malformed config files
  }
}
