'use strict';

const getChannelURL = require('ember-source-channel-url');
const { embroiderSafe, embroiderOptimized } = require('@embroider/test-setup');

module.exports = async function () {
  return {
    useYarn: true,
    scenarios: [
      {
        name: 'ember-lts-4.12',
        npm: {
          devDependencies: {
            'ember-source': '~4.12.1',
            '@types/ember-qunit': '^6.1.1',
            '@types/ember-resolver': '^9.0.0',
            '@types/ember__application': '^4.0.6',
            '@types/ember__array': '^4.0.4',
            '@types/ember__component': '^4.0.14',
            '@types/ember__debug': '^4.0.4',
            '@types/ember__error': '^4.0.3',
            '@types/ember__object': '^4.0.6',
            '@types/ember__routing': '^4.0.13',
            '@types/ember__runloop': '^4.0.4',
            '@types/ember__service': '^4.0.3',
            '@types/ember__string': '^3.0.11',
            '@types/ember__template': '^4.0.2',
            '@types/ember__test': '^4.0.2',
            '@types/ember__test-helpers': '^2.9.1'
          }
        }
      },
      {
        name: 'ember-release',
        npm: {
          devDependencies: {
            'ember-source': await getChannelURL('release')
          }
        }
      },
      {
        name: 'ember-beta',
        npm: {
          devDependencies: {
            'ember-source': await getChannelURL('beta')
          }
        }
      },
      {
        name: 'ember-canary',
        npm: {
          devDependencies: {
            'ember-source': await getChannelURL('canary')
          }
        }
      },
      embroiderSafe(),
      embroiderOptimized()
    ]
  };
};
