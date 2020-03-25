'use strict';

const EmberApp = require('ember-cli/lib/broccoli/ember-app');
const path = require('path');

module.exports = function(defaults) {
  const app = new EmberApp(defaults, {
    'ember-cli-addon-docs': {
      documentingAddonAt: '../forms'
    },
    postcssOptions: {
      compile: {
        enabled: true,
        cacheInclude: [/.*\.css$/, /.tailwind\.config\.js$/],
        plugins: [
          require('tailwindcss')(
            path.join('app', 'styles', 'tailwind.config.js')
          ),
          require('autoprefixer')
        ]
      }
    }
  });

  // Make sure to include ember-basic-dropdown styles
  // Ember Basic Dropdown does not include the styles of sass or less is
  // present in the project and ember-cli-addon-docs has sass as a dependency
  app.import(
    'node_modules/ember-basic-dropdown/vendor/ember-basic-dropdown.css'
  );

  // Use `app.import` to add additional libraries to the generated
  // output files.
  //
  // If you need to use different assets in different
  // environments, specify an object as the first parameter. That
  // object's keys should be the environment name and the values
  // should be the asset to use in that environment.
  //
  // If the library that you are including contains AMD or ES6
  // modules that you would like to import into your application
  // please specify an object with the list of modules as keys
  // along with the exports of each module as its value.

  return app.toTree();
};
