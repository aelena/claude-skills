# Code Quality & Coverage Detector

Detect code quality services, test coverage, and linting tools. These produce **priority 2** badges.

## Detection Rules

### Codecov
- **Files:** `codecov.yml`, `.codecov.yml`, `codecov.yaml`
- **Also check:** CI workflows for `codecov/codecov-action` usage, or `codecov` in scripts
- **Badge:**
  ```
  [![Codecov](https://img.shields.io/codecov/c/github/{owner}/{repo}?style={style}&logo=codecov)](https://codecov.io/gh/{owner}/{repo})
  ```
- **Priority:** 2

### Coveralls
- **Files:** `.coveralls.yml`
- **Also check:** CI workflows for `coveralls` commands or `coverallsapp/github-action`
- **Badge:**
  ```
  [![Coveralls](https://img.shields.io/coveralls/github/{owner}/{repo}?style={style}&logo=coveralls)](https://coveralls.io/github/{owner}/{repo})
  ```
- **Priority:** 2

### Codacy
- **Files:** `.codacy.yml`, `.codacy.yaml`
- **Also check:** Existing badges in README referencing codacy
- **Badge:** Requires project token — check existing README badges for the token. If not found, note that the user needs to provide the Codacy project token.
- **Priority:** 2

### Code Climate
- **Files:** `.codeclimate.yml`
- **Badge:**
  ```
  [![Code Climate](https://img.shields.io/codeclimate/maintainability/{owner}/{repo}?style={style}&logo=codeclimate)](https://codeclimate.com/github/{owner}/{repo})
  ```
- **Priority:** 2

### SonarCloud / SonarQube
- **Files:** `sonar-project.properties`, `.sonarcloud.properties`
- **Also check:** CI workflows for `sonarcloud` or `sonarqube` actions
- **Badge:**
  ```
  [![Quality Gate](https://img.shields.io/sonar/quality_gate/{project_key}?server=https%3A%2F%2Fsonarcloud.io&style={style}&logo=sonarcloud)](https://sonarcloud.io/project/overview?id={project_key})
  ```
- **Extract:** `sonar.projectKey` from properties file. Usually `{owner}_{repo}`.
- **Priority:** 2

### Test Frameworks (static badge)
- **Detection:**
  - `jest.config.*` or `jest` in package.json → Jest
  - `vitest.config.*` or `vitest` in package.json → Vitest
  - `pytest.ini`, `pyproject.toml [tool.pytest]`, `conftest.py` → pytest
  - `phpunit.xml` → PHPUnit
  - `*.test.ts`, `*.spec.ts`, `*.test.js` patterns → detect framework from config
  - `rspec` in Gemfile → RSpec
  - `_test.go` files → Go testing
  - `#[test]` in Rust files → Rust tests
- **Badge (static, optional):**
  ```
  [![Tests](https://img.shields.io/badge/tests-{framework}-{color}?style={style}&logo={logo})]()
  ```
- **Priority:** 3 — only include in `full` mode since the CI badge already implies tests pass

### Linting / Formatting
- **Detection:**
  - `.eslintrc*`, `eslint.config.*` → ESLint
  - `.prettierrc*`, `prettier.config.*` → Prettier
  - `biome.json`, `biome.jsonc` → Biome
  - `.flake8`, `ruff.toml`, `.ruff.toml` → Ruff/Flake8
  - `rustfmt.toml` → rustfmt
  - `.golangci.yml` → golangci-lint
  - `.rubocop.yml` → RuboCop
  - `.phpcs.xml` → PHP_CodeSniffer
  - `.stylelintrc*` → Stylelint
- **Badge (static, code style):**
  ```
  [![Code Style](https://img.shields.io/badge/code%20style-{tool}-{color}?style={style}&logo={logo})]({url})
  ```
  Common patterns:
  - Prettier: `[![Code Style](https://img.shields.io/badge/code%20style-prettier-F7B93E?style={style}&logo=prettier)](https://prettier.io/)`
  - Biome: `[![Code Style](https://img.shields.io/badge/code%20style-biome-60A5FA?style={style}&logo=biome)](https://biomejs.dev/)`
  - Ruff: `[![Ruff](https://img.shields.io/badge/linter-ruff-D7FF64?style={style}&logo=ruff)](https://docs.astral.sh/ruff/)`
  - Standard: `[![Standard](https://img.shields.io/badge/code%20style-standard-F3DF49?style={style})](https://standardjs.com/)`
- **Priority:** 3

### Security Scanning
- **Detection:**
  - `snyk` in CI or `.snyk` file → Snyk
  - `dependabot.yml` in `.github/` → Dependabot
  - `renovate.json` or `renovate.json5` → Renovate
- **Badges:**
  - Dependabot: Static badge only (no dynamic endpoint)
    ```
    [![Dependabot](https://img.shields.io/badge/dependabot-enabled-025E8C?style={style}&logo=dependabot)](https://github.com/{owner}/{repo}/security/dependabot)
    ```
  - Renovate:
    ```
    [![Renovate](https://img.shields.io/badge/renovate-enabled-1A1F6C?style={style}&logo=renovatebot)](https://renovatebot.com/)
    ```
- **Priority:** 3
