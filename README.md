# Claude session management

Long-running Claude Code sessions that keep their context, and a team of sessions with a fixed model per role. Pick the part you need and copy one folder into your repo.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/assets/overview-dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="docs/assets/overview-light.svg">
  <img alt="Within every session a pre-compaction hook keeps open questions and running work. Across sessions Design runs on Opus, Lead on Sonnet and Subagents on Haiku." src="docs/assets/overview-light.svg">
</picture>

## Why

- **Sessions run on.** Compaction fires early, so every turn stays small and no one resets a session by hand.
- **Nothing important is lost.** Open questions and running work survive every summary.
- **A fixed model per role.** Opus designs, Sonnet leads, Haiku does the small tasks.
- **One Lead merges.** Parallel sessions never compete for `main`.
- **Enforced, not requested.** Role files, launch commands and a hook keep the roles in place.

## Pick a folder

- **[`intra-session-mgmt/`](intra-session-mgmt):** one session that lasts. The compaction window and trigger, and a hook that keeps open questions and running work in every summary.
- **[`inter-session-mgmt/`](inter-session-mgmt):** a team of sessions. Role files for Design, Lead and the worker subagent, and a hook that locks subagent calls to the defined roles. Needs `jq`.
- **[`full-session-mgmt/`](full-session-mgmt):** everything above in one folder.

Each folder holds a ready-to-copy `.claude/`:

```text
intra-session-mgmt/.claude/
├─ settings.json              compaction window and trigger, the pre-compaction hook
└─ compact-instructions.md    what every summary keeps
inter-session-mgmt/.claude/
├─ settings.json              the subagent hook
├─ agents/                    design.md (Opus) · lead.md (Sonnet) · worker.md (Haiku)
└─ hooks/lock-agent.sh        only the defined subagents, no per-call overrides
full-session-mgmt/.claude/    both of the above, merged
```

## Quick start

1. **Download a folder's `.claude/` into your repo.** Run it in the repo root. It takes `full-session-mgmt`; use `intra-session-mgmt` or `inter-session-mgmt` instead if you want only one part:

   ```bash
   curl -sL https://github.com/Herz-Cloud-AI-GmbH/claude-session-management/archive/refs/heads/main.tar.gz \
     | tar -xz --strip-components=2 --wildcards '*/full-session-mgmt/.claude'
   ```

2. **Intra-session:** start a new session and run `/compact`. The summary contains the two added sections: open questions and running work.
3. **Inter-session:** start a Lead with `claude --agent lead --effort xhigh`. Expect a Sonnet session at xhigh effort.

> [!NOTE]
> The download overwrites an existing `.claude/settings.json`. If you have one, merge the new entries into it by hand. To pin a version, replace `refs/heads/main` with `refs/tags/<release>`.

## What works

Tested with Claude Code 2.1.322.

| Part | Status |
|---|---|
| Pre-compaction hook and instruction file | ✅ tested |
| Role files set the session's model | ✅ tested |
| Subagent file sets the subagent's model | ✅ tested |
| Hook locks subagent calls to the defined roles | ✅ tested |
| Effort levels, organisation-wide settings | 📖 documented by Claude Code, not tested here |

## Where next

- **[Intra-session management](docs/intra-session-management.md):** set up compaction and see how a summary is built.
- **[Inter-session management](docs/inter-session-management.md):** the three roles, their models, and how to enforce them.
- **[`scripts/check.sh`](scripts/check.sh):** for contributors, checks that `full-session-mgmt/` stays equal to the other two folders.
