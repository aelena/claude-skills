---
name: break-time
description: Track wall-clock time across a Claude Code session and nudge the user to take a break at configurable intervals (default 45/90/120 minutes). Uses a UserPromptSubmit hook to inject break reminders into the next response. Includes commands to snooze and reset the timer. Use when the user asks to set up break reminders, work-rest cycles, time-aware nudges, says "snooze break-time", "when's my next break", "I'm taking a break now", or invokes /break-time.
argument-hint: "[next | snooze <minutes> | reset | configure]"
---

# break-time

An ambient skill that nudges you to take a break when you've been heads-down too long. Claude itself can't track wall-clock time across responses — it only sees the conversation. **Hooks** run *outside* Claude in the harness and can inject context Claude wouldn't otherwise have. That's how this works.

If you've never written a hook, read `HOOKS-101.md` first. It's a standalone tutorial — copy-paste-friendly, ~15 minutes to read, and it's the foundation for *any* ambient skill you might want to build later.

## What it does

- Tracks the start of the current "active session" (resets after 10 minutes of idle).
- On every prompt you submit, computes how long you've been actively working.
- When you cross a configurable threshold (default 45, 90, 120 minutes), injects a one-shot nudge into Claude's context. Claude will mention it briefly in its next response, in its own voice, before answering your question.
- You can snooze it (`/break-time snooze 60`) or reset it (`/break-time reset`).
- Each threshold fires only once per active session — no spam.

## Current state

The output of this command, run when the skill loads (or, where Claude Code hands it over instead, run it first). `/break-time` with no argument needs nothing else:

!`bash "${CLAUDE_SKILL_DIR}/scripts/state.sh" || true`

## Invocation

The skill is two things: a **passive hook** (runs automatically once installed) and a few **active commands** for managing it. The only slash command is `/break-time`; Claude Code derives it from the directory name. Everything else is an argument to it, or plain language.

Run the scripts as `bash "${CLAUDE_SKILL_DIR}/scripts/<name>.sh"`. The working directory is the user's project, not this skill.

| Trigger | Behavior |
|---|---|
| *(automatic)* | The hook fires on every prompt. No invocation needed once installed. |
| `/break-time` | Show current state (above): how long the active session has been running, when the next threshold fires, snooze status. |
| `/break-time next` | Show only the next scheduled nudge (`scripts/next.sh`: when it fires, ETA, whether snooze will mute it). |
| `/break-time snooze [N]` | Snooze nudges for N minutes, default 60 (`scripts/snooze.sh N`). |
| `/break-time reset` | Reset the active session timer, treating *now* as session start (`scripts/reset.sh`). |
| `/break-time configure` | Walk the user through editing thresholds in `~/.claude/break-time.conf`. |
| Natural language: "snooze break-time", "show next break-time", "when's my next break?", "I'm taking a break now", "stop the timer" | Same |

### Disable
Remove the hook block from `~/.claude/settings.json`. The skill files can stay; without the hook wired up, they're inert.

## Installation

1. Copy `break-time/` to `~/.claude/skills/break-time/`.
2. Add the hook block from `example-settings.json` to your `~/.claude/settings.json` (the file already exists; merge, don't overwrite). The hook stays in settings rather than in this skill's frontmatter on purpose: frontmatter hooks register only once the skill is invoked, and a break reminder has to run in sessions where nobody invoked anything.
3. Restart Claude Code so the harness picks up the new hook.
4. That's it. The hook runs on every prompt from now on.

Full beginner walkthrough is in `HOOKS-101.md`.

## How the hook works (mechanically)

1. You submit a prompt.
2. The harness calls `bash ~/.claude/skills/break-time/scripts/check_break.sh` *before* Claude sees the prompt.
3. The hook reads `~/.claude/break-time.state` (a flat key-value file), computes elapsed time, and decides if any threshold has been crossed.
4. If a threshold fires, the hook prints the nudge to stdout as plain text. For `UserPromptSubmit`, the harness adds plain stdout to Claude's context and labels it as hook output itself, so the script does not wrap it in tags.
5. Claude sees the reminder and weaves it into its response: *"By the way, you've been heads-down for 90 minutes — stand up and walk for five before we keep going. Now, about your question..."*
6. Each fired threshold is recorded in the state file so it doesn't fire again until the active session resets.

## Configuration

State and config live in `~/.claude/`:
- `break-time.state` — runtime state (session_start, fired thresholds, snooze)
- `break-time.conf` — optional user config (thresholds, idle gap, message style)

If `break-time.conf` is missing, defaults are used:

```bash
THRESHOLDS="45 90 120"   # minutes — when to nudge
IDLE_GAP=10              # minutes of idle = new session
STYLE=friendly           # friendly | aggressive | poetic
```

`STYLE=poetic` makes the nudge a haiku (cross-skill love letter to `poet-commit`).

## Safety guardrails

- **Never blocks a prompt.** The hook always exits 0 — if it fails, the user's work is unaffected.
- **Always logs to a file** (`~/.claude/break-time.log`) so debugging is possible without surfacing errors in-band.
- **Capped output.** The nudge is one short paragraph. Never floods the context window.
- **Snooze respected always.** If the user has snoozed, the hook still tracks time but emits nothing.
- **No network calls.** Pure local file I/O. Never delays the prompt.

## Files in this skill

- `SKILL.md` — this file
- `HOOKS-101.md` — **standalone tutorial on writing hooks** (publishable)
- `example-settings.json` — copy-paste hook config for `~/.claude/settings.json`
- `scripts/check_break.sh` — the hook itself
- `scripts/snooze.sh` — snooze nudges for N minutes
- `scripts/reset.sh` — reset the active session timer
- `scripts/state.sh` — print current state (the command under *Current state* above)
- `scripts/next.sh` — print just the next scheduled nudge (used by `/break-time next`)
- `README.md` — short install instructions
