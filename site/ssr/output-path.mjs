import { join } from 'node:path';

/**
 * The file a route's HTML is written to.
 *
 * Flat `<route>.html`, never `<route>/index.html`. Every link the site renders is
 * extensionless and slash-free (`/docs/components/buttons/button`) — including
 * Docfy index pages, whose URLs do carry a trailing slash. Netlify's Pretty URLs
 * serve `/foo` from `foo.html`, while `foo/index.html` answers only at `/foo/`,
 * so directory output would put a 301 in front of every cold page load and move
 * the site's canonical URLs.
 *
 * A route and its children coexist: `/docs/get-started/` becomes
 * `docs/get-started.html` alongside the `docs/get-started/` directory holding
 * `installation.html`.
 */
export function outputPathForUrl(distDir, url) {
  const relative = url.replace(/^\/+/, '').replace(/\/+$/, '');

  return relative === ''
    ? join(distDir, 'index.html')
    : join(distDir, `${relative}.html`);
}
