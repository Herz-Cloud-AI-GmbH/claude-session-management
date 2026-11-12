#!/usr/bin/env bash
# Checks that both/ is exactly intra-session/ plus inter-session/. Run before every commit. Needs jq.
set -euo pipefail
cd "$(dirname "$0")/.."

diff intra-session/.claude/compact-instructions.md both/.claude/compact-instructions.md
diff -r inter-session/.claude/agents both/.claude/agents
diff inter-session/.claude/hooks/lock-agent.sh both/.claude/hooks/lock-agent.sh
diff <(jq -S . both/.claude/settings.json) \
     <(jq -S -s '.[0] * .[1]' intra-session/.claude/settings.json inter-session/.claude/settings.json)
diff <(cd both && find . -type f | sort) \
     <({ (cd intra-session && find . -type f); (cd inter-session && find . -type f); } | sort -u)
echo "ok: both/ = intra-session/ + inter-session/"
