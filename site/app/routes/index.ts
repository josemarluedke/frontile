import Route from '@ember/routing/route';
import { service } from '@ember/service';
import RouterService from '@ember/routing/router-service';
import * as buttons from 'frontile';
import * as utilities from 'frontile';
import * as collections from 'frontile';
import * as status from 'frontile';
import * as overlays from 'frontile';
import * as forms from 'frontile';

export default class IndexRoute extends Route {
  @service router!: RouterService;

  redirect(): void {
    this.router.replaceWith('docs');
  }

  // Embroider's tree shaking is removing pkg main entry point as was not used,
  // but it is used in template imports
  something(): object {
    return {
      buttons,
      utilities,
      collections,
      status,
      overlays,
      forms,
    };
  }
}
