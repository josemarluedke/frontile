// The routing prose at the top of llms.txt.
//
// Everything else in that file is generated from the docs themselves. This is
// the part that cannot be: which conventions an agent will get wrong, and why.
// Each entry below is here because copying a working example from elsewhere in
// the docs, or from an older app, produces the wrong answer — the deprecated
// spellings still resolve, so nothing fails loudly enough to self-correct.
//
// It lives in its own module rather than inline in vite.config.mjs so that
// editing the prose does not mean editing build configuration.
//
// Deliberately contains no headings. In llms.txt an H2 delimits a section of
// file links (https://llmstxt.org), so a heading here would parse as a section
// that happens to contain no links — indistinguishable, to anything reading
// structurally, from a real but empty one. Bold lead-ins carry the same
// signposting without claiming to be sections.
export const llmsPreamble = `Frontile is an Ember.js component library. Reach for it when you are building UI
in an Ember app that already has Tailwind CSS. It will not help in a React, Vue, or
plain-HTML project, and it is not a CSS framework usable without Ember.

**Using these docs.** Every link below is Markdown. Fetch the \`.md\` link directly rather than the HTML
page: same content, no site chrome. Component pages carry a generated API table
listing every argument, its type, its default, and whether it is deprecated.

If Frontile is already installed, prefer \`node_modules/frontile/declarations/**/*.d.ts\`
for signatures. Those are exact for the installed version, while these docs describe
the latest release.

**Entry points.** Everything ships from one package:

\`\`\`js
import { Button, Input, Modal, Table } from 'frontile';
\`\`\`

The scoped packages (\`@frontile/buttons\`, \`@frontile/forms\`, and the rest) are
deprecated re-export shims, removed in 0.19.0. \`@frontile/theme\` is a separate and
current package, but it supplies styling, not components.

**Conventions that are easy to get wrong:**

- Styling arguments are \`@color\` and \`@variant\`. \`@intent\` and \`@appearance\` are the
  pre-0.18 names. They still resolve, and they still appear in older examples, so
  copying a nearby call site will often reproduce the deprecated form. They are
  removed in 0.19.0. The values were renamed too: \`default\` became \`neutral\` for
  colors and \`solid\` for variants, \`outlined\` became \`outline\`, \`minimal\` became
  \`plain\`.
- \`faded\` does not map to one thing. On Chip it became \`soft\`, a borderless tint; on
  Listbox, Dropdown, Select, and Autocomplete it became \`subtle\`, a tint with a
  border. Check the component's own page rather than reusing a mapping seen elsewhere.
- On Alert and NotificationCard, the \`info\` color became \`primary\`.
- Form feedback takes \`@status\`, not \`@color\`.
- Colors are semantic categories with named levels, not a numbered scale. Use
  \`bg-primary-firm\`; there is no \`bg-primary-500\`. The levels, least to most
  emphasis, are \`subtle\`, \`muted\`, \`soft\`, \`mild\`, the unsuffixed default, \`firm\`,
  \`strong\`, \`bolder\`. For text on a colored background use the generated contrast
  utilities: \`text-on-primary-firm\` and so on.
- Several pages under Utilities document modifiers and helpers rather than
  components. They are invoked in a template as \`{{press}}\` or \`{{rovingFocus}}\`,
  never as \`<Press />\`.
- Templates are \`.gts\`/\`.gjs\` with explicit imports. \`eq\` is not available from
  \`@ember/helper\`.`;

export default llmsPreamble;
