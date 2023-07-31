module.exports = {
  root: true,
  plugins: [],
  extends: ['@underline/eslint-config-ember-typescript'],
  rules: {
    '@typescript-eslint/no-empty-interface': 'off',
    'ember/no-empty-glimmer-component-classes': 'off'
  },
  overrides: [
    {
      files: ['packages/**/tests/**/*.ts'],
      rules: {
        '@typescript-eslint/explicit-function-return-type': 'off',
        '@typescript-eslint/no-non-null-assertion': 'off'
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
        'site/lib/docfy-theme/*.js',
        'test-app/ember-cli-build.js',
        'test-app/testem.js',
        'test-app/config/**/*.js',
        'test-app/tests/dummy/config/**/*.js',
        'test-app/**/tailwind.config.js',
        'test-app/.docfy-config.js',
        'test-app/lib/docfy-theme/*.js'
      ],
      extends: ['@underline/eslint-config-node'],
      rules: {}
    }
  ]
};
