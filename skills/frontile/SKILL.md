---
name: frontile
description: Build UI with Frontile, the Ember.js component library, in an app that depends on it. Use this whenever writing or editing `.gts`/`.gjs` templates that render Frontile components (Button, Input, Select, Modal, Drawer, Table, Listbox, Autocomplete, Alert, and the rest), choosing between similar Frontile components, styling them with the semantic color system, or upgrading code that still uses the pre-0.18 `@intent`/`@appearance` arguments. Also use it when a Frontile component renders unstyled, when a color class like `bg-primary-500` does not work, or when you need a component's exact arguments.
---

# Frontile

An Ember.js component library styled with Tailwind CSS and Tailwind Variants. Everything
ships from the single `frontile` package; `@frontile/theme` supplies the styling system.

This skill carries judgment and routes to facts. It does not restate argument lists, types,
or defaults. Those live in the declarations on disk, they are version-exact there, and any
copy kept here would go stale on the next release.

## Get the facts before writing the code

Look arguments up rather than recalling them. Some of Frontile's older spellings still
resolve, so a wrong guess produces code that runs and is wrong instead of failing. In this
order:

**1. `node_modules/frontile/declarations/**/*.d.ts` — prefer this.**
Authoritative for arguments, types, defaults, and deprecations. Version-exact by
construction, and no network. `frontile` publishes `declarations/`, and Glint needs it, so
every consuming app already has it. The JSDoc is complete: `@defaultValue` for defaults and
`@deprecated` carrying the migration instruction:

```ts
/**
 * @deprecated Use `variant`. `default` is now `solid`, `outlined` is
 * `outline`, and `minimal` is `plain`.
 */
appearance?: 'default' | 'soft' | 'outlined' | 'minimal' | 'tonal' | 'custom';
```

An argument whose JSDoc starts with `@deprecated` must not be used in new code.

**2. `https://frontile.dev/docs/components/<category>/<name>.md`** — prose, usage examples,
and yielded blocks, which the declarations cannot give. Categories are `buttons`,
`collections`, `disclosure`, `forms`, `navigation`, `notifications`, `overlays`, `status`,
`utilities`. Fetch the `.md`, not the HTML page.

**3. `https://frontile.dev/llms.txt`** — the index, when the component's name is not yet
known. Component entries carry a one-line description, so the right one can usually be
picked without fetching anything else. Guide pages are listed without descriptions.

For bulk reading, `llms-components.txt`, `llms-theming.txt`, and `llms-migrations.txt` hold
those sections in full. `llms-full.txt` holds everything and is large enough (~1.2 MB) that
it is rarely the right choice.

Tiers 2 and 3 always describe the latest release, while tier 1 matches the installed
version. Where they disagree about an argument, tier 1 wins.

## The four things most likely to go wrong

Detail for each is in the reference files below.

1. **There is no numbered color scale.** `bg-primary-500` does not exist. Colors are
   semantic categories with named levels: `bg-primary-firm`, `text-on-primary-firm`.
2. **`eq` is not importable from `@ember/helper`.** Reaching for it is a compile error.
3. **Tailwind skips `node_modules`.** Without the `@source` directives in the app's
   stylesheet, every Frontile class is purged and components render unstyled with no error
   anywhere. If components look unstyled, check this before anything else.
4. **`@color` and `@variant` are the current styling arguments.** The pre-0.18 `@intent` and
   `@appearance` still resolve, so older examples and nearby call sites are not evidence that
   a spelling is current. See `references/api-naming.md` when upgrading or when one appears.

## References

Load only what the task needs.

| Task                                                   | Read                                                 |
| ------------------------------------------------------ | ---------------------------------------------------- |
| Writing or editing any `.gts` that renders Frontile    | `references/gts-conventions.md`                      |
| Setting or changing colors, variants, or styling       | `references/colors.md`                               |
| Seeing `@intent`/`@appearance`, or upgrading from 0.17 | `references/api-naming.md`                           |
| Choosing between similar components                    | `references/component-selection.md`                  |
| A component's exact arguments                          | The declarations, tier 1 above, not a reference file |
