# Shields.io Endpoint Reference

Complete reference for constructing dynamic badge URLs. Base URL: `https://img.shields.io/`

All endpoints support these common query params:
- `style` — `flat` | `flat-square` | `plastic` | `for-the-badge` | `social`
- `logo` — SimpleIcons slug (e.g., `github`, `npm`, `python`)
- `logoColor` — hex color or named color for the logo
- `label` — override the left-side text
- `color` — override the right-side color
- `labelColor` — override the left-side background color

---

## GitHub

### Actions Workflow Status
```
github/actions/workflow/status/{owner}/{repo}/{workflow_file}
github/actions/workflow/status/{owner}/{repo}/{workflow_file}?branch={branch}
```
Link: `https://github.com/{owner}/{repo}/actions/workflows/{workflow_file}`

### License
```
github/license/{owner}/{repo}
```
Link: `https://github.com/{owner}/{repo}/blob/main/LICENSE`

### Release / Tag
```
github/v/release/{owner}/{repo}
github/v/tag/{owner}/{repo}
```
Link: `https://github.com/{owner}/{repo}/releases/latest`

### Languages
```
github/languages/top/{owner}/{repo}
github/languages/count/{owner}/{repo}
```

### Repo Size
```
github/repo-size/{owner}/{repo}
github/languages/code-size/{owner}/{repo}
```

### Last Commit
```
github/last-commit/{owner}/{repo}
github/last-commit/{owner}/{repo}/{branch}
```

### Commit Activity
```
github/commit-activity/m/{owner}/{repo}
github/commit-activity/y/{owner}/{repo}
github/commit-activity/w/{owner}/{repo}
```

### Issues & PRs
```
github/issues/{owner}/{repo}
github/issues-closed/{owner}/{repo}
github/issues-pr/{owner}/{repo}
github/issues-pr-closed/{owner}/{repo}
```
Link: `https://github.com/{owner}/{repo}/issues`

### Stars / Forks / Watchers
```
github/stars/{owner}/{repo}
github/forks/{owner}/{repo}
github/watchers/{owner}/{repo}
```
Link: `https://github.com/{owner}/{repo}/stargazers`

### Contributors
```
github/contributors/{owner}/{repo}
```
Link: `https://github.com/{owner}/{repo}/graphs/contributors`

### Downloads (Releases)
```
github/downloads/{owner}/{repo}/total
github/downloads/{owner}/{repo}/latest/total
```

### Directory File Count
```
github/directory-file-count/{owner}/{repo}
github/directory-file-count/{owner}/{repo}/{path}
```

### Package.json Version
```
github/package-json/v/{owner}/{repo}
```

### Discussions
```
github/discussions/{owner}/{repo}
```

---

## npm

### Version
```
npm/v/{package}
npm/v/{package}/latest
npm/v/{package}/{tag}
npm/v/{@scope}/{package}
```
Link: `https://www.npmjs.com/package/{package}`

### Downloads
```
npm/dw/{package}
npm/dm/{package}
npm/dy/{package}
npm/dt/{package}
```

### Bundle Size
```
bundlephobia/min/{package}
bundlephobia/minzip/{package}
```

### License
```
npm/l/{package}
```

### Node Version
```
node/v/{package}
```

### Types
```
npm/types/{package}
```
> Shows if the package has TypeScript type definitions.

---

## PyPI

### Version
```
pypi/v/{package}
```
Link: `https://pypi.org/project/{package}/`

### Downloads
```
pypi/dm/{package}
pypi/dw/{package}
pypi/dd/{package}
```

### Python Version
```
pypi/pyversions/{package}
```

### Format / Wheel
```
pypi/format/{package}
pypi/wheel/{package}
```

### Status
```
pypi/status/{package}
```

### License
```
pypi/l/{package}
```

---

## crates.io (Rust)

### Version
```
crates/v/{crate}
```
Link: `https://crates.io/crates/{crate}`

### Downloads
```
crates/d/{crate}
crates/dv/{crate}
```

### License
```
crates/l/{crate}
```

### MSRV
```
crates/msrv/{crate}
```

### Size
```
crates/size/{crate}
```

---

## Maven / Gradle (Java/Kotlin)

### Maven Central
```
maven-central/v/{groupId}/{artifactId}
```
Link: `https://search.maven.org/artifact/{groupId}/{artifactId}`

---

## NuGet (.NET)

### Version
```
nuget/v/{package}
nuget/vpre/{package}
```
Link: `https://www.nuget.org/packages/{package}`

### Downloads
```
nuget/dt/{package}
```

---

## RubyGems

### Version
```
gem/v/{gem}
```
Link: `https://rubygems.org/gems/{gem}`

### Downloads
```
gem/dt/{gem}
gem/dv/{gem}
```

---

## Go

### Module Version
```
github/go-mod/go-version/{owner}/{repo}
```
Link: `https://pkg.go.dev/{module_path}`

### Go Reference (docs)
Use `https://pkg.go.dev/badge/{module_path}.svg` directly from pkg.go.dev.

---

## Packagist (PHP/Composer)

### Version
```
packagist/v/{vendor}/{package}
```
Link: `https://packagist.org/packages/{vendor}/{package}`

### Downloads
```
packagist/dt/{vendor}/{package}
packagist/dm/{vendor}/{package}
```

### PHP Version
```
packagist/dependency-v/{vendor}/{package}/php
```

---

## Hex (Elixir/Erlang)

### Version
```
hexpm/v/{package}
```
Link: `https://hex.pm/packages/{package}`

### Downloads
```
hexpm/dt/{package}
```

---

## pub.dev (Dart/Flutter)

### Version
```
pub/v/{package}
```
Link: `https://pub.dev/packages/{package}`

### Points / Likes / Popularity
```
pub/points/{package}
pub/likes/{package}
pub/popularity/{package}
```

---

## Code Coverage

### Codecov
```
codecov/c/github/{owner}/{repo}
codecov/c/github/{owner}/{repo}/{branch}
```
Link: `https://codecov.io/gh/{owner}/{repo}`

### Coveralls
```
coveralls/github/{owner}/{repo}
coveralls/github/{owner}/{repo}?branch={branch}
```
Link: `https://coveralls.io/github/{owner}/{repo}`

---

## Code Quality

### Codacy
```
codacy/grade/{project_token}
codacy/coverage/{project_token}
```
Link: `https://app.codacy.com/gh/{owner}/{repo}/dashboard`

### Code Climate
```
codeclimate/maintainability/{owner}/{repo}
codeclimate/coverage/{owner}/{repo}
```
Link: `https://codeclimate.com/github/{owner}/{repo}`

### SonarCloud
```
sonar/quality_gate/{owner}_{repo}?server=https%3A%2F%2Fsonarcloud.io
sonar/coverage/{owner}_{repo}?server=https%3A%2F%2Fsonarcloud.io
sonar/bugs/{owner}_{repo}?server=https%3A%2F%2Fsonarcloud.io
sonar/vulnerabilities/{owner}_{repo}?server=https%3A%2F%2Fsonarcloud.io
```
Link: `https://sonarcloud.io/project/overview?id={owner}_{repo}`

---

## CI Services (non-GitHub)

### Travis CI
```
travis/com/{owner}/{repo}
travis/com/{owner}/{repo}/{branch}
```
Link: `https://app.travis-ci.com/{owner}/{repo}`

### CircleCI
```
circleci/build/github/{owner}/{repo}/{branch}
```
Link: `https://app.circleci.com/pipelines/github/{owner}/{repo}`

### Azure Pipelines
```
azure-devops/build/{org}/{project}/{definitionId}
```

### GitLab CI
```
gitlab/pipeline-status/{owner}/{repo}
```

### AppVeyor
```
appveyor/build/{owner}/{repo}
```

---

## Documentation

### Read the Docs
```
readthedocs/{project}
```
Link: `https://{project}.readthedocs.io/`

---

## Social / Chat

### Discord
```
discord/{server_id}
```
Link: `https://discord.gg/{invite_code}`

> Note: Requires the server widget to be enabled.

---

## Docker

### Image Version
```
docker/v/{owner}/{image}
docker/v/{owner}/{image}?sort=semver
```
Link: `https://hub.docker.com/r/{owner}/{image}`

### Image Size
```
docker/image-size/{owner}/{image}
```

### Pulls
```
docker/pulls/{owner}/{image}
```

### Stars
```
docker/stars/{owner}/{image}
```

---

## Static / Custom Badges

For anything without a live endpoint:
```
badge/{label}-{message}-{color}
```

Common uses:
- `badge/PRs-welcome-brightgreen` → PRs welcome
- `badge/Maintained-yes-green` → Actively maintained
- `badge/Made%20with-Python-blue?logo=python&logoColor=white` → Made with Python
- `badge/TypeScript-5.0+-blue?logo=typescript&logoColor=white` → TypeScript version
- `badge/platform-linux%20%7C%20macos%20%7C%20windows-lightgrey` → Platform support

---

## Encoding Rules

- Spaces → `%20` or `_` (underscores render as spaces)
- Hyphens (literal) → `--` (double dash)
- Underscores (literal) → `__` (double underscore)
- Forward slashes → use URL encoding or restructure
- In the three-part static format: `{label}-{message}-{color}`, each segment uses the above escaping
