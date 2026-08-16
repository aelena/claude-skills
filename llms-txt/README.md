# llms-txt

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skill that generates a high-quality `llms.txt` file at the root of any code repository, following the [llmstxt.org](https://llmstxt.org/) proposed standard.

**What is llms.txt?** A curated markdown file that tells language models what your project is about, where the important docs live, and what they can skip. Think of it as `robots.txt` but for LLMs — a table of contents that fits in a model's context window so it can understand your repo without reading every file.

## What it produces

For a typical repo, the skill emits something like:

```markdown
# acme-cli

> Command-line client for the Acme API, with offline mode and shell completions.

## Docs
- [Getting started](docs/getting-started.md): install, auth, first request
- [Configuration](docs/config.md): config file format and environment variables

## Optional
- [Changelog](CHANGELOG.md): release history
```

The generated file is curated, not exhaustive. The whole point of `llms.txt` is restraint.

## Quick install

Drop the folder into your Claude Code skills directory:

```bash
git clone https://github.com/aelena/llms-txt ~/.claude/skills/llms-txt
```

Or if you have it locally:

```bash
cp -r llms-txt ~/.claude/skills/llms-txt
```

Restart Claude Code if it's running, then in any repo:

```
/llms-txt
```

…or just say "create an llms.txt for this project".

## Invocation cheatsheet

| You say | What happens |
|---|---|
| `/llms-txt` | Generate `llms.txt` at the repo root |
| `/llms-txt full` | Also generate `llms-full.txt` (concatenated full docs) |
| `/llms-txt validate` | Validate an existing `llms.txt` against the spec |
| `/llms-txt update` | Refresh existing `llms.txt`, preserving manual edits |

## What's in the box

```
llms-txt/
├── SKILL.md            ← skill definition Claude loads
├── format.md           ← distilled llmstxt.org format reference
└── scripts/
    ├── discover.sh     ← enumerate candidate files for indexing
    └── validate.sh     ← lint a generated llms.txt against spec basics
```

## Safety

- Never overwrites an existing `llms.txt` without preview + confirmation
- Skips suspected secret files (`.env*`, `*.pem`, `*key*`, `credentials*`, `*.secret`)
- Respects `.gitignore`
- Never invents URLs

## Related skills

Part of a family of small, opinionated Claude Code skills:

- [claude-poetry-skill](https://github.com/aelena/claude-poetry-skill) — poetic git commit messages
- [seo-geo-audit](https://github.com/aelena/seo-geo-audit) — frontend SEO + GEO auditing
- [break-time](https://github.com/aelena/break-time) — ambient break reminders via hooks
- [vibeasfunc](https://github.com/aelena/vibeasfunc) — VBA → functional C# modernization
- [bpmnemonic](https://github.com/aelena/bpmnemonic) — BPMN → specs.md / prd.md translation
- [repo-badges](https://github.com/aelena/repo-badges) — auto-detect toolchain and insert shields.io badges
