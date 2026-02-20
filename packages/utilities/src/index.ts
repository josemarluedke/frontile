import { deprecate } from '@ember/debug';

deprecate(
  'Importing from "@frontile/utilities" is deprecated. ' +
  'Import from "frontile" or "frontile/utilities" instead. ' +
  'See https://frontile.dev/docs/migrations/package-consolidation',
  false,
  {
    id: 'frontile.import-from-utilities',
    until: '0.19.0',
    for: 'frontile',
    since: { available: '0.18.0', enabled: '0.18.0' },
    url: 'https://frontile.dev/docs/migrations/package-consolidation'
  }
);

export * from 'frontile/utilities';
