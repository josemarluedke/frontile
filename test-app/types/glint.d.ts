import '@glint/environment-ember-loose';
import '@glint/environment-ember-template-imports';

import type FrontileCore from '@frontile/core/template-registry';
import type FrontileButtons from '@frontile/buttons/template-registry';
import type FrontileForms from '@frontile/forms/template-registry';
import type FrontileChangesetForm from '@frontile/changeset-form/template-registry';
import type FrontileOverlays from '@frontile/overlays/template-registry';
import type FrontileNotifications from '@frontile/notifications/template-registry';

declare module '@glint/environment-ember-loose/registry' {
  export default interface Registry
    extends FrontileCore,
      FrontileButtons,
      FrontileForms,
      FrontileChangesetForm,
      FrontileOverlays,
      FrontileNotifications {
    /* your local loose-mode entries here */
  }
}
