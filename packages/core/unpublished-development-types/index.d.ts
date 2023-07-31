// Add any types here that you need for local development only.
// These will *not* be published as part of your addon, so be careful that your published code does not rely on them!

import 'ember-source/types';
import '@glint/environment-ember-template-imports';
import type RenderModifiersRegistry from '@ember/render-modifiers/template-registry';
import type CoreRegistry from '../src/template-registry.ts';

declare module '@glint/environment-ember-loose/registry' {
  export default interface Registry
    extends RenderModifiersRegistry,
      CoreRegistry {
    // ...
  }
}
