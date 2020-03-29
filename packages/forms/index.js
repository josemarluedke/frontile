'use strict';

module.exports = {
  name: require('./package').name,
  options: {
    'ember-power-select': {
      theme: false
    }
  },

  included(includer, ...rest) {
    const powerSelectOptions = includer.options['ember-power-select'] || {};
    powerSelectOptions.theme = false;
    includer.options['ember-power-select'] = powerSelectOptions;

    this._super.included.apply(this, [includer, ...rest]);
  },

  // Ember does not call contentFor on nested addons, so we must call it
  // manually.
  contentFor(type, config) {
    const emberPowerSelect = this.addons.find(
      (a) => a.name === 'ember-power-select'
    );
    return emberPowerSelect.contentFor(type, config);
  }
};
