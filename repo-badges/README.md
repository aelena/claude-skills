# repo-badges

<!-- badges-start -->
[![License: MIT](https://img.shields.io/badge/license-MIT-blue?style=flat)](./LICENSE) [![Last Commit](https://img.shields.io/github/last-commit/aelena/repo-badges?style=flat)](https://github.com/aelena/repo-badges/commits) [![Issues](https://img.shields.io/github/issues/aelena/repo-badges?style=flat)](https://github.com/aelena/repo-badges/issues)
<!-- badges-end -->

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skill that automatically detects your repository's toolchain, services, and metadata, then generates and inserts a complete set of [shields.io](https://shields.io) badges into your README.

## What It Does

1. **Scans** your repo for CI configs, package manifests, coverage tools, linter configs, community links, docs sites, and license files
2. **Generates** the correct shields.io badge URLs — dynamic (auto-updating) wherever possible
3. **Groups** badges by category with consistent styling
4. **Inserts** them into your README with HTML comment markers for easy updates

## Quick Start

```
/repo-badges           # Detect and insert all relevant badges
/repo-badges preview   # Preview without modifying files
/repo-badges minimal   # Only build status + version + license
/repo-badges full      # Include every applicable badge
/repo-badges update    # Refresh existing badge section
```

## Badge Categories

| Category | Examples | Priority |
|---|---|---|
| **Build** | GitHub Actions, Travis CI, CircleCI | Must-have |
| **Package** | npm, PyPI, crates.io, Maven, NuGet, Go | Must-have |
| **License** | SPDX license from LICENSE file | Must-have |
| **Coverage** | Codecov, Coveralls, Code Climate | Recommended |
| **Quality** | SonarCloud, Codacy, code style | Recommended |
| **Docs** | Read the Docs, docs.rs, custom sites | Recommended |
| **Community** | Discord, Slack, PRs Welcome | Recommended |
| **Activity** | Stars, forks, last commit, downloads | Optional |

## Supported Ecosystems

- **JavaScript/TypeScript** — npm, Yarn, pnpm, Bun
- **Python** — PyPI, Poetry, setuptools
- **Rust** — crates.io, Cargo
- **Go** — Go modules, pkg.go.dev
- **Java/Kotlin** — Maven Central, Gradle
- **.NET** — NuGet
- **Ruby** — RubyGems
- **PHP** — Packagist/Composer
- **Elixir** — Hex
- **Dart/Flutter** — pub.dev
- **Docker** — Docker Hub

## Customization

### Style
```
/repo-badges --style flat          # Default
/repo-badges --style flat-square   # Square corners
/repo-badges --style plastic       # 3D look
/repo-badges --style for-the-badge # Large, bold
/repo-badges --style social        # GitHub social style
```

### Updating
The skill wraps badges in `<!-- badges-start -->` / `<!-- badges-end -->` markers. Running `/repo-badges update` replaces only the content between markers, preserving any manual badges you added outside them.

## Files

```
repo-badges/
├── SKILL.md                      # Skill definition and execution flow
├── README.md                     # This file
├── catalog/
│   └── shields-endpoints.md      # Complete shields.io URL reference
├── detectors/
│   ├── ci.md                     # CI/CD detection (GitHub Actions, Travis, etc.)
│   ├── package.md                # Package registry detection (npm, PyPI, etc.)
│   ├── meta.md                   # License, language, framework detection
│   ├── quality.md                # Coverage and code quality tools
│   ├── community.md              # Discord, Slack, social links
│   ├── docs.md                   # Documentation site detection
│   └── activity.md               # Stars, forks, commit activity
├── templates/
│   └── layout.md                 # Badge grouping and formatting rules
├── scripts/
│   └── detect.sh                 # Shell script for repo scanning
└── examples/
    ├── full-badges.md            # Example with all badge categories
    └── minimal-badges.md         # Example with minimal badges
```

## Installation

Copy or clone into your Claude Code skills directory:

```bash
git clone https://github.com/aelena/repo-badges ~/.claude/skills/repo-badges
# or
cp -r repo-badges ~/.claude/skills/repo-badges
```

Restart Claude Code, then invoke with `/repo-badges` in any repository. You can also trigger it with natural language ("add badges to readme", "shield up this repo").

## Related skills

Part of a family of small, opinionated Claude Code skills:

- [claude-poetry-skill](https://github.com/aelena/claude-poetry-skill) — poetic git commit messages
- [llms-txt](https://github.com/aelena/llms-txt) — generate llms.txt index files
- [seo-geo-audit](https://github.com/aelena/seo-geo-audit) — frontend SEO + GEO auditing
- [break-time](https://github.com/aelena/break-time) — ambient break reminders via hooks
- [vibeasfunc](https://github.com/aelena/vibeasfunc) — VBA → functional C# modernization
- [bpmnemonic](https://github.com/aelena/bpmnemonic) — BPMN → specs.md / prd.md translation
