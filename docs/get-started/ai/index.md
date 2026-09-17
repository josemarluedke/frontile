---
title: AI & Agents
order: 1
category: get-started
subcategory: ai
---

# AI & Agents

Frontile publishes its documentation in forms a coding agent can read directly: a machine
index, plain-Markdown mirrors of every page, and an installable skill. Nothing here needs a
server, an account, or a plugin.

All of it exists so an agent can read the actual API instead of inventing one that looks
plausible.

## Start here

**Using a coding agent** such as Claude Code, Cursor, or Codex, install the skill:

```bash
npx skills add josemarluedke/frontile
```

It teaches the agent where to look, which component to reach for, and how the styling system
works. See [Agent Skill](./skill.md).

**Using a chat tool**, or wiring something up yourself, point it at
[`/llms.txt`](/llms.txt) and let it follow the links. See
[LLMs.txt](./llms-txt.md).

Neither is required. Every page on this site is available as Markdown at its own URL plus
`.md`, and that works with no setup at all.

## When to reach for Frontile

Frontile is an Ember.js component library built on Tailwind CSS and Tailwind Variants. It
fits when the task is:

- Building UI in an Ember app where Tailwind is acceptable, and you want accessible
  components rather than primitives to style yourself.
- Forms that handle their own labelling, validation display, and sizing.
- Collections such as tables, listboxes, dropdowns, calendars, and command palettes.
- Overlays driven from a template or from code: modals, drawers, popovers, toasts.
- Theming an app to a brand through semantic color tokens, without forking component code.

Reach for something else when the project is React, Vue, Svelte, or plain HTML, when Tailwind
is off the table, or when you want unstyled headless primitives with no prebuilt UI.

## Where an agent should look

In this order, cheapest and most trustworthy first.

**1. The type declarations in your own `node_modules`.**

```
node_modules/frontile/declarations/**/*.d.ts
```

Authoritative for arguments, types, and defaults, and exact for the version you installed,
which no published document can be. `frontile` ships `declarations/` and Glint needs it, so
this is already on disk in every app. The JSDoc survives the build:

```ts
/**
 * The button variant.
 *
 * @defaultValue 'solid'
 */
variant?: 'solid' | 'soft' | 'subtle' | 'outline' | 'ghost' | 'plain' | 'custom';
```

Anything deprecated is marked `@deprecated` here too, with the replacement named.

**2. The Markdown mirror of the component's page.** Every page on this site is also served as
plain Markdown at the same URL plus `.md`, carrying the prose, examples, and yielded blocks
that type declarations cannot express. See [LLMs.txt](./llms-txt.md).

**3. The index**, when the component's name is not yet known: [`/llms.txt`](/llms.txt).

Tier 1 decides whether the generated code compiles, and it always matches the installed
version. Tiers 2 and 3 supply prose and discovery, where reading documentation slightly ahead
of your installed version costs far less.

## Which origin serves these files

They are emitted by the documentation build, so every version subdomain serves the files for
its own version, but only for versions built after the export existed.

| Origin                                                    | Serves the agent surface |
| --------------------------------------------------------- | ------------------------ |
| [`next.frontile.dev`](https://next.frontile.dev/llms.txt) | Yes, in-development docs |
| `frontile.dev`                                            | From 0.18 onward         |
| `v0.16.frontile.dev`                                      | No, predates it          |

> **Note:** An origin that does not serve them answers with the site's HTML shell and HTTP
> 200, not a 404. A fetch that returns HTML where Markdown was expected has failed, whatever
> the status code says.
