# Activity & Popularity Detector

Detect repo activity metrics and popularity signals. These produce **priority 3** (optional) badges.

## Detection Rules

### Stars
- **Badge:**
  ```
  [![Stars](https://img.shields.io/github/stars/{owner}/{repo}?style={style})](https://github.com/{owner}/{repo}/stargazers)
  ```
- **Priority:** 3
- **When to include:** In `full` mode, or when the project is popular enough that the star count is a meaningful signal. For small/new repos, star badges can look empty.

### Forks
- **Badge:**
  ```
  [![Forks](https://img.shields.io/github/forks/{owner}/{repo}?style={style})](https://github.com/{owner}/{repo}/network/members)
  ```
- **Priority:** 3
- **When to include:** Only in `full` mode.

### Open Issues
- **Badge:**
  ```
  [![Issues](https://img.shields.io/github/issues/{owner}/{repo}?style={style})](https://github.com/{owner}/{repo}/issues)
  ```
- **Priority:** 3
- **When to include:** Default and full modes. Useful signal for activity.

### Open Pull Requests
- **Badge:**
  ```
  [![Pull Requests](https://img.shields.io/github/issues-pr/{owner}/{repo}?style={style})](https://github.com/{owner}/{repo}/pulls)
  ```
- **Priority:** 3

### Commit Activity
- **Badge:**
  ```
  [![Commit Activity](https://img.shields.io/github/commit-activity/m/{owner}/{repo}?style={style})](https://github.com/{owner}/{repo}/graphs/commit-activity)
  ```
- **Priority:** 3
- **When to include:** In `full` mode. Monthly commit frequency.

### Last Commit
- **Badge:**
  ```
  [![Last Commit](https://img.shields.io/github/last-commit/{owner}/{repo}?style={style})](https://github.com/{owner}/{repo}/commits)
  ```
- **Priority:** 3
- **When to include:** Default and full modes. Quick maintenance signal.

### Release Downloads
- **Badge:**
  ```
  [![Downloads](https://img.shields.io/github/downloads/{owner}/{repo}/total?style={style})](https://github.com/{owner}/{repo}/releases)
  ```
- **Priority:** 3
- **When to include:** Only if the project distributes binaries via GitHub Releases. Check for releases by looking for release links in README or `goreleaser` config.

### GitHub Release
- **Badge:**
  ```
  [![Release](https://img.shields.io/github/v/release/{owner}/{repo}?style={style})](https://github.com/{owner}/{repo}/releases/latest)
  ```
- **Priority:** 2
- **When to include:** If the project uses GitHub Releases (not just tags). Check for release links in README or the `goreleaser.yml` config.
- **When to skip:** If a package registry badge (npm, PyPI, etc.) is already present — the version badge from the registry is more relevant than GitHub releases.

## Grouping

Activity badges go in a separate visual group at the end of the badge section. They are informational and should not compete visually with the more important status/version badges.

## Edge Cases

- **New repo with 0 stars/forks:** Skip stars and forks badges — empty counters look bad.
- **Archived repo:** If the repo is archived, add a static badge instead of activity badges:
  ```
  [![Archived](https://img.shields.io/badge/status-archived-red?style={style})]()
  ```
- **Social style:** If `--style social` is used, stars/forks badges work particularly well since the social style was designed for these counters.
