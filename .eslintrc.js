module.exports = {
  root: true,
  parserOptions: {
    project: './tsconfig.eslint.json'
  },
  plugins: [],
  extends: ['@neighborly/eslint-config-ember-typescript'],
  rules: {
    '@typescript-eslint/no-empty-interface': 'off'
  },
  overrides: [
    // node files
    {
      files: [
        '.eslintrc.js',
        '.prettierrc.js',
        '.template-lintrc.js',
        'testem.js',
        'config/**/*.js',
        'packages/*/.ember-cli.js',
        'packages/*/ember-cli-build.js',
        'packages/*/index.js',
        'packages/*/testem.js',
        'packages/*/blueprints/*/index.js',
        'packages/*/config/**/*.js',
        'packages/*/tests/dummy/config/**/*.js'
      ],
      excludedFiles: [
        'packages/*/addon/**',
        'packages/*/addon-test-support/**',
        'packages/*/app/**',
        'packages/*/tests/dummy/app/**'
      ],
      extends: ['@neighborly/eslint-config-node'],
      rules: {}
    }
  ]
};
