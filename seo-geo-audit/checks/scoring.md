# Scoring rubric

Scores must be **reproducible**: the same repository, audited twice with the
same version of this skill, must produce the same number. And they must be
**comparable**: two different sites scored the same way can be ranked against
each other. The rules below are therefore mechanical — apply them literally,
do not exercise judgement about "how bad this really is".

Start each category at **100** and deduct.

## Deduction is per check ID, not per occurrence

A check ID is deducted **once**, no matter how many files fail it. Prevalence
raises the deduction on a fixed ladder — it does not multiply without bound.
Ten pages missing a `<title>` is one finding (SEO-001) at the 6+ tier, not ten
findings.

| Severity | 1 occurrence | 2–5 occurrences | 6+ occurrences |
|---|---|---|---|
| high   | -8 | -12 | -16 |
| medium | -3 | -5  | -6  |
| low    | -1 | -2  | -2  |
| info   |  0 |  0  |  0  |

This ladder *is* the cap. There is no separate cap rule.

Always report the occurrence count alongside the finding, so the reader can see
the difference between one stray page and a site-wide failure:

```
SEO-001 · high · -16 — <title> missing (14 of 31 pages)
```

## Not applicable vs. not verifiable

Two states that are **never** deductions, and must never be silently treated as
passes either:

- **N/A** — the check cannot apply to this repo. `HowTo` schema (GEO-009) on a
  site with no tutorials; pagination (SEO-030) on a site with no pagination.
  Exclude from both numerator and denominator; list under "Not applicable".
- **UNVERIFIED** — the check applies, but source analysis cannot settle it.
  The main case is JSON-LD injected at runtime, which `find-jsonld.sh` reports
  as `[JS-EMBEDDED]`: structured data is present, but its validity cannot be
  confirmed without rendering. Never deduct for these, and never report them as
  missing. List under "Unverified" and say what would settle it.

Report the denominator so a score is legible:

```
GEO: 71/100 — scored over 29 of 37 checks (5 N/A, 3 unverified)
```

## Letter grades

| Score | Grade |
|---|---|
| 95–100 | A+ |
| 90–94  | A  |
| 85–89  | A- |
| 80–84  | B+ |
| 75–79  | B  |
| 70–74  | B- |
| 65–69  | C+ |
| 60–64  | C  |
| 55–59  | C- |
| 50–54  | D  |
| <50    | F  |

## Arithmetic

- Sum all deductions, subtract from 100, **floor at 0**. Never negative.
- No rounding is needed — every value in the ladder is an integer.
- Show the arithmetic in the report so the number can be checked:
  `100 − 16 (SEO-001) − 8 (SEO-007) − 5 (SEO-011) = 71`

## Per-category scoring

SEO and GEO are scored **independently**. A site can have an A+ in SEO and a D
in GEO. Don't merge them — they answer different questions.

```
SEO:  A   (92/100)  — scored over 28 of 30 checks (2 N/A)
GEO:  D   (54/100)  — scored over 33 of 37 checks (2 N/A, 2 unverified)
```

## Comparing multiple sites

When auditing several repositories in one pass, the denominators will differ —
a docs site legitimately has more N/A checks than a storefront. Always print
the denominator next to the score, and when ranking sites, rank on the letter
grade and the high-severity count, not on the raw number alone.

## What the score is *not*

The score is **a vibe check, not a contract**. It exists to give a quick sense
of where things stand. The real value is in the individual findings and their
fixes — the letter grade is just the headline. Treat it accordingly in the
report: prominent, but not the focus.
