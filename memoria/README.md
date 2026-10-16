# memoria

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skill that gives every project a working memory between sessions: a local, untracked `_memoria.md` at the repo root, loaded automatically when a session starts.

## Why

Claude starts every session blank. What survives today is either too durable or too raw:

- **CLAUDE.md and auto-memory** hold facts that stay true for months. They are the wrong place for "the migration is half-done on `feat/queue`, tests red on purpose".
- **`claude --resume`** holds the whole transcript, behind an id you have to find among dozens of sessions in the picker.
- **Commit messages** say what changed, not what was decided against, what is waiting on whom, or what comes next.

So I kept telling Claude, in project after project: *keep an untracked `_memoria.md` with the resume command and a log of where we are.* This skill turns that into something that happens without asking, and fixes the parts that went wrong when it was done by hand:

| By hand | With the skill |
|---|---|
| The resume id was whatever someone remembered to paste, often stale | The SessionStart hook writes the current id and keeps the last five |
| Claude only read the file if told to | The hook injects it into context at startup, resume, `/clear` and after compaction |
| A session that ended abruptly left no trace | The SessionEnd hook appends its commits under "Unlogged sessions" for the next one to fold in |
| Each repo needed the `.git/info/exclude` line added by hand | Added automatically; warns if the file is ever tracked |
| The file grew without bound | A 400-line injection cap and a `/memoria prune` routine |

It is the private twin of a `.flowtrack` file: `.flowtrack` is committed and points at the portfolio record; `_memoria.md` is never committed and holds the workbench.

## Install

1. Install the skill (from the repo root): `./install.sh memoria` or `.\install.ps1 -Skills memoria`.
2. Merge the hook block from [`example-settings.json`](example-settings.json) into `~/.claude/settings.json`. Merge, don't overwrite; other hooks can sit alongside.
3. Restart Claude Code.

Needs `bash` and `git` (Git Bash on Windows is enough). No jq, no network.

## Use

Mostly you don't. Open a session in a repo with a `_memoria.md` and the first reply starts with where you left off. In a repo without one, Claude offers once to start it.

| Say | Effect |
|---|---|
| `/memoria init` | Create `_memoria.md` from the template and fill what can be established |
| `/memoria save`, "update memoria", "save where we are" | Update Now, Done, Decisions, Open questions, Next, Running it |
| `/memoria`, "where did we leave off" | Five-line summary |
| `/memoria prune` | Collapse old Done entries, drop answered questions |

## The file

```
# _memoria — <project>
<!-- memoria:resume:start … -->   ← managed by the hook: session id, resume command, history
<!-- memoria:resume:end -->
## Now              what is in flight
## Repo             remote, branch, history quirks, warnings
## Running it       commands, ports, env var names (never values), known breakages
## Done             dated, with commit hashes
## Decisions        with the reason
## Open questions
## Next             numbered, each doable in a sitting
```

See [`examples/_memoria.md`](examples/_memoria.md) for a real one.

## Configuration

Environment variables, all optional:

| Variable | Default | Meaning |
|---|---|---|
| `MEMORIA_FILE` | `_memoria.md` | File name at the project root |
| `MEMORIA_MAX_LINES` | `400` | Lines injected at session start |
| `MEMORIA_HISTORY` | `5` | Earlier session ids kept in the Resume block |
| `MEMORIA_STATE_DIR` | `~/.claude/memoria` | Per-session state and `memoria.log` |

## Files

- `SKILL.md` — when Claude engages and the save routine
- `template.md` — skeleton for new files
- `scripts/session_start.sh` — SessionStart hook
- `scripts/session_end.sh` — SessionEnd hook
- `scripts/init.sh` — create a new `_memoria.md`
- `scripts/lib.sh` — shared helpers
- `example-settings.json` — hook config
- `examples/_memoria.md` — worked example

Hooks always exit 0 and log to `~/.claude/memoria/memoria.log`; a broken hook never blocks a session.
