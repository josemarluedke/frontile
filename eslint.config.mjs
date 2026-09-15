/**
 * Debugging:
 *   https://eslint.org/docs/latest/use/configure/debug
 *  ----------------------------------------------------
 *
 *   Print a file's calculated configuration
 *
 *     npx eslint --print-config path/to/file.js
 *
 *   Inspecting the config
 *
 *     npx eslint --inspect-config
 *
 */
import globals from 'globals';
import js from '@eslint/js';

import ts from 'typescript-eslint';

import ember from 'eslint-plugin-ember/recommended';
import prettier from 'eslint-plugin-prettier/recommended';
import qunit from 'eslint-plugin-qunit';
import n from 'eslint-plugin-n';

const esmParserOptions = {
  ecmaFeatures: { modules: true },
  ecmaVersion: 'latest'
};

export default ts.config(
  js.configs.recommended,
  prettier,
  ember.configs.base,
  ember.configs.gjs,
  ember.configs.gts,
  /**
   * Ignores must be in their own object
   * https://eslint.org/docs/latest/use/configure/ignore
   */
  {
    ignores: [
      '**/dist/**',
      '**/declarations/**',
      '**/node_modules/**',
      '**/coverage/**',
      '**/tmp/**',
      'site/dist-ssr/**',
      // Docfy generates every page under here at build time from the
      // component .md files; the .gitignore already excludes it as build
      // output. Its .gjs/.gts output can be enormous (a whole rendered doc
      // page inlined as a template), and running prettier/prettier (which
      // shells out to prettier per file) against that is exorbitantly slow.
      'site/app/templates/docs/**',
      '!**/.*'
    ]
  },
  /**
   * https://eslint.org/docs/latest/use/configure/configuration-files#configuring-linter-options
   */
  {
    linterOptions: {
      reportUnusedDisableDirectives: 'error'
    }
  },
  {
    rules: {
      'no-console': ['error', { allow: ['error', 'warn', 'info'] }],
      'lines-between-class-members': [
        'error',
        'always',
        { exceptAfterSingleLine: true }
      ]
    }
  },
  {
    files: ['**/*.{js,gjs}'],
    languageOptions: {
      parserOptions: esmParserOptions,
      globals: {
        ...globals.browser
      }
    }
  },
  {
    files: ['**/*.{ts,gts}'],
    languageOptions: {
      parser: ember.parser,
      parserOptions: esmParserOptions
    },
    extends: [...ts.configs.recommended, ember.configs.gts],
    rules: {
      '@typescript-eslint/no-empty-interface': 'off',
      '@typescript-eslint/no-empty-object-type': 'off',
      '@typescript-eslint/no-unused-expressions': 'off',
      '@typescript-eslint/no-unused-vars': [
        'error',
        {
          ignoreRestSiblings: true,
          argsIgnorePattern: '^_',
          caughtErrors: 'all'
        }
      ],
      '@typescript-eslint/no-non-null-assertion': 'error',
      '@typescript-eslint/explicit-function-return-type': 'warn',
      '@typescript-eslint/ban-ts-comment': 'warn',
      '@typescript-eslint/array-type': 'warn',
      '@typescript-eslint/no-extraneous-class': 'warn',
      '@typescript-eslint/no-require-imports': 'warn',
      '@typescript-eslint/no-this-alias': 'warn',
      '@typescript-eslint/prefer-function-type': 'warn'
    }
  },
  /**
   * Test files (unit/integration tests across packages/*, test-app, site):
   * return types and non-null assertions are noise here, and the
   * `lines-between-class-members` prettier-adjacent rule fights with how
   * qunit modules are commonly laid out.
   */
  {
    files: ['**/tests/**/*.ts', '**/*.gts'],
    rules: {
      '@typescript-eslint/explicit-function-return-type': 'off',
      '@typescript-eslint/no-non-null-assertion': 'off',
      '@typescript-eslint/no-useless-constructor': 'off',
      'lines-between-class-members': 'off'
    }
  },
  {
    files: ['**/tests/**/*-test.{js,gjs,ts,gts}'],
    plugins: {
      qunit
    }
  },
  /**
   * CJS node files
   */
  {
    files: [
      '.prettierrc.js',
      '.template-lintrc.js',
      'testem.js',
      '**/testem.js',
      '**/testem.cjs',
      '**/*.cjs',
      'config/**/*.js',
      'scripts/**/*.js',
      'packages/*/babel.config.js',
      'packages/*/addon-main.js',
      'packages/*/.ember-cli.js',
      'packages/*/ember-cli-build.js',
      'packages/*/index.js',
      'packages/*/blueprints/*/index.js',
      'packages/*/config/**/*.js',
      'packages/**/tailwind.config.js',
      'packages/**/tailwind/*.js',
      'packages/tailwindcss-plugin-helpers/**/*.js',
      'site/config/**/*.js',
      'site/**/tailwind.config.js',
      'site/.docfy-config.js',
      'site/lib/*.js',
      'site/ember-cli-build.js',
      'test-app/config/**/*.js',
      'test-app/tailwind.config.js',
      'test-app/.docfy-config.js',
      'test-app/frontile.js',
      'test-app/ember-cli-build.js'
    ],
    plugins: {
      n
    },
    languageOptions: {
      sourceType: 'script',
      ecmaVersion: 'latest',
      globals: {
        ...globals.node
      }
    }
  },
  /**
   * ESM node files. None of these are shipped to a browser: rollup, vite,
   * eslint, prettier, docfy, scripts/, site/ssr/. So they need the Node
   * global env (process, __dirname, etc.) and no-console relaxed.
   */
  {
    files: ['**/*.mjs'],
    plugins: {
      n
    },
    languageOptions: {
      sourceType: 'module',
      ecmaVersion: 'latest',
      parserOptions: esmParserOptions,
      globals: {
        ...globals.node
      }
    },
    rules: {
      'no-console': 'off'
    }
  },
  /**
   * Repo-wide relaxations. Positioned last so they win over the rules
   * `ember.configs.gts`/`ember.configs.base` apply above -- flat config
   * merges by array order, and those presets are extended earlier, above.
   */
  {
    rules: {
      'ember/no-empty-glimmer-component-classes': 'off',
      'ember/no-runloop': 'off'
    }
  }
);
