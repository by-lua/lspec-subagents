/**
 * agent-types.ts — Unified agent type registry.
 *
 * Merges embedded default agents with user-defined agents from .pi/agents/*.md.
 * User agents override defaults with the same name. Disabled agents are kept but excluded from spawning.
 *
 * L-Spec addition: model placeholders ({{model:agent_name}}) are resolved at registration
 * from lspec-model-config.json via model-config-loader.ts.
 */
import { DEFAULT_AGENTS } from "./default-agents.js";
import { loadModelConfig, resolveAllPlaceholders } from "./model-config-loader.js";
/** All known built-in tool names. */
export const BUILTIN_TOOL_NAMES = ["read", "bash", "edit", "write", "grep", "find", "ls"];
/** Unified runtime registry of all agents (defaults + user-defined). */
const agents = new Map();
/** Cached model config, loaded once per session. */
let modelConfig = loadModelConfig(process.cwd());
/**
 * Register agents into the unified registry.
 * Starts with DEFAULT_AGENTS, then overlays user agents (overrides defaults with same name).
 * Model placeholders ({{model:name}}) are resolved from lspec-model-config.json.
 * Disabled agents (enabled === false) are kept in the registry but excluded from spawning.
 */
export function registerAgents(userAgents) {
    agents.clear();
    // Start with defaults
    for (const [name, config] of DEFAULT_AGENTS) {
        agents.set(name, config);
    }
    // Overlay user agents (overrides defaults with same name)
    for (const [name, config] of userAgents) {
        agents.set(name, config);
    }
    // Resolve model placeholders against the model config
    // This replaces {{model:orchestrator}} etc. with actual model strings
    reloadModelConfig();
    resolveAllPlaceholders(agents, modelConfig);
}
/**
 * Reload the model config from disk (in case it changed since session start).
 */
export function reloadModelConfig(cwd) {
    modelConfig = loadModelConfig(cwd ?? process.cwd());
}
/** Get the current model config (for UI display / debugging). */
export function getModelConfig() {
    return modelConfig;
}
/** Case-insensitive key resolution. */
function resolveKey(name) {
    if (agents.has(name))
        return name;
    const lower = name.toLowerCase();
    for (const key of agents.keys()) {
        if (key.toLowerCase() === lower)
            return key;
    }
    return undefined;
}
/** Resolve a type name case-insensitively. Returns the canonical key or undefined. */
export function resolveType(name) {
    return resolveKey(name);
}
/** Get the agent config for a type (case-insensitive). */
export function getAgentConfig(name) {
    const key = resolveKey(name);
    return key ? agents.get(key) : undefined;
}
/** Get all enabled type names (for spawning and tool descriptions). */
export function getAvailableTypes() {
    return [...agents.entries()]
        .filter(([_, config]) => config.enabled !== false)
        .map(([name]) => name);
}
/** Get all type names including disabled (for UI listing). */
export function getAllTypes() {
    return [...agents.keys()];
}
/** Get names of default agents currently in the registry. */
export function getDefaultAgentNames() {
    return [...agents.entries()]
        .filter(([_, config]) => config.isDefault === true)
        .map(([name]) => name);
}
/** Get names of user-defined agents (non-defaults) currently in the registry. */
export function getUserAgentNames() {
    return [...agents.entries()]
        .filter(([_, config]) => config.isDefault !== true)
        .map(([name]) => name);
}
/** Check if a type is valid and enabled (case-insensitive). */
export function isValidType(type) {
    const key = resolveKey(type);
    if (!key)
        return false;
    return agents.get(key)?.enabled !== false;
}
/** Tool names required for memory management. */
const MEMORY_TOOL_NAMES = ["read", "write", "edit"];
/**
 * Get memory tool names (read/write/edit) not already in the provided set.
 */
export function getMemoryToolNames(existingToolNames) {
    return MEMORY_TOOL_NAMES.filter(n => !existingToolNames.has(n));
}
/** Tool names needed for read-only memory access. */
const READONLY_MEMORY_TOOL_NAMES = ["read"];
/**
 * Get read-only memory tool names not already in the provided set.
 */
export function getReadOnlyMemoryToolNames(existingToolNames) {
    return READONLY_MEMORY_TOOL_NAMES.filter(n => !existingToolNames.has(n));
}
/** Get built-in tool names for a type (case-insensitive). */
export function getToolNamesForType(type) {
    const key = resolveKey(type);
    const raw = key ? agents.get(key) : undefined;
    const config = raw?.enabled !== false ? raw : undefined;
    const names = config?.builtinToolNames?.length ? config.builtinToolNames : [...BUILTIN_TOOL_NAMES];
    return names;
}
/** Get config for a type (case-insensitive, returns a SubagentTypeConfig-compatible object). Falls back to orchestrator. */
export function getConfig(type) {
    const key = resolveKey(type);
    const config = key ? agents.get(key) : undefined;
    if (config && config.enabled !== false) {
        return {
            displayName: config.displayName ?? config.name,
            description: config.description,
            builtinToolNames: config.builtinToolNames ?? BUILTIN_TOOL_NAMES,
            extensions: config.extensions,
            skills: config.skills,
            promptMode: config.promptMode,
        };
    }
    // Fallback for unknown/disabled types — orchestrator config
    const fallback = agents.get("orchestrator");
    if (fallback && fallback.enabled !== false) {
        return {
            displayName: fallback.displayName ?? fallback.name,
            description: fallback.description,
            builtinToolNames: fallback.builtinToolNames ?? BUILTIN_TOOL_NAMES,
            extensions: fallback.extensions,
            skills: fallback.skills,
            promptMode: fallback.promptMode,
        };
    }
    // Absolute fallback (should never happen)
    return {
        displayName: "Orchestrator",
        description: "L-Spec central coordinator — delegates to specialists, manages phases",
        builtinToolNames: BUILTIN_TOOL_NAMES,
        extensions: true,
        skills: true,
        promptMode: "replace",
    };
}
