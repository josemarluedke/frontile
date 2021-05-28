'use strict';

const EmberAddon = require('ember-cli/lib/broccoli/ember-addon');
const path = require('path');

module.exports = function (defaults) {
  const app = new EmberAddon(defaults, {
    postcssOptions: {
      compile: {
        enabled: true,
        cacheExclude: [],
        cacheInclude: [],
        // cacheInclude: [/.*\.css$/, /.tailwind\.config\.js$/],
        plugins: [
          require('tailwindcss')(
            path.join('tests', 'dummy', 'app', 'styles', 'tailwind.config.js')
          ),
          require('autoprefixer')
        ]
      }
    }
  });

  app.import(
    'node_modules/ember-basic-dropdown/vendor/ember-basic-dropdown.css'
  );

  /*
    This build file specifies the options for the dummy test app of this
    addon, located in `/tests/dummy`
    This build file does *not* influence how the addon or the app using it
    behave. You most likely want to be modifying `./index.js` or app's build file
  */

  const { maybeEmbroider } = require('@embroider/test-setup');
  return maybeEmbroider(app);
};
