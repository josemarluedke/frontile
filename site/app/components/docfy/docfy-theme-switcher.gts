import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { hash } from '@ember/helper';
import { registerDestructor } from '@ember/destroyable';
import { SegmentedControl, Tooltip } from 'frontile';
import IconSun from '~icons/lucide/sun';
import IconMoon from '~icons/lucide/moon';
import IconMonitor from '~icons/lucide/monitor';

interface Signature {
  Element: HTMLDivElement;
  Args: Record<string, unknown>;
}
declare const FastBoot: unknown;

const DARK_MODE_CLASS = 'dark';
const LIGHT_MODE_CLASS = 'light';
const STORAGE_KEY = 'prefersMode';

type Mode = 'light' | 'dark' | 'system';

function isMode(value: unknown): value is Mode {
  return value === 'light' || value === 'dark' || value === 'system';
}

/*
 * linkedom gives the prerenderer a `document` and a `window`, but no working
 * `localStorage` -- the object is there, the methods are not. Reading it
 * unguarded threw on all 92 prerendered pages. Every access goes through these
 * two, which fall back to "no stored preference" rather than failing the render.
 */
function readStoredMode(): Mode | null {
  try {
    if (typeof localStorage?.getItem !== 'function') {
      return null;
    }
    const stored = localStorage.getItem(STORAGE_KEY);
    return isMode(stored) ? stored : null;
  } catch {
    // Private windows and blocked site data throw on access, not on read.
    return null;
  }
}

function writeStoredMode(mode: Mode): void {
  try {
    if (typeof localStorage?.setItem === 'function') {
      localStorage.setItem(STORAGE_KEY, mode);
    }
  } catch {
    // A preference that cannot be persisted still applies for this page.
  }
}

/**
 * Light / Dark / System, as three always-visible segments.
 *
 * The two-position flip this replaces could express only two of the three
 * states a reader can be in: the moment you touched it you were pinned to a
 * choice, with no way back to following the OS. A laptop that dims itself at
 * sunset should take the docs with it.
 *
 * A segmented control suits the choice better than a menu, because what is
 * selected is the *mode*, not the resulting colour — and a menu trigger can
 * only show one of those two at a time. Here the indicator can sit on "System"
 * while the page itself is dark, and the two facts stop competing for the same
 * icon.
 */
export default class DocfyThemeSwitcher extends Component<Signature> {
  @tracked mode: Mode = 'system';
  @tracked systemPrefersDark = false;

  /** Pending handle for the inline body transition cleanup. */
  private transitionTimer?: ReturnType<typeof setTimeout>;

  constructor(owner: never, args: Signature['Args']) {
    super(owner, args);
    if (typeof FastBoot !== 'undefined') {
      return;
    }

    registerDestructor(this, () => {
      if (this.transitionTimer !== undefined) {
        clearTimeout(this.transitionTimer);
      }
    });

    this.mode = readStoredMode() ?? 'system';

    // `matchMedia` has no counterpart while the site is prerendered in Node.
    // Following the OS preference only means anything in a live browser, so skip
    // the subscription there rather than making the prerenderer shim it.
    if (typeof window.matchMedia !== 'function') {
      return;
    }

    const mediaQueryList = window.matchMedia('(prefers-color-scheme: dark)');
    this.systemPrefersDark = mediaQueryList.matches;

    const onSystemChange = ({ matches }: MediaQueryListEvent): void => {
      this.systemPrefersDark = matches;
      // Only while unpinned. A reader who picked Light meant Light, even at
      // sunset.
      if (this.mode === 'system') {
        this.applyClasses();
      }
    };

    // `addEventListener` rather than the `onchange` property this used before:
    // the property form is a single slot, so anything else subscribing to the
    // same query would silently evict this one.
    mediaQueryList.addEventListener('change', onSystemChange);
    registerDestructor(this, () => {
      mediaQueryList.removeEventListener('change', onSystemChange);
    });

    // The pre-paint script in index.html resolves `system` through this same
    // query, so <html> is already correct; re-applying only matters when the
    // stored value was something neither of them recognises.
    this.applyClasses();
  }

  /** What is actually painted right now, once `system` is resolved. */
  get isDark(): boolean {
    if (this.mode === 'system') {
      return this.systemPrefersDark;
    }
    return this.mode === 'dark';
  }

  @action
  selectMode(value: Mode): void {
    if (!isMode(value)) {
      return;
    }

    this.mode = value;
    writeStoredMode(value);
    this.applyClasses();
  }

  applyClasses(): void {
    const root = document.documentElement;
    const shouldBeDark = this.isDark;
    const wanted = shouldBeDark ? DARK_MODE_CLASS : LIGHT_MODE_CLASS;

    // Picking the mode that is already painted — System while the OS is
    // already dark, say — changes nothing, so it should not flash a transition
    // over the whole page.
    if (root.classList.contains(wanted)) {
      return;
    }

    const body = document.body;
    body.style.transition = 'background-color 0.2s ease, color 0.2s ease';
    body.style.transitionDelay = '0s, 0s';

    root.classList.remove(shouldBeDark ? LIGHT_MODE_CLASS : DARK_MODE_CLASS);
    root.classList.add(wanted);

    // The inline transition exists only to smooth this one swap; clear it
    // afterwards so nothing else on the page inherits a 200ms colour fade.
    // Tracked through a destructor rather than left dangling, since a torn-down
    // component must not reach back into the document.
    clearTimeout(this.transitionTimer);
    this.transitionTimer = setTimeout(() => {
      this.transitionTimer = undefined;
      body.style.transition = '';
      body.style.transitionDelay = '';
    }, 200);
  }

  <template>
    <div ...attributes>
      {{! Icon-only, so every segment carries its own aria-label: a tooltip
          arrives as aria-describedby, which describes a control rather than
          naming one, and would leave these three unnamed on their own. }}
      <SegmentedControl
        @value={{this.mode}}
        @onChange={{this.selectMode}}
        @size="sm"
        @classes={{hash item="px-2"}}
        aria-label="Color theme"
        as |Ctl|
      >
        <Tooltip @content="Light" as |t|>
          <Ctl.Item @value="light" aria-label="Light" {{t.trigger}}>
            <IconSun aria-hidden="true" class="size-4" />
          </Ctl.Item>
        </Tooltip>

        <Tooltip @content="Dark" as |t|>
          <Ctl.Item @value="dark" aria-label="Dark" {{t.trigger}}>
            <IconMoon aria-hidden="true" class="size-4" />
          </Ctl.Item>
        </Tooltip>

        <Tooltip @content="Follow system" as |t|>
          <Ctl.Item @value="system" aria-label="Follow system" {{t.trigger}}>
            <IconMonitor aria-hidden="true" class="size-4" />
          </Ctl.Item>
        </Tooltip>
      </SegmentedControl>
    </div>
  </template>
}
