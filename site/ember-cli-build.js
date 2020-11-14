'use strict';

// Enable FastBoot Rehydration
process.env.EXPERIMENTAL_RENDER_MODE_SERIALIZE = true;

const EmberApp = require('ember-cli/lib/broccoli/ember-app');
const path = require('path');
const env = EmberApp.env();

const purgecssOptions = {
  content: [
    './app/index.html',
    './app/**/*.hbs',
    '../**/*.md',
    './node_modules/**/*.hbs',
    '../node_modules/**/*.hbs'
  ],
  defaultExtractor: (content) => {
    // Capture as liberally as possible, including things like `h-(screen-1.5)`
    const broadMatches = content.match(/[^<>"'`\s]*[^<>"'`\s:]/g) || [];

    // Capture classes within other delimiters like .block(class="w-1/2") in Pug
    const innerMatches = content.match(/[^<>"'`\s.()]*[^<>"'`\s.():]/g) || [];

    return broadMatches.concat(innerMatches);
  },
  whitelistPatterns: [
    /js-/,
    /mode-dark/,
    /^close-button/,
    /^visually-hidden/,
    /^form-field-checkbox/,
    /^form-field-feedback/,
    /^form-field-hint/,
    /^form-field-input/,
    /^form-field-label/,
    /^form-field-radio/,
    /^form-field-textarea/,
    /^form-input/,
    /^form-textarea/,
    /^form-select/,
    /^form-checkbox/,
    /^form-radio/,
    /^form-checkbox-group/,
    /^form-radio-group/,
    /^notifications-container/,
    /^notification-card/,
    /^notification-transition/,
    /^overlay/,
    /^modal/,
    /^drawer/,
    /^btn/
  ]
};

const postcssPlugins = [
  {
    module: require('postcss-import'),
    options: {
      path: [path.join(__dirname, '../node_modules')]
    }
  },
  require('tailwindcss')(path.join('app', 'config', 'tailwind.config.js')),
  require('postcss-nested'),
  require('autoprefixer')
];
if (env !== 'development' || process.env.PURGE_CSS === 'true') {
  const purgecss = require('@fullhuman/postcss-purgecss')(purgecssOptions);
  postcssPlugins.push(purgecss);
}

module.exports = function (defaults) {
  const app = new EmberApp(defaults, {
    prember: {
      urls: ['/']
    },
    postcssOptions: {
      compile: {
        enabled: true,
        cacheInclude: [/.*\.css$/, /.tailwind\.config\.js$/],
        plugins: postcssPlugins
      }
    }
  });

  return app.toTree();
};
