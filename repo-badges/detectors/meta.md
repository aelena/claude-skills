# Metadata Detector

Detect repo-level metadata: license, language, size, maintenance signals. These produce **priority 1** badges.

## Detection Rules

### License
- **Files:** `LICENSE`, `LICENSE.md`, `LICENSE.txt`, `LICENCE`, `COPYING`, `UNLICENSE`
- **Also check:** `license` field in `package.json`, `pyproject.toml`, `Cargo.toml`
- **Badge (dynamic from GitHub):**
  ```
  [![License](https://img.shields.io/github/license/{owner}/{repo}?style={style})](https://github.com/{owner}/{repo}/blob/main/LICENSE)
  ```
- **Fallback (static, if license is known but repo isn't on GitHub):**
  ```
  [![License](https://img.shields.io/badge/license-{license_spdx}-blue?style={style})](./LICENSE)
  ```
- **Priority:** 1
- **Link target:** The LICENSE file in the repo.
- **Prefer the static fallback when the LICENSE is freshly added.** If the `LICENSE` file is uncommitted, currently staged, or was added in the most recent commit, the dynamic GitHub endpoint will likely return `invalid` for up to ~1 hour: shields.io queried GitHub before its Licensee scanner classified the new file, and shields.io caches that "no license" response. In this case emit the static fallback (`shields.io/badge/license-{spdx}-blue`), which doesn't depend on any GitHub-side classification. The next `/badges update` (run after the cache warms) can convert it to the dynamic form.

### Primary Language
- **Detection:** Look at file extensions in the repo. Use the dominant language.
- **Badge (dynamic from GitHub):**
  ```
  [![Language](https://img.shields.io/github/languages/top/{owner}/{repo}?style={style})](https://github.com/{owner}/{repo})
  ```
- **Priority:** 2
- **When to skip:** If the repo is overwhelmingly one language (95%+), the language badge is less useful — it's obvious from context. Include it when the repo is multi-language or when the primary language might be surprising.

### Framework / Platform Badge (static)
- **Detection:** Identify the primary framework from config files:
  - `next.config.*` → Next.js
  - `astro.config.*` → Astro
  - `nuxt.config.*` → Nuxt
  - `svelte.config.*` → SvelteKit
  - `angular.json` → Angular
  - `vite.config.*` → Vite
  - `webpack.config.*` → Webpack
  - `tailwind.config.*` → Tailwind CSS
  - `remix.config.*` → Remix
  - `gatsby-config.*` → Gatsby
  - `electron-builder.*` or `electron` in dependencies → Electron
  - `react-native` in dependencies → React Native
  - `flutter` in pubspec.yaml → Flutter
  - `django` or `flask` in requirements/pyproject → Django/Flask
  - `rails` in Gemfile → Rails
  - `spring` in pom.xml/build.gradle → Spring
  - `laravel` in composer.json → Laravel
  - `express` in package.json dependencies → Express
  - `fastapi` in requirements/pyproject → FastAPI
- **Badge:**
  ```
  [![{Framework}](https://img.shields.io/badge/{framework}-{version}+-{color}?style={style}&logo={logo}&logoColor=white)]({url})
  ```
- **Priority:** 2 (useful context, not essential)
- Use appropriate colors:
  - React: `61DAFB`, Next.js: `black`, Vue: `4FC08D`, Angular: `DD0031`
  - Svelte: `FF3E00`, Astro: `BC52EE`, Tailwind: `06B6D4`
  - Django: `092E20`, Flask: `black`, Rails: `CC0000`
  - Spring: `6DB33F`, Laravel: `FF2D20`, Express: `black`

### Last Commit
- **Badge:**
  ```
  [![Last Commit](https://img.shields.io/github/last-commit/{owner}/{repo}?style={style})](https://github.com/{owner}/{repo}/commits)
  ```
- **Priority:** 3
- **When to include:** In `full` mode, or when the repo could be mistaken for abandoned.

### Repo Size
- **Badge:**
  ```
  [![Repo Size](https://img.shields.io/github/repo-size/{owner}/{repo}?style={style})](https://github.com/{owner}/{repo})
  ```
- **Priority:** 3
- **When to include:** Only in `full` mode. Not typically useful.

### Maintenance / Status (static)
- **Detection:** Look for signals:
  - Commits in the last 6 months → "Maintained"
  - `SECURITY.md` exists → project takes maintenance seriously
  - Version >= 1.0.0 → "Stable"
  - Version 0.x → "Beta" or "Experimental"
- **Badge:**
  ```
  [![Maintained](https://img.shields.io/badge/maintained-yes-green?style={style})](https://github.com/{owner}/{repo})
  ```
- **Priority:** 3
- **Caution:** Only add if there's strong evidence. A "maintained: yes" badge on an inactive repo is worse than no badge.

### Platform Support (static)
- **Detection:**
  - CI matrix with multiple OS → multi-platform
  - `.github/workflows/*.yml` containing `os: [ubuntu, macos, windows]`
  - Electron or Tauri → desktop
  - React Native or Flutter → mobile
  - Dockerfile → containerized
- **Badge:**
  ```
  [![Platform](https://img.shields.io/badge/platform-linux%20%7C%20macos%20%7C%20windows-lightgrey?style={style})]()
  ```
- **Priority:** 2 (useful for CLI tools and libraries)
