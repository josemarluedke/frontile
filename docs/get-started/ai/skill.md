---
title: Agent Skill
order: 3
category: get-started
subcategory: ai
---

# Agent Skill

```bash
npx skills add josemarluedke/frontile
```

Once installed, ask your agent for UI and it builds with Frontile instead of guessing at an
API it half-remembers:

- _"Add a settings form with a name field, an email field, and a save button."_
- _"Put this destructive action behind a confirmation modal."_
- _"Make this table sortable and paginated."_
- _"Restyle these buttons to the danger color."_
- _"This Select should let people type to filter."_

## What a skill is

A skill is a set of instructions an agent loads when it recognises that a task involves
Frontile. It sits in your project, is plain Markdown you can read and edit, and needs no
server, account, or running process. The [`skills` CLI](https://skills.sh) installs it and
supports 35+ agents including Claude Code, Cursor, Codex, and Windsurf.

An MCP server answers questions over a live connection. A skill is loaded text. For a library
whose facts are already on disk in your `node_modules`, text is enough, which is why Frontile
ships a skill and no server.

## What it carries

The skill holds judgment and routes to facts. It does not restate arguments, types, or
defaults.

An installed skill is a copy of a file, frozen at install time, while your `frontile`
dependency moves independently. Any argument list written into it would eventually describe a
version nobody has. So it states where to look instead: first
`node_modules/frontile/declarations/**/*.d.ts`, which is exact for the version you installed,
then the [Markdown mirrors](./llms-txt.md) for prose and examples.

What it does carry:

- **The lookup order**, so the agent checks your installed types before inventing an argument.
- **Component selection** for the genuinely ambiguous choices: Modal versus Drawer versus
  Popover, Select versus NativeSelect versus Autocomplete, Table versus SimpleTable.
- **The semantic color system:** categories with named levels, and why `bg-primary-500` does
  not exist.
- **`.gts` conventions**, including the imports that are not where an agent expects them and
  the Tailwind `@source` lines that, when missing, leave every component unstyled.
- **The pre-0.18 argument names**, for upgrades and for the older examples still circulating.

Reference files load on demand, so a question about colors does not pull in the migration
guidance:

```
skills/frontile/
├── SKILL.md                          # Lookup order, common traps, routing table
└── references/
    ├── api-naming.md                 # Current vs pre-0.18 argument names
    ├── colors.md                     # Semantic categories and levels
    ├── component-selection.md        # Which component for which job
    └── gts-conventions.md            # Template authoring and setup
```

## Using it

Most agents load the skill on their own once they recognise the task involves Frontile. In
agents that support invoking a skill directly, `/frontile` does it explicitly.

## Installing

Project-level by default, which is usually what you want: the skill is committed with the
project, so everyone working on it gets the same guidance. Use `--global` when only some of
your projects use Frontile and you would rather not carry it in every agent's context.

```bash
npx skills add josemarluedke/frontile          # this project
npx skills add josemarluedke/frontile --global # every project on this machine
```

The CLI writes into whichever directory each detected agent reads from. For Claude Code that
is `.claude/skills/frontile`, and the files are plain Markdown you can open, edit, or commit.

Target one agent rather than every detected one:

```bash
npx skills add josemarluedke/frontile --agent claude-code
npx skills add josemarluedke/frontile --agent cursor
```

Installing offers a second skill, `frontile-contributor-docs`. That one is for work inside
the Frontile repository itself, writing the component documentation that lives beside the
source, and is of no use in an app that consumes Frontile. To skip the prompt:

```bash
npx skills add josemarluedke/frontile --skill frontile
```

## Keeping it current

Updates are manual. The CLI pulls; nothing is pushed to you:

```bash
npx skills update
```

Worth running after upgrading Frontile, particularly across a minor version. An installed
skill can sit arbitrarily far behind the version in your `package.json`, or ahead of it if
you installed while tracking the development branch.

A stale skill costs you guidance rather than correctness: the facts that decide whether
generated code compiles come from your own `node_modules`.

## Without installing anything

Everything the skill points at is fetchable directly, and [`/llms.txt`](/llms.txt) states the
same lookup order in its preamble, so an agent pointed at the index alone arrives at the same
place. See [llms.txt & Markdown](./llms-txt.md).

## Found a problem?

If the skill steers an agent wrong, that is a bug in the skill.
[Open an issue](https://github.com/josemarluedke/frontile/issues).

## Related

- [Agent Skills specification](https://agentskills.io/home)
- [Claude Agent Skills](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
- [`skills` CLI](https://skills.sh)
