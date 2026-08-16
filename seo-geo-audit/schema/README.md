# JSON-LD schema templates

Drop-in starting points for the highest-leverage schema types. `fix` mode uses these to suggest concrete edits when GEO-005..010 fire.

Each template uses `{{DOUBLE_BRACE}}` placeholders. Before inserting, Claude must:

1. Pick the right template for the page type (article, product, FAQ, etc.).
2. Read the page source to fill placeholders with real values — never leave a `{{PLACEHOLDER}}` in code.
3. Wrap the JSON in `<script type="application/ld+json">…</script>`.
4. For frameworks with metadata APIs (Next `metadata`, Astro frontmatter, Nuxt `useHead`), prefer the framework idiom over a raw `<script>` tag.

| Template | Use on |
|---|---|
| `organization.json` | Site root / about page — establishes the brand entity |
| `article.json` | Blog posts, news, long-form content |
| `local-business.json` | Brick-and-mortar locations |
| `product.json` | E-commerce product detail pages |
| `software-application.json` | SaaS landing pages, app listings |
| `website-searchaction.json` | Site root — declares your search endpoint to Google |
| `faqpage.json` | FAQ pages and help docs with Q&A pairs |
| `howto.json` | Step-by-step tutorial pages |

## Validation

After insertion, validate with:
- [Google Rich Results Test](https://search.google.com/test/rich-results)
- [Schema.org validator](https://validator.schema.org/)

Both are free, no API key.
