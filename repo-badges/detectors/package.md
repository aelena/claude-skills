# Package Manager & Registry Detector

Detect package manifests and registries. These produce **priority 1** version/install badges.

## Detection Rules

### npm (Node.js/JavaScript/TypeScript)
- **Files:** `package.json`
- **Extract:** `name`, `version`, `private` field
- **Skip if:** `private: true` — the package isn't published to npm
- **Badges:**
  ```
  [![npm](https://img.shields.io/npm/v/{name}?style={style}&logo=npm)](https://www.npmjs.com/package/{name})
  [![Downloads](https://img.shields.io/npm/dm/{name}?style={style})](https://www.npmjs.com/package/{name})
  ```
- **Scoped packages:** If name is `@scope/pkg`, the URL path is `@scope/pkg` (shields handles encoding).
- **TypeScript types badge:**
  - If `types` or `typings` field exists in package.json, OR a `tsconfig.json` exists:
    ```
    [![TypeScript](https://img.shields.io/npm/types/{name}?style={style}&logo=typescript)](https://www.npmjs.com/package/{name})
    ```
- **Node version:**
  - If `engines.node` exists in package.json:
    ```
    [![Node](https://img.shields.io/node/v/{name}?style={style}&logo=nodedotjs)](https://nodejs.org/)
    ```
- **Bundle size (priority 3):**
  ```
  [![Bundle Size](https://img.shields.io/bundlephobia/minzip/{name}?style={style})](https://bundlephobia.com/package/{name})
  ```

### PyPI (Python)
- **Files:** `setup.py`, `setup.cfg`, `pyproject.toml`
- **Extract:** Package name from:
  - `pyproject.toml` → `[project].name` or `[tool.poetry].name`
  - `setup.cfg` → `[metadata].name`
  - `setup.py` → `name=` argument in `setup()` call
- **Skip if:** No name found, or project is clearly not published (no `[build-system]` in pyproject.toml and no setup.py)
- **Badges:**
  ```
  [![PyPI](https://img.shields.io/pypi/v/{name}?style={style}&logo=pypi)](https://pypi.org/project/{name}/)
  [![Python](https://img.shields.io/pypi/pyversions/{name}?style={style}&logo=python)](https://pypi.org/project/{name}/)
  [![Downloads](https://img.shields.io/pypi/dm/{name}?style={style})](https://pypi.org/project/{name}/)
  ```

### Cargo / crates.io (Rust)
- **Files:** `Cargo.toml`
- **Extract:** `[package].name`, `[package].version`
- **Skip if:** `publish = false`
- **Badges:**
  ```
  [![Crates.io](https://img.shields.io/crates/v/{name}?style={style}&logo=rust)](https://crates.io/crates/{name})
  [![Downloads](https://img.shields.io/crates/d/{name}?style={style})](https://crates.io/crates/{name})
  [![MSRV](https://img.shields.io/crates/msrv/{name}?style={style})](https://crates.io/crates/{name})
  ```
- **Rust edition badge (static):**
  - If `edition` field exists:
    ```
    [![Rust](https://img.shields.io/badge/rust-{edition}+-orange?style={style}&logo=rust)](https://www.rust-lang.org/)
    ```

### Maven Central (Java/Kotlin)
- **Files:** `pom.xml`, `build.gradle`, `build.gradle.kts`
- **Extract:**
  - `pom.xml`: `<groupId>` and `<artifactId>`
  - `build.gradle(.kts)`: `group` and `id` from the `publishing` block, or project name
- **Badge:**
  ```
  [![Maven Central](https://img.shields.io/maven-central/v/{groupId}/{artifactId}?style={style}&logo=apachemaven)](https://search.maven.org/artifact/{groupId}/{artifactId})
  ```

### NuGet (.NET)
- **Files:** `*.csproj`, `*.fsproj`, `*.vbproj`, `*.sln`
- **Extract:** `<PackageId>` from `*.csproj`, or use the project directory name
- **Skip if:** `<IsPackable>false</IsPackable>`
- **Badge:**
  ```
  [![NuGet](https://img.shields.io/nuget/v/{package}?style={style}&logo=nuget)](https://www.nuget.org/packages/{package})
  [![Downloads](https://img.shields.io/nuget/dt/{package}?style={style})](https://www.nuget.org/packages/{package})
  ```

### RubyGems
- **Files:** `*.gemspec`, `Gemfile`
- **Extract:** `spec.name` from gemspec
- **Badge:**
  ```
  [![Gem](https://img.shields.io/gem/v/{name}?style={style}&logo=rubygems)](https://rubygems.org/gems/{name})
  [![Downloads](https://img.shields.io/gem/dt/{name}?style={style})](https://rubygems.org/gems/{name})
  ```

### Go Modules
- **Files:** `go.mod`
- **Extract:** module path from `module` directive
- **Badges:**
  ```
  [![Go Version](https://img.shields.io/github/go-mod/go-version/{owner}/{repo}?style={style}&logo=go)](https://pkg.go.dev/{module_path})
  [![Go Reference](https://pkg.go.dev/badge/{module_path}.svg)](https://pkg.go.dev/{module_path})
  ```
- Note: Go Reference badge comes from pkg.go.dev directly, not shields.io.

### Packagist (PHP)
- **Files:** `composer.json`
- **Extract:** `name` field (format: `vendor/package`)
- **Badge:**
  ```
  [![Packagist](https://img.shields.io/packagist/v/{vendor}/{package}?style={style}&logo=packagist)](https://packagist.org/packages/{vendor}/{package})
  [![PHP Version](https://img.shields.io/packagist/dependency-v/{vendor}/{package}/php?style={style}&logo=php)](https://packagist.org/packages/{vendor}/{package})
  ```

### Hex (Elixir)
- **Files:** `mix.exs`
- **Extract:** project name from `def project` → `:app` field
- **Badge:**
  ```
  [![Hex](https://img.shields.io/hexpm/v/{name}?style={style}&logo=elixir)](https://hex.pm/packages/{name})
  ```

### pub.dev (Dart/Flutter)
- **Files:** `pubspec.yaml`
- **Extract:** `name` field
- **Badges:**
  ```
  [![Pub](https://img.shields.io/pub/v/{name}?style={style}&logo=dart)](https://pub.dev/packages/{name})
  [![Pub Points](https://img.shields.io/pub/points/{name}?style={style})](https://pub.dev/packages/{name})
  ```
- **Flutter-specific:** If `flutter` is in `dependencies` or `environment`, add logo=flutter instead.

### Docker
- **Files:** `Dockerfile`, `docker-compose.yml`, `docker-compose.yaml`, `.dockerignore`
- **Extract:** Image name from Docker Hub or container registry. Check README for Docker Hub links, or use `{owner}/{repo}` as default.
- **Badge (only if Docker Hub image is confirmed):**
  ```
  [![Docker](https://img.shields.io/docker/v/{owner}/{image}?sort=semver&style={style}&logo=docker)](https://hub.docker.com/r/{owner}/{image})
  [![Docker Pulls](https://img.shields.io/docker/pulls/{owner}/{image}?style={style})](https://hub.docker.com/r/{owner}/{image})
  ```
- **Caution:** Only add Docker badges if there's evidence the image is published. Having a Dockerfile alone isn't enough.

## Priority Assignment

| Badge Type | Priority |
|---|---|
| Version (primary registry) | 1 |
| Downloads | 2 |
| Bundle size | 3 |
| Types/TypeScript | 2 |
| Language/runtime version | 2 |
| Docker | 2 |

## Edge Cases

- **Monorepo with multiple packages:** Detect the root package only, unless `workspaces` (npm) or similar config indicates otherwise. Note in summary that sub-packages may need manual badges.
- **Unpublished packages:** If the package appears private or unpublished, skip registry badges. Add a static version badge from the manifest instead:
  ```
  ![Version](https://img.shields.io/badge/version-{version}-blue?style={style})
  ```
