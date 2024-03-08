/* eslint-disable @typescript-eslint/no-empty-function */

import EmberRouter from '@ember/routing/router';
import config from 'test-app/config/environment';

export default class Router extends EmberRouter {
  location = config.locationType;
  rootURL = config.rootURL;
}

Router.map(function () {
  this.route('buttons');
  this.route('changeset-form');
  this.route('core');
  this.route('forms', function () {
    this.route('style-variants');
  });
  this.route('forms-legacy', function () {
    this.route('style-variants');
  });
  this.route('notifications');
  this.route('overlays');
});
