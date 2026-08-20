# Audit report — greenfield-startup.io

**Audited:** 2026-04-07
**Scope:** standard (12 files scanned)
**Framework:** Next.js (App Router)

## Score

| Category | Grade | Score | Scored over | Findings |
|---|---|---|---|---|
| SEO  | F | 23/100 | 29 of 30 checks (1 N/A, 0 unverified) | 4 high · 3 medium · 2 low |
| GEO  | F | 1/100  | 35 of 37 checks (2 N/A, 0 unverified) | 6 high · 4 medium · 1 low |

**Arithmetic:**
SEO `100 - 16 - 16 - 16 - 8 - 6 - 6 - 5 - 2 - 2 = 23` ·
GEO `100 - 16 - 16 - 16 - 12 - 8 - 8 - 6 - 6 - 6 - 3 - 2 = 1`

> Typical greenfield Next.js project. The framework gives you a head start on SEO basics and nothing at all on GEO. The biggest wins are: add per-page metadata, drop JSON-LD on the homepage and content pages, and create an `llms.txt`. None of these are hard — they just haven't been done yet.
>
> Note the GEO score has nearly saturated the scale. At this end the number stops discriminating — 1/100 and 8/100 describe the same situation — so work the findings list, not the grade.

---

## Top fixes (highest leverage first)

**Leverage is not the same as deduction.** The ladder charges prevalence, not
urgency. The first item below carries one of the *smaller* deductions on the
page and is still the most urgent thing in this report.

### 1. SEO-024 — `noindex` left in production  · *high* · -8

**Where:** `app/dashboard/page.tsx:3`

**What's wrong:** A `<meta name="robots" content="noindex">` survived from staging. That page is invisible to Google — not ranked poorly, absent. One line, one page, and no amount of other SEO work compensates for it.

**Fix:** Delete the tag, or move it behind an environment check if the page really should stay out of the index.

### 2. SEO-001 — Missing `<title>`  · *high* · -16

**Where:** `app/layout.tsx:1` (cascades to 10 pages with no override)

**What's wrong:** The root layout sets a generic title ("Next.js App") and no page overrides it. Every page in Google looks identical.

**Fix:**
```tsx
// app/blog/[slug]/page.tsx
export async function generateMetadata({ params }) {
  const post = await getPost(params.slug);
  return {
    title: `${post.title} — Greenfield`,
    description: post.excerpt.slice(0, 155),
    openGraph: { title: post.title, description: post.excerpt, images: [post.cover] }
  };
}
```

### 3. SEO-004 — Missing `<meta name="description">`  · *high* · -16

**Where:** `app/layout.tsx:1` (same 10 pages)

**What's wrong:** No page sets a description, so Google writes its own snippet from whatever text it finds first.

**Fix:** The same `generateMetadata` export shown above resolves SEO-001 and SEO-004 together. They are separate check IDs and charged separately, but one edit closes both.

### 4. SEO-007 — Missing canonical  · *high* · -16

**Where:** all 12 routes

**What's wrong:** No canonical URLs anywhere. With both `www` and apex resolving, every page is a duplicate-content candidate against itself.

**Fix:** Set `metadataBase` once in the root layout and `alternates.canonical` per route.

### 5. GEO-005 — No JSON-LD anywhere  · *high* · -16

**Where:** entire codebase (0 blocks found across 12 files)

**What's wrong:** Without JSON-LD, LLMs cannot extract typed entities. Blog posts have no `Article` schema, the homepage no `Organization`, the docs no `TechArticle`.

**Fix:** Start from `schema/organization.json` and `schema/article.json` in this skill. Two blocks, ~30 lines, and GEO-006 closes with it.

### 6. GEO-016 — Headings are not self-contained  · *high* · -16

**Where:** `app/blog/[slug]/page.tsx`, plus 5 individual posts

**What's wrong:** Headings like "Background", "The Problem", "Conclusion" mean nothing out of context. An LLM surfacing a single section as a citation produces something useless.

**Fix:** Rewrite headings to stand alone. "Background" → "Why we needed a new retry policy". "Conclusion" → "Three lessons from rolling out backoff capping".

---

## All findings

Each line shows the check ID, severity, the deduction actually applied, and the
occurrence count. A check ID is charged once regardless of how many files fail it.

### SEO (9)

- **SEO-001** · *high* · -16 — Missing `<title>` (10 occurrences)
  - `app/layout.tsx:1` — generic title, no per-page override
- **SEO-004** · *high* · -16 — Missing description (10 occurrences)
  - `app/layout.tsx:1`
- **SEO-007** · *high* · -16 — Missing canonical (12 occurrences)
  - `app/layout.tsx:1` — no `metadataBase`, no per-route `alternates.canonical`
- **SEO-024** · *high* · -8 — `noindex` in production (1 occurrence)
  - `app/dashboard/page.tsx:3`
- **SEO-015** · *medium* · -6 — Images missing `alt` (12 occurrences)
- **SEO-019** · *medium* · -6 — No Open Graph tags (12 occurrences)
- **SEO-010** · *medium* · -5 — Multiple `<h1>` per page (2 occurrences)
- **SEO-014** · *low* · -2 — Anchor text "click here" (7 occurrences)
- **SEO-018** · *low* · -2 — Images missing dimensions (9 occurrences)

### GEO (11)

- **GEO-005** · *high* · -16 — No JSON-LD (12 occurrences)
- **GEO-006** · *high* · -16 — No `Article` schema on blog posts (6 occurrences)
- **GEO-016** · *high* · -16 — Generic headings throughout (6 occurrences)
- **GEO-021** · *high* · -12 — Code shown as screenshots (2 occurrences)
  - `app/blog/launch.tsx:88`, `app/blog/postmortem.tsx:142` — PNGs of code are invisible to text-only crawlers
- **GEO-001** · *high* · -8 — No `llms.txt` (1 occurrence)
  - `public/` — file does not exist. Run the `llms-txt` skill.
- **GEO-008** · *high* · -8 — FAQ page has no `FAQPage` schema (1 occurrence)
- **GEO-014** · *medium* · -6 — Long paragraphs, median 132 words (6 occurrences)
- **GEO-022** · *medium* · -6 — No author shown (6 occurrences)
- **GEO-023** · *medium* · -6 — No publication date (6 occurrences)
- **GEO-031** · *medium* · -3 — Homepage content rendered client-side only (1 occurrence)
- **GEO-020** · *low* · -2 — Code blocks have no language hints (6 occurrences)

---

## Unverified

Checks that apply but cannot be settled from source alone. **These are not
failures** and carry no deduction.

*None.* The site emits no structured data at all, so nothing was ambiguous —
a clean sheet here reflects the absence of markup, not its correctness.

## Not applicable

Checks excluded from the denominator because they cannot apply to this repo.

- **SEO-030** — Pagination `rel="prev"`/`rel="next"` — nothing is paginated.
- **GEO-009** — `HowTo` schema — the site publishes no tutorials.
- **GEO-010** — `Product` schema — the site sells nothing.

---

## Methodology

This audit was generated by the `seo-geo-audit` Claude skill. Each check is a
piece of semantic reasoning over the source code, not a regex match — meaning
findings reflect *content quality*, not just *presence*.

Scoring follows `checks/scoring.md`: each category starts at 100, each failing
check ID is charged once on a fixed severity/prevalence ladder, and the result
is floored at 0. Not-applicable checks leave the denominator; unverified checks
are never charged. The arithmetic is printed above so the number can be checked.

The score is a headline, not a contract — at this end of the scale it barely
discriminates. The findings and their fixes are the deliverable.

The audit is read-only and reads source only — it does not fetch the live site.
To apply fixes, run `/seo-geo-audit fix` and confirm each edit.
