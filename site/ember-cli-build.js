'use strict';
// Enable FastBoot Rehydration
process.env.EXPERIMENTAL_RENDER_MODE_SERIALIZE = true;

const EmberApp = require('ember-cli/lib/broccoli/ember-app');
const path = require('path');

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

module.exports = function (defaults) {
  const app = new EmberApp(defaults, {
    prember: {
      urls: ['/']
    },
    fastboot: {
      hostWhitelist: [/^localhost:\d+$/]
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
