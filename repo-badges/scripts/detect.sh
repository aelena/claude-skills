#!/usr/bin/env bash
# detect.sh — Enumerate repo characteristics relevant to badge generation.
# Usage: detect.sh [repo_root]
#
# Outputs a structured summary of detected files, configs, and metadata
# that badge detectors use to decide which badges to generate.

set -euo pipefail

ROOT="${1:-.}"
cd "$ROOT"

echo "=== REPO DETECTION REPORT ==="
echo ""

# --- Git Remote ---
echo "## Git Remote"
if git remote get-url origin 2>/dev/null; then
  echo "  remote: $(git remote get-url origin)"
else
  echo "  remote: (none)"
fi
echo ""

# --- Default Branch ---
echo "## Default Branch"
git symbolic-ref --short HEAD 2>/dev/null || echo "(detached or not a git repo)"
echo ""

# --- CI/CD Config Files ---
echo "## CI/CD"
for f in .github/workflows/*.yml .github/workflows/*.yaml; do
  [ -f "$f" ] && echo "  github-actions: $f"
done
[ -f .travis.yml ] && echo "  travis: .travis.yml"
[ -f .circleci/config.yml ] && echo "  circleci: .circleci/config.yml"
[ -f .gitlab-ci.yml ] && echo "  gitlab-ci: .gitlab-ci.yml"
[ -f azure-pipelines.yml ] && echo "  azure: azure-pipelines.yml"
[ -f Jenkinsfile ] && echo "  jenkins: Jenkinsfile"
[ -f .appveyor.yml ] && echo "  appveyor: .appveyor.yml"
[ -f appveyor.yml ] && echo "  appveyor: appveyor.yml"
echo ""

# --- Package Manifests ---
echo "## Package Manifests"
[ -f package.json ] && echo "  npm: package.json"
[ -f pyproject.toml ] && echo "  python: pyproject.toml"
[ -f setup.py ] && echo "  python: setup.py"
[ -f setup.cfg ] && echo "  python: setup.cfg"
[ -f Cargo.toml ] && echo "  rust: Cargo.toml"
[ -f go.mod ] && echo "  go: go.mod"
[ -f pom.xml ] && echo "  java-maven: pom.xml"
[ -f build.gradle ] && echo "  java-gradle: build.gradle"
[ -f build.gradle.kts ] && echo "  kotlin-gradle: build.gradle.kts"
[ -f composer.json ] && echo "  php: composer.json"
[ -f Gemfile ] && echo "  ruby: Gemfile"
[ -f mix.exs ] && echo "  elixir: mix.exs"
[ -f pubspec.yaml ] && echo "  dart: pubspec.yaml"
for f in *.gemspec; do
  [ -f "$f" ] && echo "  ruby-gem: $f"
done
for f in *.csproj; do
  [ -f "$f" ] && echo "  dotnet: $f"
done
for f in *.sln; do
  [ -f "$f" ] && echo "  dotnet-sln: $f"
done
echo ""

# --- License ---
echo "## License"
for f in LICENSE LICENSE.md LICENSE.txt LICENCE LICENCE.md COPYING UNLICENSE; do
  [ -f "$f" ] && echo "  file: $f"
done
echo ""

# --- Docs ---
echo "## Documentation"
[ -d docs ] && echo "  docs-dir: docs/"
[ -f mkdocs.yml ] && echo "  mkdocs: mkdocs.yml"
[ -f .readthedocs.yml ] && echo "  readthedocs: .readthedocs.yml"
[ -f .readthedocs.yaml ] && echo "  readthedocs: .readthedocs.yaml"
[ -d .storybook ] && echo "  storybook: .storybook/"
for f in openapi.yaml openapi.json swagger.yaml swagger.json; do
  [ -f "$f" ] && echo "  openapi: $f"
done
[ -f typedoc.json ] && echo "  typedoc: typedoc.json"
echo ""

# --- Code Quality / Coverage ---
echo "## Quality & Coverage"
[ -f codecov.yml ] && echo "  codecov: codecov.yml"
[ -f .codecov.yml ] && echo "  codecov: .codecov.yml"
[ -f .coveralls.yml ] && echo "  coveralls: .coveralls.yml"
[ -f .codacy.yml ] && echo "  codacy: .codacy.yml"
[ -f .codeclimate.yml ] && echo "  codeclimate: .codeclimate.yml"
[ -f sonar-project.properties ] && echo "  sonar: sonar-project.properties"
echo ""

# --- Linting / Formatting ---
echo "## Linting & Formatting"
for f in .eslintrc .eslintrc.js .eslintrc.json .eslintrc.yml .eslintrc.yaml; do
  [ -f "$f" ] && echo "  eslint: $f"
done
[ -f eslint.config.js ] && echo "  eslint: eslint.config.js"
[ -f eslint.config.mjs ] && echo "  eslint: eslint.config.mjs"
[ -f eslint.config.ts ] && echo "  eslint: eslint.config.ts"
for f in .prettierrc .prettierrc.js .prettierrc.json .prettierrc.yml .prettierrc.yaml prettier.config.js prettier.config.mjs; do
  [ -f "$f" ] && echo "  prettier: $f"
done
[ -f biome.json ] && echo "  biome: biome.json"
[ -f biome.jsonc ] && echo "  biome: biome.jsonc"
[ -f .flake8 ] && echo "  flake8: .flake8"
[ -f ruff.toml ] && echo "  ruff: ruff.toml"
[ -f .ruff.toml ] && echo "  ruff: .ruff.toml"
[ -f rustfmt.toml ] && echo "  rustfmt: rustfmt.toml"
[ -f .golangci.yml ] && echo "  golangci: .golangci.yml"
[ -f .rubocop.yml ] && echo "  rubocop: .rubocop.yml"
echo ""

# --- Community ---
echo "## Community & Social"
[ -f CONTRIBUTING.md ] && echo "  contributing: CONTRIBUTING.md"
[ -f .github/CONTRIBUTING.md ] && echo "  contributing: .github/CONTRIBUTING.md"
[ -f .github/FUNDING.yml ] && echo "  funding: .github/FUNDING.yml"
[ -f SECURITY.md ] && echo "  security: SECURITY.md"
[ -f .github/SECURITY.md ] && echo "  security: .github/SECURITY.md"
[ -f CODE_OF_CONDUCT.md ] && echo "  coc: CODE_OF_CONDUCT.md"
echo ""

# --- Framework Detection ---
echo "## Frameworks"
for f in next.config.js next.config.mjs next.config.ts; do
  [ -f "$f" ] && echo "  nextjs: $f"
done
for f in astro.config.mjs astro.config.ts; do
  [ -f "$f" ] && echo "  astro: $f"
done
for f in nuxt.config.js nuxt.config.ts; do
  [ -f "$f" ] && echo "  nuxt: $f"
done
for f in svelte.config.js svelte.config.ts; do
  [ -f "$f" ] && echo "  sveltekit: $f"
done
[ -f angular.json ] && echo "  angular: angular.json"
for f in vite.config.js vite.config.ts vite.config.mjs; do
  [ -f "$f" ] && echo "  vite: $f"
done
for f in tailwind.config.js tailwind.config.ts tailwind.config.mjs; do
  [ -f "$f" ] && echo "  tailwind: $f"
done
[ -f Dockerfile ] && echo "  docker: Dockerfile"
[ -f docker-compose.yml ] && echo "  docker-compose: docker-compose.yml"
[ -f docker-compose.yaml ] && echo "  docker-compose: docker-compose.yaml"
[ -f tsconfig.json ] && echo "  typescript: tsconfig.json"
echo ""

# --- Dependency Management ---
echo "## Dependency Management"
[ -f .github/dependabot.yml ] && echo "  dependabot: .github/dependabot.yml"
[ -f renovate.json ] && echo "  renovate: renovate.json"
[ -f renovate.json5 ] && echo "  renovate: renovate.json5"
[ -f .snyk ] && echo "  snyk: .snyk"
echo ""

# --- README ---
echo "## README"
for f in README.md readme.md README.rst README README.txt; do
  [ -f "$f" ] && echo "  readme: $f"
done
echo ""

echo "=== END REPORT ==="
