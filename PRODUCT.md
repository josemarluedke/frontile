# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

Primary: **experienced Ember.js developers who have not used Frontile before.** They already
know Octane, Glimmer components, template-tag (`.gts`/`.gjs`) authoring, and Tailwind. They
arrive at frontile.dev evaluating whether to adopt a component library, and they judge the
API surface and the accessibility claims skeptically. Do not explain Ember to them, do not
explain what a component library is, and do not pad with encouragement.

Also carried by the same surfaces: developers weighing whether the Ember ecosystem has a
credible modern component story at all, existing Frontile users navigating to a specific
component's documentation, and maintainers migrating across the v0.18 breaking changes.

## Product Purpose

Frontile provides the components, helpers, modifiers, and styles needed to build consistent,
accessible Ember.js applications — both low-level primitives and higher-level composed
components.

**The marketing surfaces sell adoption, and the activation event is exploration, not
installation.** A first-time visitor succeeds when they go looking — through the component
range, the theming system, and the docs — because they have decided Frontile is worth
evaluating. Installation is a materially harder sell and a later step; a homepage optimized
for `pnpm install` optimizes for the wrong moment. The homepage's job is to build the case
and then open every door into the library.

Frontile's case also carries a second burden it cannot avoid: for some visitors it is
evidence about whether Ember.js itself still has a credible, modern component story. The
surfaces should make that case confidently rather than defensively.

## Positioning

The combination a neighboring Ember library cannot truthfully claim wholesale:

- **Tailwind Variants as the styling contract**, not CSS-in-JS and not fixed stylesheets —
  every component's classes are overridable per-slot via `@classes`, with class-conflict
  resolution built in.
- **Glint-typed templates**, so component args are checked at build time, including generics
  (`Table<User>`, `Listbox<Country>`) that infer against the consumer's own data types.
- **A semantic color system with named levels** (`subtle`/`muted`/`soft`/`mild`/DEFAULT/
  `firm`/`strong`/`bolder`) rather than a numbered scale, with `on-*` contrast text colors
  generated automatically for WCAG contrast, and light/dark handled by CSS variables.
- **Accessibility treated as a component-level obligation** — WAI-ARIA authoring practices,
  keyboard navigation, and focus management, documented per component.

## Operating Context

- Consumers install `frontile` + `@frontile/theme` via pnpm/npm/yarn and wire the theme into
  a Tailwind **v4** entry stylesheet with `@plugin "@frontile/theme/plugin/default"` and
  `@import "@frontile/theme"`. Tailwind skips `node_modules` when scanning for classes, so
  consumers must add `@source` entries pointing at `frontile` and `@frontile` or their
  classes get purged. This `@source` step is the single most common setup failure and belongs
  anywhere setup is taught.
- Component source is consolidated in `packages/frontile`, grouped by category. The old
  per-feature packages (`buttons`, `collections`, `forms`, `overlays`, `notifications`,
  `status`, `utilities`) are now deprecation wrappers that re-export from `frontile`.
- `@frontile/changeset-form` and `@frontile/forms-legacy` are deprecated and will be removed
  before v1.
- Docs are Docfy-rendered: each component has a co-located `.md` beside its `.gts`, and the
  code fences in those files render as live interactive demos, highlighted through Docfy's
  Shiki pipeline. Guide docs live in `docs/`.
- The docs site (`site/`) consumes Frontile itself, so the homepage is simultaneously
  marketing and the largest integration test of the library's own design system.

## Capabilities and Constraints

- **52 documented components across eight categories:** Forms, Buttons, Collections
  (incl. a sortable/selectable Table, plus Calendar and a Command palette), Overlays,
  Navigation (Tabs, TabNav, Pagination, ExternalLink), Disclosure (Accordion), Feedback
  (Alert, notifications, ProgressBar), and Utilities.
- Requires `ember-source` >= 4.12, modern browsers. Tailwind CSS v4.
- **Pre-1.0 and under active development.** Breaking changes still occur; consumers are told
  to pin versions. The v0.18 line is in **beta** (0.18.0-beta.4 at time of writing) and
  carries migration guides covering the move from the old numbered color scale to named
  levels and the rename of `@intent`/`@appearance` to `@color`/`@variant`.
- All components must support dark mode, and styling must go through Tailwind Variants rather
  than plain CSS.
- Setup taught on marketing surfaces must match the docs: a Tailwind **v4** entry stylesheet
  (`@plugin`, `@import`, `@source`) for wiring, and a CommonJS `frontile.js`
  (`require('@frontile/theme/plugin')` + `module.exports = frontile({...})`) for color
  customization, referenced from the CSS as `@plugin "./frontile.js"`. Colors are configured
  in JavaScript, not in `@theme`. A snippet that shows one half without the other is not
  usable and should not ship.

## Brand Commitments

- Name **Frontile**; the wordmark component in `site/app/components/logo.gts`. Authored and
  maintained by Josemar Luedke. MIT licensed.
- **Typography is fixed by the theme** (the "Beacon" role system) and must be used as given:
  seven roles — `marquee` (Domine, serif, semibold), `header`, `body`, `label`, `caption`
  (all Open Sans), `strong` (Open Sans bold, for numerics), and `code` (Source Code Pro) —
  each on its own steps of a shared 1.067 typescale, applied as `font-<role>` +
  `text-<role>-<size>`.
- **Color must come from the semantic token system** — categories `neutral`, `primary`,
  `secondary`, `tertiary`, `success`, `warning`, `danger`, `surface-*`, at named
  levels, with `on-<category>-<level>` for contrast text. Hardcoded color values on marketing
  surfaces are a defect, not a liberty.
- The site should be built out of Frontile's own components wherever a Frontile component
  exists for the job. Dogfooding is a credibility argument, not a convenience.
- **Icons come from Lucide** via `unplugin-icons`, wrapped in `site/app/components/icons.gts`.
  Frontile itself ships no icon set; hand-rolled SVG paths are not the house style.

## Evidence on Hand

Usable, because it is verifiable in-tree:

- Real, interactive component demos (the library is the site's own dependency).
- Component inventory and counts per category.
- The public repository at `github.com/josemarluedke/frontile`, its CI workflow, and the MIT
  license.
- The actual published version, and the docs' own version switcher.
- Real setup code, taken from `docs/get-started/` so it cannot drift from the truth.
- **A machine-readable documentation layer, shipped in production builds** (not in `vite`
  dev): `llms.txt` and `llms-full.txt` following the llms.txt standard, a plain-Markdown
  mirror of every docs page at `<url>.md`, and a per-page one-click handoff that
  opens the page in ChatGPT or Claude. This is claimable today. An MCP server and agent
  skills are **not** shipped and must not be implied.

**Explicitly absent — must never be fabricated:** adoption or download numbers, GitHub star
counts, named production users, customer logos, testimonials, "trusted by" claims, benchmark
results, community size, or any framing that implies a user base whose size is unknown.
Copy such as "join the growing community of developers" is an unsupported adoption claim and
should not be used.

## Product Principles

1. **Exploration is the conversion.** The homepage wins when the visitor goes deeper — into a
   component, a theme, a doc page. Every element should either build the case for adopting
   Frontile or open a door into it; ideally both. Install instructions are a destination, not
   the hook.
2. **Sell the three things Frontile actually has:** the breadth of the component set, the
   depth of the theming system, and a default theme that is genuinely good in both light and
   dark. These are the assets; lead with them.
3. **Demonstrate, don't assert.** "Accessible" and "type-safe" are claims a skeptical Ember
   developer discounts on sight. Show the keyboard behavior, the ARIA wiring, the real type
   error, and the same components restyled — instead of listing adjectives.
4. **Teach only what is currently true.** Setup and theming code on marketing surfaces must
   match the code the docs ship, because a wrong snippet costs more trust than a missing one.
5. **Dogfood in public.** The site is the proof. Build it from Frontile's components and
   tokens, and let its own quality carry the argument.
6. **Claim nothing about adoption.** No download counts, stars, logos, testimonials, or
   "growing community" framing. Where the marketing surfaces stay quiet about momentum they
   are being accurate, not modest. Pre-1.0 status and migration guidance belong in the docs
   rather than as a pitch on the homepage.

## Accessibility & Inclusion

Accessibility is a product claim here, which raises the bar on Frontile's own surfaces: the
site must not ship a violation that contradicts what it advertises. Concretely — WAI-ARIA
authoring practices, full keyboard operability with visible focus, correct labels and live
regions, `prefers-reduced-motion` respected, and WCAG-contrasting text via the generated
`on-*` colors in both light and dark themes.
