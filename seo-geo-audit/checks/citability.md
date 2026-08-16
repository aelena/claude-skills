# Citability rubric

This rubric scores **content blocks** (typically a paragraph, an answer to a question heading, or a self-contained section) for how readily a language model will quote them. It complements the binary checks in `geo.md` — those tell you whether a feature *exists*; this tells you whether the feature is *good*.

Use it on the highest-leverage blocks: the lede of a key article, the first paragraph after each H2, FAQ answers, definitions. Don't try to score every paragraph in the repo — pick representative blocks per route.

## How to apply

For each selected block, score it 0–100 across five weighted dimensions, then combine. Claude does the scoring as a reasoning pass — these are heuristics, not regex matches.

```
Citability = (AnswerBlock × 0.30)
           + (SelfContainment × 0.25)
           + (StructuralReadability × 0.20)
           + (StatisticalDensity × 0.15)
           + (Uniqueness × 0.10)
```

| Score | Grade | Meaning |
|---|---|---|
| 80–100 | A | LLMs will quote this verbatim |
| 65–79  | B | Citable with minor edits |
| 50–64  | C | Extractable but unlikely to be the chosen excerpt |
| 35–49  | D | LLMs will paraphrase or skip |
| <35    | F | Effectively invisible to citation |

## Dimension 1 — Answer Block Quality (30%)

Does the block deliver a clear, direct answer near the top?

| Signal | Points |
|---|---|
| Definition pattern in opening sentence ("X is…", "X refers to…", "X means…") | +15 |
| Main claim appears in first 60 words | +15 |
| Block is headed by a question (H2/H3 phrased as a query) | +10 |
| Quotable claim cites research, data, or a named source | +10 |
| Average sentence length within 5–25 words | +10 |
| Opens with throat-clearing ("In today's fast-paced world…", "It is well known that…") | −15 |
| Opens by restating the question instead of answering it | −10 |

## Dimension 2 — Self-Containment (25%)

Can the block be lifted out and still make sense?

| Signal | Points |
|---|---|
| Word count between 134–167 (sweet spot) | +20 |
| Word count between 80–250 (acceptable range) | +10 |
| Pronoun density under 2% (low "this", "it", "they" without antecedents) | +8 |
| At least 3 named entities or proper nouns present | +7 |
| Block starts with "This is why…" / "As mentioned above…" / other reference to surrounding context | −10 |
| Block under 40 words or over 350 words | −10 |

## Dimension 3 — Structural Readability (20%)

Is the block shaped like something an LLM can chunk cleanly?

| Signal | Points |
|---|---|
| Uses a list, table, or stepped structure where appropriate | +10 |
| Headings above the block are descriptive, not generic ("Why retry budgets prevent thundering herds" beats "Background") | +5 |
| Code blocks have language hints | +5 |
| One idea per paragraph (no multi-topic walls of text) | +5 |
| Wall-of-text paragraph over 100 words with no internal structure | −10 |
| Important content hidden in "click to expand" / accordion | −10 |

## Dimension 4 — Statistical Density (15%)

Concrete data is the most-cited shape of content.

| Signal | Points (with caps) |
|---|---|
| Each percentage with context ("uptime 99.95% over 6 months") | +3 each, max +6 |
| Each dollar amount with context | +3 each, max +5 |
| Explicit recency marker ("as of &lt;month year&gt;", "updated this quarter") | +2 |
| Named authoritative source ("Gartner", "McKinsey", peer-reviewed journal, government dataset) | +5 |
| Vague quantifiers ("many", "some", "a lot", "most") instead of numbers | −5 |

## Dimension 5 — Uniqueness Signals (10%)

Does the block say something the LLM couldn't get from a generic summary of the topic?

| Signal | Points |
|---|---|
| Reports first-hand experience ("we ran this in production for 18 months and observed…") | +10 |
| Original research, benchmark, or dataset linked | +10 |
| Contrarian or specific claim that wouldn't appear in a generic article | +5 |
| Reads like a generic AI summary of the topic ("In conclusion, there are many factors to consider…") | −10 |
| Pure paraphrase of well-known facts without new framing | −5 |

## Reporting

In the audit report, surface citability as **per-block scores** for the top 3–5 blocks audited, plus a **median citability score** across the sampled blocks. A median below 50 is the headline; individual block scores let the user see which specific paragraphs to rewrite.
