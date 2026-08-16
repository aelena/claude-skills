# Full Badges Example

Example output when running `/repo-badges full` on a mature TypeScript project published to npm, with GitHub Actions CI, Codecov coverage, Discord community, and Read the Docs documentation.

**Repo:** `acme/widget-toolkit` (fictional)

---

## Generated Badge Section

```markdown
<!-- badges-start -->
[![CI](https://img.shields.io/github/actions/workflow/status/acme/widget-toolkit/ci.yml?style=flat&logo=github)](https://github.com/acme/widget-toolkit/actions/workflows/ci.yml)
[![npm](https://img.shields.io/npm/v/widget-toolkit?style=flat&logo=npm)](https://www.npmjs.com/package/widget-toolkit)
[![Downloads](https://img.shields.io/npm/dm/widget-toolkit?style=flat)](https://www.npmjs.com/package/widget-toolkit)
[![Codecov](https://img.shields.io/codecov/c/github/acme/widget-toolkit?style=flat&logo=codecov)](https://codecov.io/gh/acme/widget-toolkit)
[![License](https://img.shields.io/github/license/acme/widget-toolkit?style=flat)](https://github.com/acme/widget-toolkit/blob/main/LICENSE)
[![TypeScript](https://img.shields.io/npm/types/widget-toolkit?style=flat&logo=typescript)](https://www.npmjs.com/package/widget-toolkit)
[![Docs](https://img.shields.io/readthedocs/widget-toolkit?style=flat&logo=readthedocs)](https://widget-toolkit.readthedocs.io/)
[![Discord](https://img.shields.io/discord/123456789?style=flat&logo=discord&label=discord)](https://discord.gg/abcdef)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen?style=flat)](./CONTRIBUTING.md)
[![Stars](https://img.shields.io/github/stars/acme/widget-toolkit?style=flat)](https://github.com/acme/widget-toolkit/stargazers)
[![Last Commit](https://img.shields.io/github/last-commit/acme/widget-toolkit?style=flat)](https://github.com/acme/widget-toolkit/commits)
<!-- badges-end -->
```

## What It Looks Like (rendered)

The badges render as a single row of shield images at the top of the README, each linking to its respective service:

`[CI: passing] [npm: v2.4.1] [Downloads: 12k/mo] [Coverage: 94%] [License: MIT] [TypeScript] [Docs: passing] [Discord: 234 online] [PRs Welcome] [Stars: 1.2k] [Last Commit: 2 days ago]`

## Summary Table (shown to user during preview)

```
Badge Detection Summary: 11 badges across 7 categories

Category     | Badge              | Source                        | Priority
-------------|--------------------|-------------------------------|----------
Build        | CI                 | .github/workflows/ci.yml      | 1
Package      | npm version        | package.json (widget-toolkit) | 1
Package      | npm downloads      | package.json (widget-toolkit) | 2
Quality      | Codecov            | codecov.yml                   | 2
Meta         | License            | LICENSE (MIT)                 | 1
Package      | TypeScript types   | tsconfig.json                 | 2
Docs         | Read the Docs      | .readthedocs.yml              | 2
Community    | Discord            | README.md (discord link)      | 2
Community    | PRs Welcome        | CONTRIBUTING.md               | 2
Activity     | Stars              | (GitHub API)                  | 3
Activity     | Last Commit        | (GitHub API)                  | 3
```

---

## Same Badges in `for-the-badge` Style

```markdown
<!-- badges-start -->
<p align="center">
  <a href="https://github.com/acme/widget-toolkit/actions/workflows/ci.yml"><img src="https://img.shields.io/github/actions/workflow/status/acme/widget-toolkit/ci.yml?style=for-the-badge&logo=github" alt="CI"></a>
  <a href="https://www.npmjs.com/package/widget-toolkit"><img src="https://img.shields.io/npm/v/widget-toolkit?style=for-the-badge&logo=npm" alt="npm"></a>
  <a href="https://www.npmjs.com/package/widget-toolkit"><img src="https://img.shields.io/npm/dm/widget-toolkit?style=for-the-badge" alt="Downloads"></a>
  <a href="https://codecov.io/gh/acme/widget-toolkit"><img src="https://img.shields.io/codecov/c/github/acme/widget-toolkit?style=for-the-badge&logo=codecov" alt="Coverage"></a>
  <a href="https://github.com/acme/widget-toolkit/blob/main/LICENSE"><img src="https://img.shields.io/github/license/acme/widget-toolkit?style=for-the-badge" alt="License"></a>
</p>
<!-- badges-end -->
```
