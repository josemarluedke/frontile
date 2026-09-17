export * from './breadcrumbs/breadcrumbs';
export { default } from './breadcrumbs/breadcrumbs';
export * from './breadcrumbs/item';
export * from './breadcrumbs/ellipsis';
export type { BreadcrumbsItemData } from './breadcrumbs/collapse';

// `./breadcrumbs/separator` is deliberately not re-exported. It is the mark
// `Item` and `Ellipsis` share, not a component a consumer composes with: the
// bring-your-own-link path is served by the yielded `separatorClass`. Adding it
// here would widen the public API for no use the spec has.
