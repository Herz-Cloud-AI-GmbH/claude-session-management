# Intra-session management

One session keeps working past its context limit and loses nothing it needs. Setup: one settings file and one instruction file, no scripts.

> [!NOTE]
> Install: copy [`intra-session/.claude/`](../intra-session/.claude) into your repo, or [`both/.claude/`](../both/.claude) to add the roles of [inter-session management](inter-session-management.md).

## The parts

- **Window and trigger:** `env` in `.claude/settings.json` decides when compaction fires.
- **Pre-compaction hook:** `hooks.PreCompact` in the same file hands the instruction file to Claude Code.
- **Instruction file:** `.claude/compact-instructions.md` names what every summary keeps.

## The settings

```json
{
  "env": {
    "CLAUDE_CODE_AUTO_COMPACT_WINDOW": "280000",
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "93"
  },
  "hooks": {
    "PreCompact": [
      { "hooks": [{ "type": "command",
          "command": "cat \"$CLAUDE_PROJECT_DIR\"/.claude/compact-instructions.md" }] }
    ]
  }
}
```

The hook has no matcher, so it runs for automatic and manual (`/compact`) compactions alike.

## How a compaction runs

```mermaid
flowchart LR
  W("<b>1 · Work</b><br/>context grows"):::work
  T("<b>2 · Trigger</b><br/>compaction starts"):::cc
  H("<b>3 · Hook</b><br/>returns the file"):::hook
  M("<b>4 · Model</b><br/>writes the summary"):::model
  C("<b>5 · Continue</b><br/>instructions + summary"):::done
  F["<b>Instruction file</b><br/>defaults + additions"]:::file
  W --> T --> H --> M --> C
  F -.-> H
  classDef work fill:#162033,stroke:#94a3b8,stroke-width:2px,color:#f8fafc
  classDef cc fill:#0b2433,stroke:#22d3ee,stroke-width:2px,color:#f8fafc
  classDef hook fill:#2f230b,stroke:#fbbf24,stroke-width:2px,color:#f8fafc
  classDef model fill:#241a4a,stroke:#a78bfa,stroke-width:2px,color:#f8fafc
  classDef done fill:#0c2b24,stroke:#34d399,stroke-width:2px,color:#f8fafc
  classDef file fill:#162033,stroke:#fbbf24,stroke-width:2px,stroke-dasharray:4 3,color:#f8fafc
```

## What the summary keeps

The default summary already carries the request, the files, the errors, the user's messages, the pending work and the next step. The instruction file adds the two things an autonomous session needs to continue correctly:

- **Open questions to the user,** each with its options and a recommendation, marked "not decided".
- **Running work:** each job, agent or run, with its ID and the exact command to check it.

## Tune it

| Setting | Effect | Here |
|---|---|---|
| `CLAUDE_CODE_AUTO_COMPACT_WINDOW` | the window compaction is measured against (100k to 1M tokens) | 280000 |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | the share of the window that triggers it; it can only lower the threshold | 93 |

> [!NOTE]
> Measured with these values, compaction fires at about 240k to 250k tokens. The summary needs room, so the trigger sits below window × percentage.

## Where the settings live

- `.claude/settings.json` in the repo: everyone working in the repo.
- `.claude/settings.local.json`: one person, this repo.
- `~/.claude/settings.json`: one person, all projects.
- Any file, started with `claude --settings <file>`: the sessions started with that flag.

A change applies from the next session start.

## Verify

1. **Start a new session** in the repo and ask it to run `echo $CLAUDE_CODE_AUTO_COMPACT_WINDOW $CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`. Expect `280000 93`.
2. **Run `/compact`.** The summary contains the two added sections.

## Why it works

- **Automatic compaction** keeps a session running without interruption: Claude Code replaces the conversation with a summary and the session goes on with the same identity.
- **The hook** makes the instructions part of every compaction. Claude Code runs it right before it summarises and uses its output as instructions for the summary.
- **The file adds to the default summary,** so the defaults stay intact.
- **Claude Code decides when to compact,** from the configured window. No other part watches the context size.
- **A lower window keeps every turn small.** The context re-sent with each turn stays near the trigger instead of growing toward the model's maximum, and a session with one topic needs about one compaction at most.

## Changelog

| Version | Date | Changes |
|---|---|---|
| 1.1 | 2026-11-12 | Install folders `intra-session/` and `both/` |
| 1.0 | 2026-11-12 | Settings, pre-compaction hook and instruction file |
