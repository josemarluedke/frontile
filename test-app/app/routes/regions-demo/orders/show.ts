import Route from '@ember/routing/route';

export default class RegionsDemoOrdersShowRoute extends Route {
  model(params: { order_id: string }): { order_id: string } {
    return params;
  }
}
