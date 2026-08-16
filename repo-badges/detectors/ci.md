# CI/CD Pipeline Detector

Detect continuous integration and deployment configurations. These produce **priority 1** (must-have) build status badges.

## Detection Rules

### GitHub Actions
- **Files:** `.github/workflows/*.yml`, `.github/workflows/*.yaml`
- **Action:** Read each workflow file. Extract:
  - `name` field (for display)
  - filename (needed for the badge URL)
  - `on` triggers (to pick the most relevant workflow — prefer `push`/`pull_request` over `schedule`)
- **Badge:** One badge per significant workflow. If there are many workflows, pick the primary CI one (usually named `ci`, `build`, `test`, `main`, or the one triggered on `push` to main/master).
- **URL pattern:**
  ```
  [![{name}](https://img.shields.io/github/actions/workflow/status/{owner}/{repo}/{filename}?style={style}&logo=github)](https://github.com/{owner}/{repo}/actions/workflows/{filename})
  ```
- **Heuristics for picking the "main" workflow:**
  1. Filename contains `ci`, `build`, `test`, or `main`
  2. Triggers include `push` to `main` or `master`
  3. If multiple match, prefer the shortest filename (likely the primary one)
  4. If user has only one workflow, use it regardless of name

### Travis CI
- **Files:** `.travis.yml`
- **Badge:**
  ```
  [![Build Status](https://img.shields.io/travis/com/{owner}/{repo}?style={style}&logo=travis)](https://app.travis-ci.com/{owner}/{repo})
  ```

### CircleCI
- **Files:** `.circleci/config.yml`
- **Badge:**
  ```
  [![CircleCI](https://img.shields.io/circleci/build/github/{owner}/{repo}/main?style={style}&logo=circleci)](https://app.circleci.com/pipelines/github/{owner}/{repo})
  ```
- Use the default branch name detected from git.

### GitLab CI
- **Files:** `.gitlab-ci.yml`
- **Badge:**
  ```
  [![Pipeline](https://img.shields.io/gitlab/pipeline-status/{owner}/{repo}?style={style}&logo=gitlab)](https://gitlab.com/{owner}/{repo}/-/pipelines)
  ```
- Note: Only works for public GitLab repos.

### Azure Pipelines
- **Files:** `azure-pipelines.yml`, `.azure-pipelines/*.yml`
- **Badge:** Requires org name and definition ID — these can't be reliably auto-detected. Note in summary that the user needs to provide these values manually.

### Jenkins
- **Files:** `Jenkinsfile`
- **Badge:** Jenkins badges require the server URL, which can't be auto-detected. Skip with a note.

### AppVeyor
- **Files:** `.appveyor.yml`, `appveyor.yml`
- **Badge:**
  ```
  [![AppVeyor](https://img.shields.io/appveyor/build/{owner}/{repo}?style={style}&logo=appveyor)](https://ci.appveyor.com/project/{owner}/{repo})
  ```

## Output Format

For each detected CI system, emit:
```yaml
- category: "Build"
  priority: 1
  badge: "[![CI](https://img.shields.io/...)](https://...)"
  source: ".github/workflows/ci.yml"
  notes: null
```

## Edge Cases

- **Monorepo with many workflows:** Cap at 3 workflow badges. Pick the top 3 by relevance (CI > deploy > lint > cron).
- **No CI detected:** Don't add any build badges. Don't add a fake "build: passing" static badge — that's misleading.
- **Private repo warning:** Note that most CI badges only work for public repos unless a token is configured.
