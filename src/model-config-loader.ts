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

import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { getAgentDir } from "@mariozechner/pi-coding-agent";

export interface ModelConfig {
  /** Map of agent name → model string (e.g. "claude-sonnet-4" or "provider/modelId") */
  agents: Record<string, string>;
}

/** Embedded defaults — used when no config file exists. Using generic models as reference. */
const EMBEDDED_DEFAULTS: ModelConfig = {
  agents: {
    orchestrator: "claude-sonnet-4",
    explorer: "gpt-4o-mini",
    librarian: "claude-sonnet-4",
    oracle: "claude-opus-4",
    designer: "claude-sonnet-4",
    fixer: "claude-sonnet-4",
    observer: "gpt-4o-mini",
    council: "claude-opus-4",
    councillor: "gpt-4o-mini",
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

/** Re-export for convenience — returns a fully resolved model for an agent. */
export function getModelForAgent(
  agentName: string,
  cwd: string
): string | undefined {
  const config = loadModelConfig(cwd);
  return config.agents[agentName];
}

/**
 * Get the global model config file path.
 */
export function getGlobalModelConfigPath(): string {
  return join(getAgentDir(), "lspec-model-config.json");
}

/**
 * Get the project model config file path.
 */
export function getProjectModelConfigPath(cwd: string): string {
  return join(cwd, ".pi", "lspec-model-config.json");
}

/**
 * Save a model assignment for an agent to the config file.
 * Updates global config by default, or project config if specified.
 * Preserves existing entries and metadata keys (_note, _docs, etc).
 */
export function saveModelForAgent(
  agentName: string,
  model: string,
  target: "global" | "project" = "global",
  cwd?: string,
): void {
  const configPath = target === "project"
    ? getProjectModelConfigPath(cwd ?? process.cwd())
    : getGlobalModelConfigPath();

  // Read existing config or create new
  let existing: Record<string, unknown> = {};
  if (existsSync(configPath)) {
    try {
      const raw = readFileSync(configPath, "utf-8");
      existing = JSON.parse(raw);
    } catch {
      existing = {};
    }
  }

  // Update the agents section
  if (!existing.agents || typeof existing.agents !== "object") {
    existing.agents = {};
  }
  (existing.agents as Record<string, string>)[agentName] = model;

  // Ensure directory exists
  mkdirSync(join(configPath, ".."), { recursive: true });

  // Write back
  writeFileSync(configPath, JSON.stringify(existing, null, 2) + "\n", "utf-8");
}
