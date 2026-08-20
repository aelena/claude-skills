# seo-geo-audit

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skill that audits a frontend codebase for both **classical SEO** (meta tags, semantic HTML, structured data, sitemaps) and **GEO** — Generative Engine Optimization.

**What is GEO?** The things *language models* care about when they read your content. As AI-powered search (ChatGPT, Perplexity, Google AI Overviews) increasingly surfaces web content, your site needs to be readable not just by crawlers but by LLMs. GEO checks whether your content is easy for a model to extract, cite, and reason about — structured data, clear headings, `llms.txt`, FAQ schemas, and more.

The novel value here is GEO. Classical SEO scanners have existed for years. But "is my site LLM-friendly?" is a question only Claude can really answer — because Claude is the consumer. The skill outputs a markdown report card with severities, `file:line` citations, and concrete fixes.

## What it produces

```markdown
# Audit report — example.dev

## Score

| Category | Grade | Score | Findings |
|---|---|---|---|
| SEO  | A   | 92/100 | 0 high · 2 medium · 4 low |
| GEO  | A-  | 88/100 | 0 high · 3 medium · 2 low |
| A11y | not audited | — | run /a11y-audit for accessibility scoring |

## Top fixes (highest leverage first)

### 1. GEO-008 — FAQ pages lack `FAQPage` schema  · *medium*
**Where:** `src/pages/faq.astro:1`
**What's wrong:** The FAQ page renders questions and answers as plain markdown headings...
**Fix:** [concrete code snippet]
...
```

See `examples/good-site-report.md` and `examples/bad-site-report.md` for full sample outputs.

## Quick install

```bash
git clone https://github.com/aelena/seo-geo-audit ~/.claude/skills/seo-geo-audit
```

Or:

```bash
cp -r seo-geo-audit ~/.claude/skills/seo-geo-audit
```

Then, from inside any frontend repo:

```
/seo-geo-audit
```

…or say "audit this site for SEO" / "is this LLM-friendly".

## Invocation cheatsheet

`/seo-geo-audit` is the only slash command — Claude Code takes it from the skill's
directory name. `/audit` and `/seo-geo` work as natural-language triggers but are
not commands and will not autocomplete.

The argument is a **mode**, not a target. The skill reads source from disk and
never fetches a URL, so a domain name is not a valid argument; it audits the
current directory unless you give it a path.

| You say | What happens |
|---|---|
| `/seo-geo-audit` | Standard audit of the current repo: SEO + GEO |
| `/seo-geo-audit deep` | Walk all routes/pages |
| `/seo-geo-audit seo` | Classical SEO only |
| `/seo-geo-audit geo` | GEO only |
| `/seo-geo-audit fix` | Audit, then propose concrete file edits |
| `/seo-geo-audit report.md` | Write the report to a file |
| `/seo-geo-audit ../other-site` | Audit that path instead of the current directory |

Modes combine: `/seo-geo-audit deep geo report.md`.

## What it audits

The skill auto-detects the framework from `package.json` and finds the right files:

- **Next.js** (App Router and Pages Router)
- **Astro**
- **Nuxt**
- **SvelteKit**
- **Remix**
- **Gatsby**
- **Vue (vanilla)**
- **Plain HTML**

Then it runs:

- **30 classical SEO checks** (titles, descriptions, canonicals, viewport, semantic landmarks, alt text, robots, sitemaps, OG/Twitter tags, anti-patterns)
- **37 GEO checks** (llms.txt, JSON-LD coverage, FAQ/HowTo/Article schema, content scannability, citation density, code-as-screenshots, server-side rendering, ...)

See `checks/seo.md` and `checks/geo.md` for the full lists.

## What's in the box

```
seo-geo-audit/
├── SKILL.md
├── checks/
│   ├── seo.md            ← classical SEO checklist
│   ├── geo.md            ← GEO checklist (the novel checks)
│   └── scoring.md        ← severity-to-points rubric
├── templates/
│   └── report-card.md    ← markdown report template
├── scripts/
│   ├── discover.sh       ← framework-aware file discovery
│   ├── extract-head.sh   ← pull <head> content
│   ├── find-jsonld.sh    ← extract JSON-LD blocks
│   └── check-llms-txt.sh ← cross-skill probe
└── examples/
    ├── good-site-report.md
    └── bad-site-report.md
```

## Safety

- **Read-only** by default. `fix` mode previews every edit and asks before applying.
- **Source repo only.** Doesn't fetch live sites — that's Lighthouse territory.
- **Never modifies** `robots.txt`, `noai` meta, or `llms.txt` without explicit user request.

## Related skills

Part of a family of small, opinionated Claude Code skills:

- [claude-poetry-skill](https://github.com/aelena/claude-poetry-skill) — poetic git commit messages
- [llms-txt](https://github.com/aelena/llms-txt) — generate llms.txt index files
- [break-time](https://github.com/aelena/break-time) — ambient break reminders via hooks
- [vibeasfunc](https://github.com/aelena/vibeasfunc) — VBA → functional C# modernization
- [bpmnemonic](https://github.com/aelena/bpmnemonic) — BPMN → specs.md / prd.md translation
- [repo-badges](https://github.com/aelena/repo-badges) — auto-detect toolchain and insert shields.io badges
