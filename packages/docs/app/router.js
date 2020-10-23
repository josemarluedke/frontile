import AddonDocsRouter, { docsRoute } from 'ember-cli-addon-docs/router';
import config from 'docs/config/environment';

export default class Router extends AddonDocsRouter {
  location = config.locationType;
  rootURL = config.rootURL;
}

Router.map(function () {
  docsRoute(this, function () {
    this.route('core', function () {
      this.route('accessibility', function () {
        this.route('focus-management');
        this.route('visually-hidden');
      });
      this.route('close-button');
    });

    this.route('forms', function () {
      this.route('form-input');
      this.route('form-textarea');
      this.route('form-select');
      this.route('form-radio');
      this.route('form-radio-group');
      this.route('form-checkbox');
      this.route('form-checkbox-group');
    });

    this.route('changeset-form', function () {
      this.route('usage');
    });

    this.route('buttons', function () {
      this.route('button');
    });
    this.route('notifications', function () {
      this.route('usage');
    });
    this.route('overlays', function () {
      this.route('usage');
    });
  });

  this.route('not-found', { path: '/*path' });
});
