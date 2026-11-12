#!/usr/bin/env bash
# Checks that full-session-mgmt/ is exactly intra-session-mgmt/ plus inter-session-mgmt/. Run before every commit. Needs jq.
set -euo pipefail
cd "$(dirname "$0")/.."

diff intra-session-mgmt/.claude/compact-instructions.md full-session-mgmt/.claude/compact-instructions.md
diff -r inter-session-mgmt/.claude/agents full-session-mgmt/.claude/agents
diff inter-session-mgmt/.claude/hooks/lock-agent.sh full-session-mgmt/.claude/hooks/lock-agent.sh
diff <(jq -S . full-session-mgmt/.claude/settings.json) \
     <(jq -S -s '.[0] * .[1]' intra-session-mgmt/.claude/settings.json inter-session-mgmt/.claude/settings.json)
diff <(cd full-session-mgmt && find . -type f | sort) \
     <({ (cd intra-session-mgmt && find . -type f); (cd inter-session-mgmt && find . -type f); } | sort -u)
echo "ok: full-session-mgmt/ = intra-session-mgmt/ + inter-session-mgmt/"
