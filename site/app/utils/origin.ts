import config from 'site/config/environment';

/** Drop the scheme and any trailing slash, e.g. `next.frontile.dev`. */
export function stripScheme(url: string): string {
  return url.replace(/^https?:\/\//, '').replace(/\/$/, '');
}

/**
 * The origin the page is being served from.
 *
 * Reading `window.location.origin` directly throws while the site is being
 * prerendered in Node, so anything evaluated during render has to come through
 * here. When there is no `window` we fall back to the canonical `siteURL` from
 * the app config, which keeps the prerendered HTML correct rather than merely
 * crash-free. Once the app rehydrates in the browser, the real origin wins —
 * which is what makes the version dropdown work on the `next` subdomain.
 */
export function currentOrigin(): string {
  if (typeof window !== 'undefined' && window.location?.origin) {
    return window.location.origin;
  }

  return config.siteURL;
}

/** `currentOrigin()` with the scheme stripped, e.g. `next.frontile.dev`. */
export function currentDomain(): string {
  return stripScheme(currentOrigin());
}
