import Route from '@ember/routing/route';
import { inject as service } from '@ember/service';
import RouterService from '@ember/routing/router-service';

export default class IndexRoute extends Route {
  @service router!: RouterService;

  redirect(): void {
    this.router.replaceWith('docs');
  }
}
