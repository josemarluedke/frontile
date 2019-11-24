import AddonDocsRouter, { docsRoute } from 'ember-cli-addon-docs/router';
import config from './config/environment';

export default class Router extends AddonDocsRouter {
  location = config.locationType;
  rootURL = config.rootURL;
}

Router.map(function() {
  docsRoute(this, function() {
    this.route('forms', function() {
      this.route('form-input');
      this.route('form-textarea');
      this.route('form-radio');
      this.route('input-radio-group');
      this.route('form-checkbox');
      this.route('form-checkbox-group');
    });
  });

  this.route('not-found', { path: '/*path' });
});
