'use strict';

const EmberApp = require('ember-cli/lib/broccoli/ember-app');

module.exports = function (defaults) {
  const app = new EmberApp(defaults, {
    'ember-cli-babel': {
      enableTypeScriptTransform: true
    },
    autoImport: {
      watchDependencies: [
        '@frontile/buttons',
        '@frontile/theme',
        '@frontile/utilities',
        '@frontile/notifications',
        '@frontile/overlays',
        '@frontile/forms',
        '@frontile/changeset-form',
        ['@frontile/forms', '@frontile/changeset-form']
      ]
    },
  });

  /*
  This build file specifies the options for the dummy test app of this
  addon, located in `/tests/dummy`
  This build file does *not* influence how the addon or the app using it
  behave. You most likely want to be modifying `./index.js` or app's build file
*/

  const { maybeEmbroider } = require('@embroider/test-setup');
  return maybeEmbroider(app, {
    packagerOptions: {
      webpackConfig: {
        module: {
          rules: [
            {
              test: /\.css$/i,
              use: [
                {
                  loader: 'postcss-loader',
                  options: {
                    postcssOptions: {
                      config: 'postcss.config.js'
                    }
                  }
                }
              ]
            }
          ]
        }
      }
    },
    // staticAddonTestSupportTrees: true,
    // staticAddonTrees: true,
    // // staticInvokables: true,
    // staticEmberSource: true
    // splitAtRoutes: ['route.name'], // can also be a RegExp
  });
};
