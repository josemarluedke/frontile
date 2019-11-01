module.exports = {
  root: true,
  parser: 'babel-eslint',
  parserOptions: {
    ecmaVersion: 2018,
    sourceType: 'module'
  },
  plugins: [
    'ember'
  ],
  extends: [
    'eslint:recommended',
    'plugin:ember/recommended'
  ],
  env: {
    browser: true
  },
  rules: {
  },
  overrides: [
    // node files
    {
      files: [
        '.eslintrc.js',
        '.template-lintrc.js',
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
      parserOptions: {
        sourceType: 'script',
        ecmaVersion: 2015
      },
      env: {
        browser: false,
        node: true
      },
      plugins: ['node'],
      rules: Object.assign({}, require('eslint-plugin-node').configs.recommended.rules, {
        // add your custom rules and overrides for node files here
      })
    }
  ]
};
