import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { later } from '@ember/runloop';
import { VisuallyHidden } from 'frontile';
import { SunIcon, MoonIcon } from '../icons';

interface Signature {
  Element: HTMLButtonElement;
  Args: Record<string, unknown>;
}
declare const FastBoot: unknown;

const DARK_MODE_CLASS = 'dark';
const LIGHT_MODE_CLASS = 'light';

export default class DocfyThemeSwitcher extends Component<Signature> {
  @tracked prefersDark = false;

  constructor(owner: never, args: Signature['Args']) {
    super(owner, args);
    if (typeof FastBoot !== 'undefined') {
      return;
    }
    const root = document.documentElement;
    this.prefersDark = root.classList.value.includes(DARK_MODE_CLASS);

    // `matchMedia` has no counterpart while the site is prerendered in Node.
    // Following the OS preference only means anything in a live browser, so skip
    // the subscription there rather than making the prerenderer shim it.
    if (typeof window.matchMedia !== 'function') {
      return;
    }

    const mediaQueryList = window.matchMedia('(prefers-color-scheme: dark)');
    mediaQueryList.onchange = ({ matches }): void => {
      if (!localStorage.getItem('prefersMode')) {
        this.prefersDark = matches;
        this.applyClasses();
      }
    };
  }

  @action toggleMode(): void {
    let newMode: string;
    if (this.prefersDark) {
      newMode = 'light';
      this.prefersDark = false;
    } else {
      newMode = 'dark';
      this.prefersDark = true;
    }
    localStorage.setItem('prefersMode', newMode);
    this.applyClasses();
  }

  applyClasses(): void {
    const body = document.body;
    body.style.transition = 'background-color 0.2s ease, color 0.2s ease';
    body.style.transitionDelay = '0s, 0s';

    if (this.prefersDark) {
      document.documentElement.classList.remove(LIGHT_MODE_CLASS);
      document.documentElement.classList.add(DARK_MODE_CLASS);
    } else {
      document.documentElement.classList.remove(DARK_MODE_CLASS);
      document.documentElement.classList.add(LIGHT_MODE_CLASS);
    }

    later(
      this,
      () => {
        body.style.transition = '';
        body.style.transitionDelay = '';
      },
      200
    );
  }
  <template>
    <button
      type="button"
      class="transition text-neutral-strong hover:text-neutral-firm outline-none focus-visible:ring"
      ...attributes
      {{on "click" this.toggleMode}}
    >
      {{#if this.prefersDark}}
        <VisuallyHidden>
          Switch to Light Mode
        </VisuallyHidden>
        <MoonIcon aria-hidden="true" class="w-6 h-6" />
      {{else}}
        <VisuallyHidden>
          Switch to Dark Mode
        </VisuallyHidden>
        <SunIcon aria-hidden="true" class="w-6 h-6" />
      {{/if}}
    </button>
  </template>
}
