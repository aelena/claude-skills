# Documentation Detector

Detect documentation sites, API docs, wikis, and related resources. These produce **priority 2** badges.

## Detection Rules

### Read the Docs
- **Detection:** Search README for `readthedocs.io` or `readthedocs.org` links. Also check for `.readthedocs.yml` or `.readthedocs.yaml` config file.
- **Extract:** Project slug from the URL (e.g., `myproject` from `myproject.readthedocs.io`).
- **Badge:**
  ```
  [![Docs](https://img.shields.io/readthedocs/{project}?style={style}&logo=readthedocs)](https://{project}.readthedocs.io/)
  ```
- **Priority:** 2

### docs.rs (Rust)
- **Detection:** If `Cargo.toml` exists and the crate is published, docs.rs is automatic.
- **Badge:**
  ```
  [![docs.rs](https://img.shields.io/docsrs/{crate}?style={style}&logo=docs.rs)](https://docs.rs/{crate})
  ```
- **Priority:** 2

### GitHub Wiki
- **Detection:** Search README for links to `github.com/{owner}/{repo}/wiki`.
- **Badge (static):**
  ```
  [![Wiki](https://img.shields.io/badge/docs-wiki-blue?style={style}&logo=github)](https://github.com/{owner}/{repo}/wiki)
  ```
- **Priority:** 3

### GitHub Pages / Custom Docs Site
- **Detection:**
  - Links to `{owner}.github.io/{repo}` in README
  - `docs/` directory with static site config (`docusaurus.config.js`, `mkdocs.yml`, `_config.yml`, `.vitepress/config.*`)
  - Custom domain in `CNAME` file
- **Badge (static):**
  ```
  [![Docs](https://img.shields.io/badge/docs-online-blue?style={style}&logo=readthedocs)]({docs_url})
  ```
- **Priority:** 2

### Storybook
- **Detection:** `storybook` in package.json devDependencies, or `.storybook/` directory.
- **Badge (static, only if published URL found):**
  ```
  [![Storybook](https://img.shields.io/badge/storybook-deployed-FF4785?style={style}&logo=storybook&logoColor=white)]({storybook_url})
  ```
- **Priority:** 3

### API Documentation (OpenAPI/Swagger)
- **Detection:** `openapi.yaml`, `openapi.json`, `swagger.yaml`, `swagger.json`, or `docs/api/` directory.
- **Badge (static):**
  ```
  [![API Docs](https://img.shields.io/badge/api-docs-blue?style={style}&logo=openapiinitiative)]({api_docs_url})
  ```
- **Priority:** 3
- **Only include** if a published docs URL is found in README. Don't link to raw spec files.

### Typedoc / JSDoc
- **Detection:** `typedoc.json`, `typedoc.config.cjs`, `jsdoc.json`, `jsdoc.config.js` in project.
- **Badge:** Only if a published URL is found. Don't add a badge for internal-only docs.
- **Priority:** 3

## Edge Cases

- **Multiple doc sources:** If both Read the Docs and a custom docs site exist, prefer the one linked from the README header.
- **Docs in progress:** If a `docs/` folder exists but has minimal content and no build config, skip the docs badge.
