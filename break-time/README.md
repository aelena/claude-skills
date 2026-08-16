# break-time

<!-- badges-start -->
[![Claude Code skill](https://img.shields.io/badge/claude%20code-skill-cc785c?style=flat-square&logo=anthropic&logoColor=white)](https://docs.anthropic.com/en/docs/claude-code)
[![Made with Bash](https://img.shields.io/badge/made%20with-bash-1f425f?style=flat-square&logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Top language](https://img.shields.io/github/languages/top/aelena/break-time?style=flat-square)](https://github.com/aelena/break-time)
[![Repo size](https://img.shields.io/github/repo-size/aelena/break-time?style=flat-square)](https://github.com/aelena/break-time)
[![Last commit](https://img.shields.io/github/last-commit/aelena/break-time?style=flat-square)](https://github.com/aelena/break-time/commits/main)
[![Contributors](https://img.shields.io/github/contributors/aelena/break-time?style=flat-square)](https://github.com/aelena/break-time/graphs/contributors)
[![Open issues](https://img.shields.io/github/issues/aelena/break-time?style=flat-square)](https://github.com/aelena/break-time/issues)
<!-- badges-end -->

An ambient [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skill that nudges you to take a break when you've been coding too long.

**This is not a command you invoke** — once installed, it runs automatically on every prompt via a `UserPromptSubmit` hook. Claude itself can't track wall-clock time across responses, but a shell hook can. When a threshold is crossed, Claude gets a one-line nudge injected into its context and mentions it naturally in its response.

## Quick install

1. Copy this folder to `~/.claude/skills/break-time/`:
   ```bash
   cp -r break-time ~/.claude/skills/break-time
   # or clone directly:
   git clone https://github.com/aelena/break-time ~/.claude/skills/break-time
   ```

2. Wire up the hook in `~/.claude/settings.json`. Merge this into the existing file (don't overwrite):
   ```json
   {
     "hooks": {
       "UserPromptSubmit": [
         {
           "matcher": "*",
           "hooks": [
             {
               "type": "command",
               "command": "bash ~/.claude/skills/break-time/scripts/check_break.sh"
             }
           ]
         }
       ]
     }
   }
   ```

3. Restart Claude Code so the harness picks up the new hook.

4. Done. Defaults: nudges at 45, 90, 120 minutes of active work. Idle for 10+ minutes resets the session.

## Additional Configuration

In optional file `~/.claude/break-time.conf`:

Tailor your settings

```bash
THRESHOLDS="30 60 90"   # minutes — when to nudge
IDLE_GAP=15             # minutes of idle = new session
STYLE=poetic            # friendly | aggressive | poetic
```

## Commands

| Command | Effect |
|---|---|
| `bash ~/.claude/skills/break-time/scripts/state.sh` | Show current state |
| `bash ~/.claude/skills/break-time/scripts/next.sh` | Show next scheduled nudge |
| `bash ~/.claude/skills/break-time/scripts/snooze.sh 60` | Snooze for 60 minutes |
| `bash ~/.claude/skills/break-time/scripts/reset.sh` | Reset session timer |

But it is probably better to just say things in chat, such as

- "snooze break-time"
- "show me break-time state"
- "show next break-time" 
- "reset the break timer"

and Claude will run the right command for you.

## How it works

Read `HOOKS-101.md` for the full beginner-friendly explanation of Claude Code hooks. It's an useful tutorial even if you never install this skill. If the nudge isn't appearing, check `tail ~/.claude/break-time.log` for diagnostics.

## Files

- `SKILL.md` — skill definition Claude loads
- `HOOKS-101.md` — **on writing Claude Code hooks**
- `example-settings.json` — copy-paste hook config
- `scripts/check_break.sh` — the hook itself
- `scripts/snooze.sh` — snooze for N minutes
- `scripts/reset.sh` — reset session timer
- `scripts/state.sh` — print human-readable state
- `scripts/next.sh` — print just the next scheduled nudge

## Related skills

Part of a family of small, opinionated Claude Code skills:

- [claude-poetry-skill](https://github.com/aelena/claude-poetry-skill) — poetic git commit messages
- [llms-txt](https://github.com/aelena/llms-txt) — generate llms.txt index files
- [seo-geo-audit](https://github.com/aelena/seo-geo-audit) — frontend SEO + GEO auditing
- [vibeasfunc](https://github.com/aelena/vibeasfunc) — VBA → functional C# modernization
- [bpmnemonic](https://github.com/aelena/bpmnemonic) — BPMN → specs.md / prd.md translation
- [repo-badges](https://github.com/aelena/repo-badges) — auto-detect toolchain and insert shields.io badges
