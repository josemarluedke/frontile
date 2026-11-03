/**
 * Scroll `target` into view inside `panel` and nowhere else.
 *
 * `scrollIntoView` and a plain `focus()` both scroll *every* scrollable
 * ancestor up to the document, so either one makes the host page jump when a
 * panel opens or when arrow keys walk past its edge. Adjusting `scrollTop`
 * directly keeps the movement inside the panel.
 *
 * The measurements come from `offsetTop`, not `getBoundingClientRect()`:
 * client rects are in transformed pixels, so under any ancestor `scale()` they
 * would not agree with `scrollTop`. This relies on the panel being the
 * target's `offsetParent`, so the panel has to be positioned.
 *
 * `center` places the target mid-panel, for the opening jump to a value that
 * is usually a long way down the list; otherwise the target is brought just
 * far enough into view, which is what stepping key by key wants.
 */
export function revealWithin(
  panel: HTMLElement,
  target: HTMLElement,
  center: boolean
): void {
  const top = target.offsetTop;
  const bottom = top + target.offsetHeight;

  if (center) {
    panel.scrollTop = top - (panel.clientHeight - target.offsetHeight) / 2;
    return;
  }

  if (top < panel.scrollTop) {
    panel.scrollTop = top;
  } else if (bottom > panel.scrollTop + panel.clientHeight) {
    panel.scrollTop = bottom - panel.clientHeight;
  }
}
