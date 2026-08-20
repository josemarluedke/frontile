import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { htmlSafe } from '@ember/template';
import { on } from '@ember/modifier';
import { VisuallyHidden } from 'frontile';

type SafeString = ReturnType<typeof htmlSafe>;

export interface Signature {
  Args: {
    /** Accessible description of what the duplicated specimen shows. */
    description: string;
  };
  Blocks: {
    /** Rendered twice — once per theme. Must be safe to duplicate. */
    specimen: [];
  };
  Element: HTMLDivElement;
}

const MIN = 8;
const MAX = 92;

/**
 * Renders one specimen twice — the ambient theme underneath, the opposite theme
 * clipped over the top — with a draggable seam between them.
 *
 * This is only possible because Frontile's semantic tokens are CSS custom
 * properties scoped by selector rather than by `prefers-color-scheme`: the
 * theme plugin emits every variable under `.light, .dark .theme-inverse` and
 * `.dark, .light .theme-inverse`, so a subtree tagged `.theme-inverse`
 * re-resolves the entire palette. Both themes can therefore be live on one page
 * at once.
 *
 * Accessibility notes:
 *
 * - The seam handle implements the ARIA window-splitter pattern
 *   (`role="separator"` with `aria-valuenow`), so it is operable with arrow
 *   keys, Home, and End — not pointer-only.
 * - Both specimen copies are `inert`. They are a picture of a UI, not a working
 *   one, and duplicated controls would otherwise appear twice in the tab order
 *   and twice to a screen reader. A `VisuallyHidden` description carries the
 *   meaning instead, and the page's live, operable components sit below.
 */
export default class ThemeSeam extends Component<Signature> {
  @tracked split = 50;

  private dragging = false;

  get clipStyle(): SafeString {
    // inset(top right bottom left) — reveal only what sits right of the seam.
    return htmlSafe(`clip-path: inset(0 0 0 ${this.split}%)`);
  }

  get seamStyle(): SafeString {
    return htmlSafe(`left: ${this.split}%`);
  }

  get roundedSplit(): number {
    return Math.round(this.split);
  }

  private clamp(value: number): number {
    return Math.min(MAX, Math.max(MIN, value));
  }

  private setFromClientX(handle: HTMLElement, clientX: number): void {
    const track = handle.parentElement;

    if (!track) {
      return;
    }

    const rect = track.getBoundingClientRect();

    if (rect.width === 0) {
      return;
    }

    this.split = this.clamp(((clientX - rect.left) / rect.width) * 100);
  }

  @action
  handlePointerDown(event: PointerEvent): void {
    const handle = event.currentTarget as HTMLElement;

    this.dragging = true;
    handle.setPointerCapture(event.pointerId);
    handle.focus();
    this.setFromClientX(handle, event.clientX);
    event.preventDefault();
  }

  @action
  handlePointerMove(event: PointerEvent): void {
    if (!this.dragging) {
      return;
    }

    this.setFromClientX(event.currentTarget as HTMLElement, event.clientX);
  }

  @action
  handlePointerUp(event: PointerEvent): void {
    const handle = event.currentTarget as HTMLElement;

    this.dragging = false;

    if (handle.hasPointerCapture(event.pointerId)) {
      handle.releasePointerCapture(event.pointerId);
    }
  }

  @action
  handleKeyDown(event: KeyboardEvent): void {
    const step = event.shiftKey ? 10 : 2;
    let next: number;

    switch (event.key) {
      case 'ArrowLeft':
      case 'ArrowDown':
        next = this.split - step;
        break;
      case 'ArrowRight':
      case 'ArrowUp':
        next = this.split + step;
        break;
      case 'Home':
        next = MIN;
        break;
      case 'End':
        next = MAX;
        break;
      case 'Enter':
        next = 50;
        break;
      default:
        return;
    }

    this.split = this.clamp(next);
    event.preventDefault();
  }

  <template>
    <div class="theme-seam" ...attributes>
      <VisuallyHidden>{{@description}}</VisuallyHidden>

      {{! Ambient theme }}
      <div class="theme-seam__copy" inert>
        <span class="theme-seam__label" aria-hidden="true">Your theme</span>
        {{yield to="specimen"}}
      </div>

      {{! Opposite theme, clipped to the right of the seam }}
      <div
        class="theme-seam__inverse theme-seam__copy theme-inverse"
        style={{this.clipStyle}}
        aria-hidden="true"
        inert
      >
        <span class="theme-seam__label" aria-hidden="true">Inverted</span>
        {{yield to="specimen"}}
      </div>

      <div
        class="theme-seam__line"
        style={{this.seamStyle}}
        aria-hidden="true"
      ></div>

      {{! A drag affordance has to begin on pointerdown; there is no way to
          start a drag from pointerup. Keyboard users get the full ARIA
          window-splitter behaviour via the keydown handler below, so the
          interaction is not pointer-only. }}
      {{! template-lint-disable no-pointer-down-event-binding }}
      <div
        class="theme-seam__handle"
        style={{this.seamStyle}}
        role="separator"
        tabindex="0"
        aria-orientation="vertical"
        aria-label="Drag to compare the light and dark themes"
        aria-valuemin={{MIN}}
        aria-valuemax={{MAX}}
        aria-valuenow={{this.roundedSplit}}
        aria-valuetext="{{this.roundedSplit}}% your theme, the rest inverted"
        {{on "pointerdown" this.handlePointerDown}}
        {{on "pointermove" this.handlePointerMove}}
        {{on "pointerup" this.handlePointerUp}}
        {{on "pointercancel" this.handlePointerUp}}
        {{! If capture is lost without a pointerup — pointer leaves the window,
            another gesture wins — the drag must still end, or the seam would
            keep following the cursor. }}
        {{on "lostpointercapture" this.handlePointerUp}}
        {{on "keydown" this.handleKeyDown}}
      ></div>
      {{! template-lint-enable no-pointer-down-event-binding }}

      {{! The icon is a sibling, not a child: an element with role="separator"
          may not have semantic descendants, and this keeps the handle's ARIA
          contract clean. It never receives pointer events, so the handle
          underneath still gets the drag. }}
      <span
        class="theme-seam__grip-wrap"
        style={{this.seamStyle}}
        aria-hidden="true"
      >
        <svg
          class="theme-seam__grip"
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          focusable="false"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M7.5 21 3 16.5m0 0L7.5 12M3 16.5h13.5m0-13.5L21 7.5m0 0L16.5 12M21 7.5H7.5"
          />
        </svg>
      </span>
    </div>
  </template>
}
