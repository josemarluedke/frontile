---
title: Agent Skill
order: 3
category: get-started
subcategory: ai
---

# Agent Skill

Frontile ships an [Agent Skill](https://github.com/vercel-labs/skills), a small set of
instructions a coding agent loads when it is working with Frontile, so it stops guessing at
an API it half-remembers.

```bash
npx skills add josemarluedke/frontile
```

The skill is installed into your project, not into Frontile. It works with any agent the
`skills` CLI supports, Claude Code among them.

## What it carries

The skill holds judgment and routes to facts. It deliberately does **not** restate arguments,
types, or defaults.

An installed skill is a copy of a file, frozen at install time, while your `frontile`
dependency moves independently. Any argument list written into it would eventually describe a
version nobody has. So it states where to look instead: first
`node_modules/frontile/declarations/**/*.d.ts`, which is exact for the version you installed,
then the [Markdown mirrors](./llms-txt.md) for prose and examples.

What it does carry:

- **The lookup order.**
- **The semantic color system:** categories with named levels, and why `bg-primary-500` does
  not exist.
- **Component selection** for the genuinely ambiguous choices: Modal versus Drawer versus
  Popover, Select versus NativeSelect versus Autocomplete, Table versus SimpleTable.
- **`.gts` conventions**, including the imports that are not where an agent expects them.
- **The pre-0.18 argument names**, for upgrades and for the older examples still circulating.
  `@intent` and `@appearance` became `@color` and `@variant`, and the old spellings still
  resolve, so nothing fails loudly when an agent reaches for one.

## Keeping it current

Updates are manual. The CLI pulls; nothing is pushed to you:

```bash
npx skills update
```

Worth running after upgrading Frontile, particularly across a minor version. An installed
skill can sit arbitrarily far behind the version in your `package.json`, or ahead of it if you
installed while tracking the development branch.

A stale skill costs you guidance rather than correctness: the facts that decide whether
generated code compiles come from your own `node_modules`.

## Two skills are offered

Installing surfaces a second skill, `frontile-contributor-docs`. That one is for work inside
the Frontile repository itself: writing the component documentation files that live beside
the source. It is of no use in an app that consumes Frontile.

Choose `frontile`. To skip the prompt:

```bash
npx skills add josemarluedke/frontile --skill frontile
```

## Without installing anything

Everything the skill points at is fetchable directly, and [`/llms.txt`](/llms.txt) states the same lookup order in its preamble, so an
agent pointed at the index alone arrives at the same place.
