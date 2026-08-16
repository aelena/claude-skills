# Badge Layout Rules

How to group, order, and format the generated badge section.

## Insertion Point

Badges go immediately after the first `# H1` heading in the README. If there's a description paragraph right after the H1, badges go between the H1 and the description.

```markdown
# Project Name

<!-- badges-start -->
[![Badge1](url)](link) [![Badge2](url)](link) ...
<!-- badges-end -->

> Short description or tagline

...rest of README
```

If the README has no H1, insert at the very top of the file.

## Marker Comments

Always wrap the badge section in HTML comments:
```html
<!-- badges-start -->
...badges...
<!-- badges-end -->
```

This allows `/repo-badges update` to find and replace the section cleanly. Markers go on their own lines.

## Grouping Order

Badges are displayed in this order, left to right. Each group is separated by a single space (no extra line breaks within the badge line). Groups may be placed on a single line or split across lines depending on count.

1. **Build / CI** — Workflow status badges
2. **Version / Package** — Registry version badges  
3. **Coverage / Quality** — Code quality and test coverage
4. **License** — License badge
5. **Docs** — Documentation site badges
6. **Community** — Discord, Slack, etc.
7. **Activity** — Stars, forks, issues, last commit (optional group)

## Layout Modes

### Single-line (default for <=8 badges)
All badges on one line, separated by spaces:
```markdown
[![CI](...)](#) [![npm](...)](#) [![Coverage](...)](#) [![License](...)](#)
```

### Multi-line (for >8 badges)
Group related badges on the same line, one blank line between groups:
```markdown
[![CI](...)](#) [![Build](...)](#)

[![npm](...)](#) [![Downloads](...)](#) [![Types](...)](#)

[![Coverage](...)](#) [![Code Climate](...)](#)

[![License](...)](#) [![PRs Welcome](...)](#) [![Discord](...)](#)
```

### Table layout (for `for-the-badge` style with many badges)
When using `for-the-badge` style with 10+ badges, consider an HTML table for clean alignment:
```markdown
<p align="center">
  <a href="..."><img src="..." alt="CI"></a>
  <a href="..."><img src="..." alt="npm"></a>
  <a href="..."><img src="..." alt="Coverage"></a>
  <a href="..."><img src="..." alt="License"></a>
</p>
```

## Alignment

- **Left-aligned** (default): Standard for most repos. Just badge markdown on a line.
- **Center-aligned**: Use `<p align="center">` with `<img>` tags. Choose this when:
  - The user requests it
  - The README already centers its header content
  - Using `for-the-badge` style (looks better centered)

## Style Consistency

- If the README already has badges in a specific style, match that style unless the user requested a different one.
- All badges in a section should use the same style parameter.
- Default style: `flat`

## Alt Text

Every badge image must have descriptive alt text:
- Use the badge label as alt text: `![Build Status](...)`, `![npm version](...)`, `![License](...)` 
- Never leave alt text empty: `![](...)` is not acceptable

## Link Targets

Every badge should be wrapped in a link to something useful:
- Build badge → CI dashboard or workflow page
- Version badge → Package registry page
- License badge → LICENSE file
- Coverage badge → Coverage report
- Community badge → Invite link or channel
- If no meaningful link exists, link to the repo itself rather than leaving it unlinked
