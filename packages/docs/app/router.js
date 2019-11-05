import AddonDocsRouter, { docsRoute } from 'ember-cli-addon-docs/router';
import config from './config/environment';

export default class Router extends AddonDocsRouter {
  location = config.locationType;
  rootURL = config.rootURL;
}

Router.map(function() {
  docsRoute(this, function() {
    this.route('forms', function() {
      this.route('input-text');
    });
  });

  this.route('not-found', { path: '/*path' });
});
