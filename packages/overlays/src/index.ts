import { deprecate } from '@ember/debug';

deprecate(
  'Importing from "@frontile/overlays" is deprecated. ' +
    'Import from "frontile" or "frontile/overlays" instead. ' +
    'See https://frontile.dev/docs/migrations/v0.18/package-consolidation',
  false,
  {
    id: 'frontile.import-from-overlays',
    until: '0.19.0',
    for: 'frontile',
    since: { available: '0.18.0', enabled: '0.18.0' },
    url: 'https://frontile.dev/docs/migrations/v0.18/package-consolidation'
  }
);

export * from 'frontile/overlays';
