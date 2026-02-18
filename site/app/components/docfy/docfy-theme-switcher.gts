import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { later } from '@ember/runloop';
import { VisuallyHidden } from 'frontile';

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
        <svg
          aria-hidden="true"
          class="w-6 h-6"
          fill="currentColor"
          viewBox="0 0 20 20"
        >
          <path
            d="M17.293 13.293A8 8 0 016.707 2.707a8.001 8.001 0 1010.586 10.586z"
          ></path>
        </svg>
      {{else}}
        <VisuallyHidden>
          Switch to Dark Mode
        </VisuallyHidden>
        <svg
          aria-hidden="true"
          class="w-6 h-6"
          fill="currentColor"
          viewBox="0 0 20 20"
        >
          <path
            d="M10 2a1 1 0 011 1v1a1 1 0 11-2 0V3a1 1 0 011-1zm4 8a4 4 0 11-8 0 4 4 0 018 0zm-.464 4.95l.707.707a1 1 0 001.414-1.414l-.707-.707a1 1 0 00-1.414 1.414zm2.12-10.607a1 1 0 010 1.414l-.706.707a1 1 0 11-1.414-1.414l.707-.707a1 1 0 011.414 0zM17 11a1 1 0 100-2h-1a1 1 0 100 2h1zm-7 4a1 1 0 011 1v1a1 1 0 11-2 0v-1a1 1 0 011-1zM5.05 6.464A1 1 0 106.465 5.05l-.708-.707a1 1 0 00-1.414 1.414l.707.707zm1.414 8.486l-.707.707a1 1 0 01-1.414-1.414l.707-.707a1 1 0 011.414 1.414zM4 11a1 1 0 100-2H3a1 1 0 000 2h1z"
            clip-rule="evenodd"
            fill-rule="evenodd"
          ></path>
        </svg>
      {{/if}}
    </button>
  </template>
}
