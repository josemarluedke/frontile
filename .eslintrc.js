module.exports = {
  root: true,
  extends: [
    '@underline/eslint-config-ember-typescript',

    'plugin:ember/recommended'
  ],
  rules: {
    '@typescript-eslint/no-empty-interface': 'off',
    '@typescript-eslint/no-empty-object-type': 'off',
    '@typescript-eslint/no-unused-expressions': 'off',
    '@typescript-eslint/no-unused-vars': 'off',
    'ember/no-empty-glimmer-component-classes': 'off',
    'ember/no-runloop': 'off',
    'node/no-missing-require': 'off',
    'node/no-missing-import': 'off',
    'node/no-unpublished-import': 'off',
    'node/no-unsupported-features/es-syntax': 'off'
  },
  overrides: [
    {
      files: ['packages/**/tests/**/*.ts', '**/*.gts'],
      rules: {
        '@typescript-eslint/explicit-function-return-type': 'off',
        '@typescript-eslint/no-non-null-assertion': 'off',
        '@typescript-eslint/no-useless-constructor': 'off',
        'lines-between-class-members': 'off'
      }
    },

    // node files
    {
      files: [
        '.eslintrc.js',
        '.prettierrc.js',
        '.template-lintrc.js',
        'testem.js',
        'config/**/*.js',
        'packages/*/babel.config.js',
        'packages/*/addon-main.js',
        'packages/*/.ember-cli.js',
        'packages/*/ember-cli-build.js',
        'packages/*/index.js',
        'packages/*/testem.js',
        'packages/*/blueprints/*/index.js',
        'packages/*/config/**/*.js',
        'packages/*/tests/dummy/config/**/*.js',
        'packages/**/tailwind.config.js',
        'packages/**/tailwind/*.js',
        'packages/tailwindcss-plugin-helpers/**/*.js',
        'site/ember-cli-build.js',
        'site/testem.js',
        'site/config/**/*.js',
        'site/tests/dummy/config/**/*.js',
        'site/**/tailwind.config.js',
        'site/.docfy-config.js',
        'site/lib/*.js',
        'test-app/ember-cli-build.js',
        'test-app/testem.js',
        'test-app/config/**/*.js',
        'test-app/tests/dummy/config/**/*.js',
        'test-app/tailwind.config.js',
        'test-app/.docfy-config.js',
        'test-app/lib/docfy-theme/*.js',
        'test-app/frontile.js',
        'test-app/postcss.config.js'
      ],
      extends: ['@underline/eslint-config-node'],
      rules: {}
    },

    // .mjs files in this repo are all Node config/tooling — rollup, vite,
    // eslint, prettier, docfy, scripts/, site/ssr/ — and none are shipped to a
    // browser. So they need the Node global env (process, __dirname, etc.) and
    // no-console relaxed. This used to enumerate them one by one, which meant
    // every new tooling file failed with confusing `no-undef` on `process`
    // until someone remembered to come back here.
    //
    // Unlike the .js files above, these aren't routed through
    // @underline/eslint-config-node's `plugin:node/recommended`, since that
    // reintroduces import-resolution rules (node/no-missing-import,
    // node/no-unpublished-import) that the root config deliberately disables.
    {
      files: ['**/*.mjs'],
      env: {
        node: true
      },
      rules: {
        'no-console': 'off'
      }
    }
  ]
};
