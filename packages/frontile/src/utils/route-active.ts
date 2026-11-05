import type RouterService from '@ember/routing/router-service';

export interface RouteActiveArgs {
  /** The route name. Without it nothing is derived from the router. */
  route?: string;
  /** A single dynamic segment for `route`. */
  model?: unknown;
  /** Dynamic segments for `route`. Wins over `model`. */
  models?: unknown[];
  /** Query params for `route`. */
  query?: Record<string, unknown>;
  /** Explicit override. Always wins over anything derived from the router. */
  isActive?: boolean;
}

/**
 * Normalizes the dynamic segments and query params given to a route link.
 */
export function normalizeRouteArgs(
  args: Pick<RouteActiveArgs, 'model' | 'models' | 'query'>
): { models: unknown[]; query: Record<string, unknown> } {
  return {
    // `!= null` (not truthiness) so a legitimate falsy dynamic segment --
    // `model={{0}}` or `model=""` -- is not silently dropped.
    models: args.models ?? (args.model != null ? [args.model] : []),
    // `LinkTo`'s `@query` throws when given `undefined` rather than treating it
    // as "no query params" -- so this must default to an empty object.
    query: args.query ?? {}
  };
}

/**
 * Whether a route link is active. An explicit `isActive` wins; without a
 * `route` the answer is `false`; otherwise the router decides.
 */
export function isRouteActive(
  router: RouterService,
  args: RouteActiveArgs
): boolean {
  if (args.isActive !== undefined) {
    return args.isActive;
  }
  if (!args.route) {
    return false;
  }

  // Redundant belt-and-braces: `RouterService#isActive` already entangles
  // itself with `currentURL`'s tag internally (see
  // `consumeTag(tagFor(this._router, 'currentURL'))` in ember-source's
  // `router-service.js`), so a caller recomputes on every transition even
  // without the read below. Kept anyway as a documented, version-independent
  // guarantee -- and covered by the transition test in
  // `tab-nav-routing-test.gts` -- in case that internal entanglement is ever
  // dropped.
  void router.currentURL;

  const { models, query } = normalizeRouteArgs(args);

  try {
    return router.isActive(args.route, ...models, {
      queryParams: query
    } as never);
  } catch {
    // `isActive` throws for a route that is not currently reachable -- an
    // unentered engine, or a dynamic segment whose model is not loaded. Not
    // being reachable is not being active.
    return false;
  }
}

/**
 * `isRouteActive` for a router that is resolved lazily. `getRouter` runs only
 * when the router is actually needed -- `route` given and `isActive` not -- so
 * a link that never routes never touches `service:router`. Shared by
 * `NavLink` and the handle `NavItem` registers with a folder, so both always
 * agree on what is active.
 */
export function isLinkActive(
  args: RouteActiveArgs,
  getRouter: () => RouterService
): boolean {
  if (args.isActive !== undefined) {
    return args.isActive;
  }
  if (!args.route) {
    return false;
  }

  return isRouteActive(getRouter(), args);
}
