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
export interface ModelConfig {
    /** Map of agent name → model string (e.g. "claude-sonnet-4" or "provider/modelId") */
    agents: Record<string, string>;
}
/** The placeholder marker prefix/suffix used in default-agents.ts */
export declare const MODEL_PLACEHOLDER_PREFIX = "{{model:";
export declare const MODEL_PLACEHOLDER_SUFFIX = "}}";
/**
 * Check if a model string is a placeholder like "{{model:explorer}}"
 */
export declare function isModelPlaceholder(model: string): boolean;
/**
 * Extract agent name from a placeholder like "{{model:explorer}}" → "explorer"
 */
export declare function parseModelPlaceholder(model: string): string | null;
/**
 * Resolve a model placeholder to the actual model string from config.
 * Returns the resolved model, or undefined if the placeholder can't be resolved.
 */
export declare function resolveModelPlaceholder(model: string | undefined, config: ModelConfig): string | undefined;
/**
 * Resolve all model placeholders in a map of agent configs.
 * Modifies the map in place.
 */
export declare function resolveAllPlaceholders(agents: Map<string, {
    model?: string;
}>, config: ModelConfig): void;
/**
 * Load model config from disk, merging global + project overrides.
 * Returns the merged config.
 */
export declare function loadModelConfig(cwd: string): ModelConfig;
/** Re-export for convenience — returns a fully resolved model for an agent. */
export declare function getModelForAgent(agentName: string, cwd: string): string | undefined;
