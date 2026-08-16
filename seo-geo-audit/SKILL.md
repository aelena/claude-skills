---
name: seo-geo-audit
description: Audit a frontend codebase for both classical SEO (meta tags, semantic HTML, structured data, sitemaps) and GEO (Generative Engine Optimization — how easily LLMs can extract, cite, and reason about your content). Reads HTML, JSX, TSX, MDX, Astro, Vue, and Svelte source files; produces a markdown report card with file:line citations and concrete fixes. Use when the user asks for an SEO audit, GEO audit, LLM-friendliness check, structured data review, or invokes /audit, /seo-geo, /seo-geo-audit.
---

# seo-geo-audit

Audit a frontend repository for **classical SEO** (the things Google's crawler cares about) and **GEO** — Generative Engine Optimization, the things *LLMs* care about when they read your content. Outputs a markdown report card with severities, `file:line` citations, and concrete fixes.

The novel value is GEO. Classical SEO scanners have existed for years. But "is your site easy for a language model to extract, cite, and reason about?" is a question only Claude can really answer — because Claude is the consumer.

## Invocation

| Trigger | Behavior |
|---|---|
| `/audit` or `/seo-geo` or `/seo-geo-audit` | Standard audit: SEO + GEO, root-level + key routes, ~30 files max |
| `/audit deep` | Walk all routes/pages discoverable in the repo. Slower, more thorough |
| `/audit seo` | Classical SEO only |
| `/audit geo` | GEO only |
| `/audit fix` | Audit, then propose concrete file edits for each high-severity finding (ask before each edit) |
| `/audit report.md` | Write the report to a file instead of showing inline |
| Natural language: "audit this site for SEO", "is this LLM-friendly", "check my structured data" | Same |

### Stop / disable
Not session-based. One-shot. Just don't invoke it.

## Execution flow

1. **Detect framework** by reading `package.json`. Look for `next`, `astro`, `nuxt`, `svelte-kit`, `remix`, `gatsby`, `vite`, `vue`, or fall back to plain HTML. The framework determines file globs and where pages live (`pages/`, `app/`, `src/routes/`, `src/pages/`, `content/`, etc.).
2. **Discover** content sources via `scripts/discover.sh <framework>`.
3. **Extract** `<head>` content and structured data via `scripts/extract-head.sh` and `scripts/find-jsonld.sh`. For JSX/TSX, look for `<Head>`, `<Helmet>`, `<Metadata>`, or framework-specific patterns (Next.js `metadata` exports, Astro frontmatter, Nuxt `useHead`). Probe AI-discovery files via `scripts/check-ai-files.sh`.
4. **Run checks.** Each check from `checks/seo.md` and `checks/geo.md` is a piece of *Claude reasoning* over the extracted data — not a regex. That's the point: classical scanners can tell you the meta tag exists; only Claude can tell you whether the description is *good*.
5. **Score citability** of 3–5 representative content blocks per audited route using `checks/citability.md`. Report median + per-block scores.
6. **Score robots.txt against the AI crawler tiers** in `checks/ai-crawlers.md` for the GEO-003 finding.
7. **Score** per category using `checks/scoring.md`. Letter grade + numeric score per category.
8. **Render** the report from `templates/report-card.md`, filling in findings with file:line citations, severities, and fix suggestions.
9. **If `fix` mode:** for each high-severity finding, propose a concrete edit using the standard preview-then-apply pattern. For missing JSON-LD findings, start from the matching template in `schema/`, fill placeholders from page source, and never leave a `{{PLACEHOLDER}}` in inserted code. Never apply without user confirmation.

## Cross-skill awareness

If `llms-txt` skill is installed, recommend running it when GEO findings include "missing llms.txt". If `a11y-audit` skill exists, point to it at the bottom of every report ("This audit covers SEO and GEO. For accessibility, run /a11y-audit.").

## Safety guardrails

- **Read-only by default.** Only `fix` mode proposes edits, and every edit needs confirmation.
- **Don't fetch the live site.** Audit the source repo. Live-site auditing is Lighthouse / PageSpeed territory — different tools, different concerns.
- **Don't assume framework conventions.** Check `package.json` first. A `pages/` folder means different things in Next vs Nuxt vs Gatsby vs vanilla.
- **Never modify policy files** (`robots.txt`, `noai` meta tags, `llms.txt`) without explicit user request — those are stakeholder decisions, not technical ones.
- **Skip generated/build artifacts.** Don't audit `dist/`, `build/`, `.next/`, `out/`, `.nuxt/`. Audit *source*.
- **Cap deep audits.** Even in `deep` mode, refuse to scan more than ~500 files without a `--no-limit` confirmation.

## Files in this skill

- `SKILL.md` — this file
- `checks/seo.md` — classical SEO checklist with severities
- `checks/geo.md` — GEO checklist (the novel checks)
- `checks/citability.md` — five-dimension scoring rubric for individual content blocks (referenced from GEO-CIT-* checks)
- `checks/ai-crawlers.md` — tier-based reference of 14 AI crawlers (GPTBot, ClaudeBot, PerplexityBot, etc.) with allow/block rationale (referenced from GEO-003)
- `checks/scoring.md` — how findings map to a 0–100 grade per category
- `templates/report-card.md` — markdown template for the final report
- `schema/` — JSON-LD templates (`organization`, `article`, `local-business`, `product`, `software-application`, `website-searchaction`, `faqpage`, `howto`) used by `fix` mode to insert structured data
- `scripts/discover.sh` — find frontend source files by framework
- `scripts/extract-head.sh` — pull `<head>` content from HTML/JSX/MDX
- `scripts/find-jsonld.sh` — extract `<script type="application/ld+json">` blocks
- `scripts/check-ai-files.sh` — probe for `llms.txt`, `llms-full.txt`, `ai-plugin.json`, `ai.txt`, `indexnow-key.txt`
- `examples/good-site-report.md` — example report on a well-optimized site
- `examples/bad-site-report.md` — example report on a typical greenfield site
