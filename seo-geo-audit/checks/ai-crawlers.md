# AI crawler reference

Use this list when auditing `robots.txt` for `GEO-003`. Each entry has a tier, a recommendation, and the cost of blocking it. Default policy: **allow Tier 1 and Tier 2; Tier 3 is a stakeholder decision**.

A blanket `User-agent: *  Disallow: /` blocks all of these. If the user has that and isn't behind a staging gate, flag it as a **high**-severity finding.

## Tier 1 — Critical for live AI search visibility (recommend ALLOW)

These power active AI search products that drive referral traffic. Blocking them removes you from answer surfaces millions of users see daily.

| User-agent | Operator | Purpose | Cost of blocking |
|---|---|---|---|
| `GPTBot` | OpenAI | Crawls for ChatGPT browsing, plugins, search | Excluded from ChatGPT Search (~300M weekly active users) |
| `OAI-SearchBot` | OpenAI | Powers ChatGPT search; **not** used for model training | Excluded from ChatGPT search results |
| `ChatGPT-User` | OpenAI | Acts on a user's explicit "visit this URL" request | ChatGPT cannot fetch pages users ask it to read |
| `ClaudeBot` | Anthropic | Powers Claude's web search and citation features | Inaccessible to Claude web search |
| `PerplexityBot` | Perplexity | Powers Perplexity's sourced-answer engine | Excluded from Perplexity (one of the strongest AI referral sources) |

## Tier 2 — Important for the broader AI ecosystem (recommend ALLOW)

These serve large platforms with massive distribution. The default is allow; the exception is when the org has an explicit policy reason to opt out.

| User-agent | Operator | Purpose | Cost of blocking |
|---|---|---|---|
| `Google-Extended` | Google | Controls Gemini training and AI Overviews. **Does not affect Google Search rankings.** | Content excluded from Gemini and AI Overviews training |
| `GoogleOther` | Google | Research crawls and AI data collection | Reduced presence in Google's experimental AI features |
| `Applebot-Extended` | Apple | Trains Apple Intelligence, Siri | May not surface in Apple Intelligence on 2B+ devices |
| `Amazonbot` | Amazon | Indexes for Alexa answers | Excluded from Alexa voice responses |
| `FacebookBot` | Meta | Used by Meta AI across Facebook, Instagram, WhatsApp | Inaccessible to Meta AI features |

## Tier 3 — Training-only crawlers (context-dependent)

These primarily build training datasets. No live-search impact, so blocking them is a values/policy choice with no immediate traffic cost. Flag the user's current setting; don't push them either way.

| User-agent | Operator | Purpose | Notes |
|---|---|---|---|
| `CCBot` | Common Crawl | Public dataset used by many model trainers (Google, Meta, Stability) | Blocking removes you from a widely-reused open dataset |
| `anthropic-ai` | Anthropic | Anthropic safety research and Claude training (separate from `ClaudeBot`) | Blocking does **not** affect Claude's live web-search access |
| `Bytespider` | ByteDance | TikTok AI features and Doubao | **Recommend BLOCK** for Western businesses (aggressive crawl behavior reported); **ALLOW** for Asian/Chinese markets |
| `cohere-ai` | Cohere | Enterprise AI and Coral chat training | Low consumer-facing exposure either way |

## How to read a robots.txt against this list

When auditing:

1. Parse `robots.txt` (root, `public/`, `static/`).
2. For each user-agent above, determine whether the file allows or disallows it. Remember: a `User-agent: *  Disallow: /` block applies to **all** of them unless overridden.
3. Classify the result per tier:
   - **Tier 1 blocked** → high severity finding. Almost always accidental.
   - **Tier 2 blocked** → medium severity. Worth confirming with the user it's intentional.
   - **Tier 3 blocked** → info only. Note the policy and move on.
4. Also check for AI-policy directives that override defaults: `Content-Signal:` (IETF draft), `X-Robots-Tag` headers if visible in source, and `<meta name="noai">` / `<meta name="noimageai">` tags.

## Anti-patterns

- **Outdated copy-paste blocks** — many `robots.txt` files block AI crawlers with outdated rationale ("AI scraping"), unaware that this also disables ChatGPT browsing on user request. Surface these as a high finding with the recommendation to split: keep training opt-outs, allow live-search agents.
- **Allow-listing only one vendor** — e.g., allowing `GPTBot` but blocking `ClaudeBot` and `PerplexityBot`. Usually accidental; flag as medium.
- **Blocking via `User-agent: *`** without explicit AI-crawler entries — catches everything, including the live-search bots the user probably wants.
