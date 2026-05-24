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
/** Embedded defaults — used when no config file exists. Using generic models as reference. */
const EMBEDDED_DEFAULTS = {
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
export function isModelPlaceholder(model) {
    return model.startsWith(MODEL_PLACEHOLDER_PREFIX) && model.endsWith(MODEL_PLACEHOLDER_SUFFIX);
}
/**
 * Extract agent name from a placeholder like "{{model:explorer}}" → "explorer"
 */
export function parseModelPlaceholder(model) {
    if (!isModelPlaceholder(model))
        return null;
    return model.slice(MODEL_PLACEHOLDER_PREFIX.length, -MODEL_PLACEHOLDER_SUFFIX.length);
}
/**
 * Resolve a model placeholder to the actual model string from config.
 * Returns the resolved model, or undefined if the placeholder can't be resolved.
 */
export function resolveModelPlaceholder(model, config) {
    if (!model)
        return undefined;
    if (!isModelPlaceholder(model))
        return model;
    const agentName = parseModelPlaceholder(model);
    if (!agentName)
        return undefined;
    return config.agents[agentName];
}
/**
 * Resolve all model placeholders in a map of agent configs.
 * Modifies the map in place.
 */
export function resolveAllPlaceholders(agents, config) {
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
export function loadModelConfig(cwd) {
    const config = structuredClone(EMBEDDED_DEFAULTS);
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
function loadAndMerge(path, config) {
    if (!existsSync(path))
        return;
    try {
        const raw = readFileSync(path, "utf-8");
        const parsed = JSON.parse(raw);
        // Skip _note, _docs keys — they're metadata
        if (parsed.agents && typeof parsed.agents === "object") {
            for (const [key, value] of Object.entries(parsed.agents)) {
                if (typeof value === "string") {
                    config.agents[key] = value;
                }
            }
        }
    }
    catch {
        // Silently ignore malformed config files
    }
}
/** Re-export for convenience — returns a fully resolved model for an agent. */
export function getModelForAgent(agentName, cwd) {
    const config = loadModelConfig(cwd);
    return config.agents[agentName];
}
