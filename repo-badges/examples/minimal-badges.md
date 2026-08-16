# Minimal Badges Example

Example output when running `/repo-badges minimal` on the same project. Only priority 1 badges are included.

**Repo:** `acme/widget-toolkit` (fictional)

---

## Generated Badge Section

```markdown
<!-- badges-start -->
[![CI](https://img.shields.io/github/actions/workflow/status/acme/widget-toolkit/ci.yml?style=flat&logo=github)](https://github.com/acme/widget-toolkit/actions/workflows/ci.yml)
[![npm](https://img.shields.io/npm/v/widget-toolkit?style=flat&logo=npm)](https://www.npmjs.com/package/widget-toolkit)
[![License](https://img.shields.io/github/license/acme/widget-toolkit?style=flat)](https://github.com/acme/widget-toolkit/blob/main/LICENSE)
<!-- badges-end -->
```

## Summary Table

```
Badge Detection Summary: 3 badges across 3 categories (minimal mode)

Category     | Badge              | Source                        | Priority
-------------|--------------------|-------------------------------|----------
Build        | CI                 | .github/workflows/ci.yml      | 1
Package      | npm version        | package.json (widget-toolkit) | 1
Meta         | License            | LICENSE (MIT)                 | 1
```

---

## Minimal for a Python Project

```markdown
<!-- badges-start -->
[![CI](https://img.shields.io/github/actions/workflow/status/acme/dataproc/test.yml?style=flat&logo=github)](https://github.com/acme/dataproc/actions/workflows/test.yml)
[![PyPI](https://img.shields.io/pypi/v/dataproc?style=flat&logo=pypi)](https://pypi.org/project/dataproc/)
[![License](https://img.shields.io/github/license/acme/dataproc?style=flat)](https://github.com/acme/dataproc/blob/main/LICENSE)
<!-- badges-end -->
```

## Minimal for a Rust Project

```markdown
<!-- badges-start -->
[![CI](https://img.shields.io/github/actions/workflow/status/acme/blazer/ci.yml?style=flat&logo=github)](https://github.com/acme/blazer/actions/workflows/ci.yml)
[![Crates.io](https://img.shields.io/crates/v/blazer?style=flat&logo=rust)](https://crates.io/crates/blazer)
[![License](https://img.shields.io/github/license/acme/blazer?style=flat)](https://github.com/acme/blazer/blob/main/LICENSE)
<!-- badges-end -->
```

## Minimal for a Go Project

```markdown
<!-- badges-start -->
[![CI](https://img.shields.io/github/actions/workflow/status/acme/gosvc/test.yml?style=flat&logo=github)](https://github.com/acme/gosvc/actions/workflows/test.yml)
[![Go Version](https://img.shields.io/github/go-mod/go-version/acme/gosvc?style=flat&logo=go)](https://pkg.go.dev/github.com/acme/gosvc)
[![License](https://img.shields.io/github/license/acme/gosvc?style=flat)](https://github.com/acme/gosvc/blob/main/LICENSE)
<!-- badges-end -->
```

## When No CI Exists (private project)

```markdown
<!-- badges-start -->
[![Version](https://img.shields.io/badge/version-1.2.0-blue?style=flat)](./package.json)
[![License](https://img.shields.io/github/license/acme/internal-tool?style=flat)](./LICENSE)
<!-- badges-end -->
```

Note: When no CI is detected and the package is private, the minimal set shrinks to just version + license.
