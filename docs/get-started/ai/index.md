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

Agents get Frontile wrong in a specific, predictable way. Version 0.18 renamed the styling
arguments — `@intent` became `@color`, `@appearance` became `@variant` — and the old names
still resolve. They only log a deprecation warning, and they still appear in older examples
across the web. An agent working from memory, or copying a call site that looks like it
works, produces code that runs and is wrong. The surfaces below exist to replace guessing
with looking it up.

## Where an agent should look

In this order, cheapest and most trustworthy first.

**1. The type declarations in your own `node_modules`.**

```
node_modules/frontile/declarations/**/*.d.ts
```

Authoritative for arguments, types, defaults, and deprecations — and exact for the version
you actually installed, which no published document can be. `frontile` ships `declarations/`
and Glint needs it, so this is already on disk in every app. The JSDoc survives the build,
including the migration instruction:

```ts
/**
 * @deprecated Use `variant`. `default` is now `solid`, `outlined` is
 * `outline`, and `minimal` is `plain`.
 */
appearance?: 'default' | 'soft' | 'outlined' | 'minimal' | 'tonal' | 'custom';
```

**2. The Markdown mirror of the component's page.** Every page on this site is also served
as plain Markdown at the same URL plus `.md` — prose, examples, and yielded blocks, which
type declarations cannot express. See [llms.txt & Markdown](./llms-txt.md).

**3. The index**, when the component's name is not yet known: [`/llms.txt`](/llms.txt).

The split matters. Tier 1 decides whether generated code compiles, and it always matches the
installed version. Tiers 2 and 3 supply prose and discovery, where reading documentation
slightly ahead of your installed version is a much smaller problem.

## The skill

[Frontile's agent skill](./skill.md) packages this lookup order plus the judgment that does
not belong in generated reference: which component to reach for, how the semantic colors
work, and which argument spellings are current.

```bash
npx skills add josemarluedke/frontile
```

## Which origin serves these files

They are emitted by the documentation build, so every version subdomain serves the files for
its own version — but only for versions built after the export existed.

| Origin                                                    | Serves the agent surface  |
| --------------------------------------------------------- | ------------------------- |
| [`next.frontile.dev`](https://next.frontile.dev/llms.txt) | Yes — in-development docs |
| `frontile.dev`                                            | From 0.18 onward          |
| `v0.16.frontile.dev`                                      | No — predates it          |

An origin that does not serve them answers with the site's HTML shell and **HTTP 200**, not
a 404. A fetch that returns HTML where Markdown was expected has failed, whatever the status
code says.
