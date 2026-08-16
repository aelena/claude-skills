# claude-skills

Seven [Claude Code](https://claude.com/claude-code) skills. Each one exists because I hit the problem it solves and got tired of re-explaining it.

They share a shape: a `SKILL.md` that tells Claude when to engage and how to think about the task, a playbook of domain knowledge it can load on demand, worked examples, and shell scripts for the parts that should be deterministic rather than inferred. No skill here asks Claude to guess at something a script can establish.

## Install

Skills live in `~/.claude/skills/`. Clone and link, or copy:

```bash
git clone https://github.com/aelena/claude-skills.git
cd claude-skills
./install.sh            # macOS / Linux — symlinks each skill
```

```powershell
git clone https://github.com/aelena/claude-skills.git
cd claude-skills
.\install.ps1           # Windows — copies each skill
```

Or just copy the directory of the one you want into `~/.claude/skills/`. There are no dependencies between them.

Restart Claude Code, and each skill becomes available by name or by its trigger phrases.

## The skills

### [`seo-geo-audit`](seo-geo-audit/)
Audits a frontend for classical SEO *and* for GEO — how easily a language model can extract, cite and reason about the page. Reads HTML, JSX, TSX, MDX, Astro, Vue and Svelte, and returns a report card with `file:line` citations and concrete fixes. Ships JSON-LD templates for the schema types that actually move the needle.

The GEO half is the interesting half: it scores citability, answer-shaped structure, and whether AI crawlers are even allowed in.

**Try:** `/seo-geo-audit`

### [`vibeasfunc`](vibeasfunc/)
Translates legacy VBA — Excel macros, Word automation, Access modules — into idiomatic functional C# on .NET 8+. Imperative loops become LINQ, error codes become `Result` types, mutable state becomes immutable records, and side effects get pushed to the boundary.

Written for the specific misery of inheriting a spreadsheet that runs a department.

**Try:** `/vibeasfunc`, `/vba2csharp`

### [`bpmnemonic`](bpmnemonic/)
Turns BPMN 2.0 diagrams into documents people will read: a technical spec for engineers, a PRD for stakeholders, or both. Extracts actors from pools and lanes, narrates the happy path, captures alternative flows from gateways, and surfaces error and timer events as exception flows.

The playbook includes the pitfalls — a parallel gateway narrated as a sequence is the classic one.

**Try:** `/bpmnemonic`, `/bpmn-to-spec`

### [`repo-badges`](repo-badges/)
Detects what a repository actually is — CI, package manager, language, framework, licence, coverage, quality tooling — and adds the shields.io badges that correspond to reality. Seven detector modules, a catalogue of endpoints, and layout templates so the badge block does not turn into a wall.

**Try:** `/repo-badges`

### [`llms-txt`](llms-txt/)
Generates or updates an `llms.txt` at the repository root following the [llmstxt.org](https://llmstxt.org) spec, so a language model can navigate the project instead of grepping it. Also validates an existing one.

**Try:** `/llms-txt`, `/llms-txt validate`

### [`break-time`](break-time/)
Tracks wall-clock time across a session and nudges you to stand up at configurable intervals. Implemented as a `UserPromptSubmit` hook, which means the reminder arrives inside the next response rather than in a notification you will ignore.

Bundled with [`HOOKS-101.md`](break-time/HOOKS-101.md), which is the document I wanted when I first tried to write a hook — the schema is nested twice and nobody explains why.

**Try:** `/break`, `/snooze`

### [`poet-commit`](poet-commit/)
Commit messages as Japanese short-form poetry — haiku, senryū, tanka, renga — with the form auto-selected by diff size. Entirely unserious, and the only skill here I would not defend on utility grounds.

**Try:** `/poet-commit`

## Writing your own

The structure that has worked for me:

```
skill-name/
  SKILL.md          # when to engage, how to think, what "done" means
  playbook/         # domain knowledge, loaded on demand
  examples/         # worked examples — the highest-leverage file
  scripts/          # anything that should be deterministic
  README.md         # for humans browsing GitHub
```

Two things I would pass on. Put the trigger phrases in the `description` frontmatter, explicitly and generously — that field is how the skill gets found, and a vague one means the skill never fires. And push everything mechanical into `scripts/`: parsing, detection, file discovery. A skill that asks the model to infer what a script could establish is a skill that will be wrong occasionally and expensively.

## Licence

[MIT](LICENSE).

---

Built by [Antonio Elena](https://aelena.com). Advisory work at [sig-intent.com](https://sig-intent.com).
