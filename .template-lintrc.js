'use strict';

module.exports = {
  extends: ['recommended'],
  // `frontile/require-data-part` implements this repo's DOM anatomy
  // invariant (see .superpowers/sdd/2026-09-10-component-anatomy-attributes)
  // -- a Node/ESM plugin, loaded via dynamic `import()` by ember-template-lint
  // even though this config file itself is CommonJS.
  plugins: ['./lint/frontile-template-lint-plugin.mjs'],
  rules: {
    'frontile/require-data-part': true,
    'frontile/require-root-data-component': true,
    // Only the html half. Every template in this repo lives in a .gts/.gjs
    // template tag (there are no .hbs files), so prettier, via
    // prettier-plugin-ember-template-tag, already formats all of them: it
    // quotes HTML attributes with double quotes and string literals inside
    // mustaches with single quotes. Plain `quotes: 'double'` also demands
    // double quotes inside mustaches, which prettier/prettier then reports as
    // an error and rewrites back, so `pnpm lint:hbs --fix` and
    // `pnpm lint:js --fix` would rewrite the same files forever.
    //
    // The curlies half is not merely noisy, it is lossy: to change a quote the
    // fixer reprints the surrounding attribute through ember-template-recast,
    // which drops whitespace-only text nodes between mustaches. That silently
    // turned `aria-describedby="{{a}} {{b}}"` into `"{{a}}{{b}}"` in
    // forms-legacy/src/components/form-select.gts, joining id lists and class
    // lists into single run-together tokens.
    //
    // Note that the `templateSingleQuote: false` override in .prettierrc.js
    // does not currently take effect (its `*.{js,ts,gjs,gts}` glob has no
    // `**/` and so matches nothing), and it would not help if it did: it
    // flips both halves, giving single-quoted HTML attributes and
    // double-quoted mustache literals.
    quotes: { curlies: false, html: 'double' },
    'eol-last': false,
    'no-builtin-form-components': false,
    'no-unknown-arguments-for-builtin-components': false,
    'require-input-label': false,
    'no-positive-tabindex': false,
    'table-groups': false
  },
  overrides: [
    {
      // forms-legacy is excluded from the whole anatomy-attributes plan
      // (see the project CLAUDE.md): it is not being migrated, so its
      // templates carry no data-component/data-part and never will.
      files: ['packages/forms-legacy/**'],
      rules: {
        'frontile/require-data-part': false,
        'frontile/require-root-data-component': false
      }
    }
  ]
};
