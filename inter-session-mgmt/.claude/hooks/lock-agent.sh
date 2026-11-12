#!/usr/bin/env bash
# PreToolUse(Agent): allow only the defined subagents, with no per-call overrides.
in=$(cat)
type=$(jq -r '.tool_input.subagent_type // ""' <<<"$in")
over=$(jq -r '.tool_input | has("model") or has("effort")' <<<"$in")
case "$type" in worker) ;; *) echo "Blocked: use the 'worker' subagent, not '$type'." >&2; exit 2 ;; esac
[ "$over" = true ] && { echo "Blocked: do not pass model or effort; the subagent file fixes them." >&2; exit 2; }
exit 0
