'use strict';

module.exports = {
  name: require('./package').name,
  included(...args) {
    this._super.included.apply(this, args);

    this.import('node_modules/focus-visible/dist/focus-visible.js');
  }
};
