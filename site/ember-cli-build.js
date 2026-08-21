'use strict';

const EmberApp = require('ember-cli/lib/broccoli/ember-app');
const { compatBuild } = require('@embroider/compat');

module.exports = async function (defaults) {
  const { buildOnce } = await import('@embroider/vite');
  let app = new EmberApp(defaults, {
    // Add options here
  });

  return compatBuild(app, buildOnce, {
    // Each of these becomes its own lazily loaded bundle. app/router.ts
    // extends @embroider/router, which is what performs the lazy load at
    // transition time.
    //
    // Everything Docfy generates lives under app/templates/docs/**, so the
    // whole documentation site — every demo, every component it imports, and
    // the 600 kB signature-data table behind the API tables — stays out of the
    // bundle the homepage needs.
    splitAtRoutes: [
      'docs',
      'docs.get-started',
      'docs.theming',
      'docs.accessibility',
      'docs.migrations',
      'docs.components',
      'docs.components.buttons',
      'docs.components.collections',
      'docs.components.forms',
      'docs.components.forms-legacy',
      'docs.components.notifications',
      'docs.components.overlays',
      'docs.components.status',
      'docs.components.utilities',
    ],
  });
};
