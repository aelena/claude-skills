# Community & Social Detector

Detect community channels, social links, and contributor info. These produce **priority 2-3** badges.

## Detection Rules

### Discord
- **Detection:** Search README and docs for Discord invite links:
  - `discord.gg/{code}`
  - `discord.com/invite/{code}`
  - `discordapp.com/invite/{code}`
- **Also check:** `CONTRIBUTING.md`, `SUPPORT.md`, `.github/SUPPORT.md`
- **Extract:** The invite code AND the server ID (needed for the dynamic member count badge).
- **Badge (if server ID known):**
  ```
  [![Discord](https://img.shields.io/discord/{server_id}?style={style}&logo=discord&label=discord)](https://discord.gg/{invite_code})
  ```
- **Badge (if only invite code known):**
  ```
  [![Discord](https://img.shields.io/badge/discord-join-5865F2?style={style}&logo=discord&logoColor=white)](https://discord.gg/{invite_code})
  ```
- **Priority:** 2
- **Note:** The dynamic badge requires the server to have the widget enabled.

### Slack
- **Detection:** Search README for Slack invite links or Slack workspace URLs.
- **Badge (static only — no dynamic endpoint):**
  ```
  [![Slack](https://img.shields.io/badge/slack-join-4A154B?style={style}&logo=slack&logoColor=white)]({slack_url})
  ```
- **Priority:** 2

### Twitter / X
- **Detection:** Search README for `twitter.com/{handle}` or `x.com/{handle}`.
- **Badge:**
  ```
  [![Twitter Follow](https://img.shields.io/twitter/follow/{handle}?style={style}&logo=x&label=follow)](https://x.com/{handle})
  ```
- **Priority:** 3

### GitHub Discussions
- **Detection:**
  - Check if discussions tab is mentioned in README or CONTRIBUTING
  - Look for links to `github.com/{owner}/{repo}/discussions`
- **Badge:**
  ```
  [![Discussions](https://img.shields.io/github/discussions/{owner}/{repo}?style={style}&logo=github)](https://github.com/{owner}/{repo}/discussions)
  ```
- **Priority:** 3

### Contributors
- **Badge:**
  ```
  [![Contributors](https://img.shields.io/github/contributors/{owner}/{repo}?style={style})](https://github.com/{owner}/{repo}/graphs/contributors)
  ```
- **Priority:** 3
- **When to include:** In `full` mode, or when the project emphasizes community contribution.

### Contributing Guide
- **Files:** `CONTRIBUTING.md`, `.github/CONTRIBUTING.md`, `docs/CONTRIBUTING.md`
- **Badge (static):**
  ```
  [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen?style={style})](./CONTRIBUTING.md)
  ```
- **Priority:** 2 — signals openness to contributions

### Sponsorship
- **Files:** `.github/FUNDING.yml`
- **Detection:** Read the funding file for platforms:
  - `github` → GitHub Sponsors
  - `open_collective` → Open Collective
  - `ko_fi` → Ko-fi
  - `patreon` → Patreon
  - `buy_me_a_coffee` → Buy Me a Coffee
- **Badge:**
  ```
  [![Sponsor](https://img.shields.io/badge/sponsor-❤-ea4aaa?style={style}&logo=githubsponsors)](https://github.com/sponsors/{owner})
  ```
  Or for specific platforms:
  ```
  [![Open Collective](https://img.shields.io/opencollective/all/{project}?style={style}&logo=opencollective)](https://opencollective.com/{project})
  ```
- **Priority:** 3
- **Note:** Only include emoji in the badge if using `for-the-badge` style. For other styles, use text only.

### Documentation Site
- **Detection:** Search README for links to common doc hosting:
  - `readthedocs.io` or `readthedocs.org`
  - `docs.rs` (Rust)
  - `gitbook.io`
  - `docusaurus` in package.json
  - `vitepress` or `vuepress` in package.json
  - `mkdocs.yml` in project root
  - `_config.yml` (Jekyll, often for GitHub Pages docs)
- **Covered by:** `detectors/docs.md` — community detector should not duplicate.

## Edge Cases

- **Multiple community channels:** Include up to 2. If there's both Discord and Slack, include both. If there are 3+, pick the 2 most prominent (Discord > Slack > Twitter).
- **Dead links:** Don't validate that links are live — just detect them. The badge will show an error state if the endpoint is unreachable, which is actually useful feedback.
