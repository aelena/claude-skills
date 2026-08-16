---
name: repo-badges
description: Automatically detect repo characteristics and add all relevant shields.io badges to README.md. Detects CI/CD, package managers, languages, frameworks, license, code quality tools, coverage, community links, and more. Use when the user asks to add badges, shields, add README badges, badge up a repo, or invokes /repo-badges.
---

# repo-badges

Scan a repository, detect its toolchain, services, and metadata, then generate a complete, well-organized set of shields.io badges and insert them into the README. Badges are dynamic (auto-updating from live services) wherever possible, falling back to static shields.io badges only when no live endpoint exists.

## Why this exists

Good badges give a reader instant signal: Is this maintained? What's it built with? Is CI green? What license? How do I install it? Manually assembling badge URLs is tedious and error-prone. This skill automates the entire process — detection, URL construction, grouping, and insertion — so the README is informative from the first glance.

## Invocation

| Trigger | Behavior |
|---|---|
| `/repo-badges` | Detect and insert all relevant badges into README.md |
| `/repo-badges preview` | Show badge markdown without modifying any files |
| `/repo-badges minimal` | Only essential badges: build status, version, license |
| `/repo-badges full` | Include every applicable badge, even optional/secondary ones |
| `/repo-badges update` | Re-detect and refresh existing badge section, preserving manual additions |
| `/repo-badges remove` | Remove the badge section from README.md |
| `/repo-badges --style <style>` | Use a specific style: `flat` (default), `flat-square`, `plastic`, `for-the-badge`, `social` |
| Natural language: "add badges to readme", "shield up this repo", "add shields to the readme" | Same as `/repo-badges` |

### Stop / disable
Not session-based. One-shot generator. Just don't invoke it.

## Execution flow

1. **Read the README.** Read `README.md` (or `readme.md`, `README.rst`, `README`). If none exists, ask the user if they want one created. Note any existing badge section (look for consecutive image links at the top, or a section between `<!-- badges-start -->` / `<!-- badges-end -->` markers).

2. **Detect repo owner and name.** Extract from:
   - Git remote URL (`git remote get-url origin`)
   - `package.json` → `repository` field
   - Existing README links
   - Ask the user if not determinable
   
   This is critical — most dynamic badges need `owner/repo`.

3. **Run detection.** For each detector in `detectors/`, scan the repo for matching files and config. Each detector outputs a list of applicable badges with:
   - Category (for grouping)
   - Priority (1 = must-have, 2 = recommended, 3 = optional)
   - Badge markdown (with correct shields.io URL)
   - Link target (where the badge should link to)

   Detection order and categories:
   
   | Priority | Category | Detector | What it looks for |
   |----------|----------|----------|-------------------|
   | 1 | Status | `detectors/ci.md` | GitHub Actions, Travis, CircleCI, Jenkins, GitLab CI, Azure Pipelines |
   | 1 | Package | `detectors/package.md` | npm, PyPI, crates.io, Maven, NuGet, RubyGems, Go, Packagist, Hex, pub.dev |
   | 1 | Meta | `detectors/meta.md` | License, language, repo size, last commit |
   | 2 | Quality | `detectors/quality.md` | Codecov, Coveralls, Codacy, Code Climate, SonarCloud, linters |
   | 2 | Community | `detectors/community.md` | Discord, Slack, Twitter, discussions, contributors |
   | 2 | Docs | `detectors/docs.md` | Docs site, wiki, API docs, Storybook |
   | 3 | Activity | `detectors/activity.md` | Stars, forks, issues, PRs, commit activity, downloads |

4. **Filter by mode.**
   - `minimal`: priority 1 only
   - default: priority 1 + 2
   - `full`: all priorities

5. **Apply style.** Default is `flat`. If user specified `--style`, apply it to all badge URLs via `?style=<style>` query param. If existing badges use a consistent style, match it.

6. **Compose badge section.** Group badges by category. Use the layout rules from `templates/layout.md`. Wrap in HTML comments for future updates:
   ```markdown
   <!-- badges-start -->
   <!-- badges-end -->
   ```

7. **Preview.** Show the generated badge markdown to the user. Display a summary table: N badges detected across M categories.

8. **Insert into README.**
   - If `<!-- badges-start -->` / `<!-- badges-end -->` markers exist: replace content between them.
   - If existing badges detected at top of file: replace them (after confirmation).
   - Otherwise: insert after the first H1 heading.
   - Never overwrite without showing the diff first.

9. **Verify endpoints resolve.** For each *dynamic* badge inserted (any URL on `img.shields.io/<service>/...` that is not `/badge/...`), fetch the `.json` form of the URL and inspect the `message` field. Report a table of `endpoint → message` to the user. If any return `invalid`, `not found`, or similar:
   - shields.io caches responses for ~1 hour. A freshly-pushed repo (or freshly-added `LICENSE`) routinely poisons the cache with `invalid` because shields.io queried GitHub before the new state propagated. Don't rewrite the URL — the cache will clear on its own.
   - **Exception — license badge with a newly-added `LICENSE`:** if the `LICENSE` file is uncommitted, in the staging area, or was added in the most recent commit, prefer the **static fallback** documented in `detectors/meta.md` (the `shields.io/badge/license-{spdx}-blue` form) so the badge resolves immediately. Switch to the dynamic GitHub endpoint on a later `/badges update` once the cache warms.
   - Also confirm valid markdown image syntax in the inserted block.

## Badge URL construction

All badges use `https://img.shields.io/` as the base. Refer to `catalog/shields-endpoints.md` for the complete endpoint reference.

**Dynamic badges** (auto-updating):
```
![Build](https://img.shields.io/github/actions/workflow/status/{owner}/{repo}/{workflow}?style=flat)
![npm](https://img.shields.io/npm/v/{package}?style=flat)
![License](https://img.shields.io/github/license/{owner}/{repo}?style=flat)
```

**Static badges** (manual, for things without a live endpoint):
```
![Badge](https://img.shields.io/badge/{label}-{message}-{color}?style=flat)
```

**Rules:**
- Always URL-encode spaces as `%20` and hyphens as `--` in label/message segments
- Always include `?style=` param for consistency
- Always wrap in a link: `[![alt](img-url)](link-url)`
- Use `logo=` param to add icons where a SimpleIcons slug exists
- Use standard colors: `brightgreen`, `green`, `yellow`, `orange`, `red`, `blue`, `lightgrey` — or hex without `#`

## Safety guardrails

- **Never overwrite README content outside the badge section** without explicit confirmation.
- **Never guess the package name.** Read it from the manifest file (`package.json`, `Cargo.toml`, etc.). If ambiguous, ask.
- **Never assume CI workflows exist.** Check `.github/workflows/` and read the YAML to get the actual workflow filename.
- **Never hardcode badge values** (like version numbers) when a dynamic endpoint exists.
- **Don't add badges for services the repo doesn't use.** Every badge must be justified by a detected config file, manifest, or explicit user request.
- **Preserve existing manual badges.** If the user added custom badges outside the managed section, don't touch them.
- **Don't add dead badges.** If you can't determine the correct endpoint parameters, skip the badge and note it in the summary.

## Files in this skill

- `SKILL.md` — this file
- `catalog/shields-endpoints.md` — complete shields.io endpoint reference with URL patterns
- `detectors/ci.md` — CI/CD pipeline detection (GitHub Actions, Travis, CircleCI, etc.)
- `detectors/package.md` — package manager and registry detection
- `detectors/meta.md` — license, language, and repo metadata detection
- `detectors/quality.md` — code quality and coverage tool detection
- `detectors/community.md` — community channels and social links
- `detectors/docs.md` — documentation site and API docs detection
- `detectors/activity.md` — repo activity and popularity metrics
- `templates/layout.md` — badge grouping and ordering rules
- `scripts/detect.sh` — enumerate repo characteristics for badge detection
- `examples/full-badges.md` — example output with all badge categories
- `examples/minimal-badges.md` — example minimal output
- `README.md` — public-facing skill documentation
