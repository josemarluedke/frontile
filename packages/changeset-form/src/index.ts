import { deprecate } from '@ember/debug';

deprecate(
  'The "@frontile/changeset-form" package is deprecated and will be removed in 0.19.0. ' +
    'Migrate to the modern "frontile" forms instead. ' +
    'See https://frontile.dev/docs/migrations/changeset-form',
  false,
  {
    id: 'frontile.changeset-form',
    until: '0.19.0',
    for: 'frontile',
    since: { available: '0.18.0', enabled: '0.18.0' },
    url: 'https://frontile.dev/docs/migrations/changeset-form'
  }
);

export * from './components/changeset-form';
