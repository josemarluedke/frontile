import '@glint/environment-ember-loose';
import '@glint/environment-ember-template-imports';

import type FrontileRegistry from 'frontile/template-registry';
import type FrontileChangesetForm from '@frontile/changeset-form/template-registry';

declare module '@glint/environment-ember-loose/registry' {
  export default interface Registry
    extends FrontileRegistry,
      FrontileChangesetForm {
    /* your local loose-mode entries here */
  }
}
