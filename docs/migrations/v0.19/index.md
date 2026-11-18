---
title: Upgrading to v0.19
order: 1
category: migrations
subcategory: v0.19
---

# Upgrading to v0.19

v0.19 removes what v0.18 deprecated. It introduces nothing new to migrate to:
every replacement already exists in 0.18.x, and the v0.18 guides below hold
the actual mappings.

## The short version

1. Upgrade to the latest 0.18.x.
2. Run your app and your test suite, and fix every Frontile deprecation
   warning. Each one names its replacement.
3. Upgrade to v0.19.
4. Run your test suite again, in a development build. Any removed argument you
   missed now fails an assertion that names the replacement.

Step 4 matters because production builds strip those assertions. A removed
argument that reaches production is silently ignored. The
[v0.19 release notes](../../releases/v0.19.md#what-breaks-and-how-loudly) list
what each one falls back to, including the two that change behavior:
`FormFeedback @intent` and the notifications `appearance` option.

## Checklist

- [ ] Imports moved from `@frontile/*` packages to `frontile`
      ([Package Consolidation](../v0.18/package-consolidation.md))
- [ ] Off `@frontile/forms-legacy` ([Forms Legacy](../v0.18/forms-legacy.md))
- [ ] Off `@frontile/changeset-form` ([Changeset Form](../v0.18/changeset-form.md))
- [ ] No `@appearance`/`@intent` on components, no `@radius` on Chip, no
      `@onClick` on CloseButton
      ([Component API Naming](../v0.18/component-api-naming.md))
- [ ] Notifications use `status`, not `appearance`, in `add()` calls and in
      `config/environment.js`
- [ ] No imports of `FrontileStickyOptions` or the `@frontile/theme`
      `forms-legacy` recipes
- [ ] Any Modal, Drawer, Popover or other overlay used from a `.hbs` template is
      re-exported from your app or moved to `.gts`
      ([release notes](../../releases/v0.19.md#hbs-templates))
- [ ] `@frontile/*` packages other than `@frontile/theme` removed from
      `package.json`
- [ ] Test suite run in a development build, with no failed assertions
