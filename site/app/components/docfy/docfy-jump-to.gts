import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { modifier } from 'ember-modifier';
import { service } from '@ember/service';
import { DocfyService } from '@docfy/ember';
import RouterService from '@ember/routing/router-service';
import type { PageMetadata } from '@docfy/core/lib/types';
import Fuse from 'fuse.js';
import { Overlay } from 'frontile';
import { VisuallyHidden } from 'frontile';
import DocfyLink from '@docfy/ember/components/docfy-link';

interface DocfyJumpToArgs {}

interface ResultItem {
  item: PageMetadata;
}

function eq(a: unknown, b: unknown): boolean {
  return a === b;
}

export default class DocfyJumpTo extends Component<DocfyJumpToArgs> {
  @service docfy!: DocfyService;
  @service router!: RouterService;

  @tracked isOpen = false;

  @tracked pattern?: string;
  @tracked results?: ResultItem[];
  @tracked selected?: number;
  @tracked resultsContainerElement?: HTMLElement;

  fuse = new Fuse(this.docfy.flat, {
    keys: ['title', 'parentLabel'],
    threshold: 0.4,
  });

  selectNext(): void {
    if (!this.results) {
      return;
    }

    if (typeof this.selected !== 'undefined') {
      if (this.selected + 1 < this.results.length) {
        this.selected += 1;
      }
    } else {
      this.selected = 0;
    }
  }

  selectPrevious(): void {
    if (!this.results) {
      return;
    }

    if (typeof this.selected !== 'undefined') {
      if (this.selected - 1 >= 0) {
        this.selected -= 1;
      }
    }
  }

  setupShortcut = modifier(() => {
    document.addEventListener('keydown', this.handleGlobalKeyDown);

    return () => {
      document.removeEventListener('keydown', this.handleGlobalKeyDown);
    };
  });

  @action handleGlobalKeyDown(event: KeyboardEvent): void {
    if (
      !['INPUT', 'TEXTAREA'].includes((event.target as HTMLElement).tagName)
    ) {
      if (event.key === '/') {
        this.isOpen = true;
      }
    }
  }

  registerContainerElement = modifier((element: HTMLElement) => {
    this.resultsContainerElement = element;

    return () => {
      this.resultsContainerElement = undefined;
    };
  });

  @action search(event: Event): void {
    const pattern = (event.target as HTMLInputElement).value;

    this.results = this.fuse.search(pattern).map((item) => {
      return {
        item: item.item,
      };
    });
    this.selected = undefined;
    this.selectNext();
  }

  @action toggle(): void {
    this.isOpen = !this.isOpen;
  }

  @action didClose(): void {
    this.results = undefined;
  }

  @action onItemClick(event: MouseEvent): void {
    event.preventDefault();

    const target = event.target as HTMLElement;
    let element: HTMLElement | null = target;

    if (['svg', 'span'].includes(target.tagName.toLowerCase())) {
      element = target.parentElement;
    }

    this.isOpen = false;
    const href = element?.getAttribute('href') || '/';
    this.router.transitionTo(href);
  }

  @action selectElement(event: MouseEvent): void {
    const index = Number(
      (event.target as HTMLElement).getAttribute('data-result')
    );
    this.selected = index;
  }

  @action onInputKeyDown(event: KeyboardEvent): void {
    if (event.key === 'ArrowDown') {
      this.selectNext();
      event.preventDefault();
    } else if (event.key === 'ArrowUp') {
      this.selectPrevious();
      event.preventDefault();
    } else if (event.key === 'Enter') {
      event.preventDefault();
      if (this.resultsContainerElement) {
        const link = this.resultsContainerElement.querySelector(
          `[data-result="${this.selected}"]`
        ) as HTMLElement | undefined;
        if (link) {
          link.click();
        }
      }
    }
  }

  <template>
    <button
      type="button"
      class="transition flex items-center rounded focus-visible:ring outline-none hover:text-neutral-strong"
      {{on "click" this.toggle}}
      {{this.setupShortcut}}
    >
      <svg
        class="w-4 h-4 mr-2"
        fill="none"
        stroke="currentColor"
        viewBox="0 0 24 24"
        xmlns="http://www.w3.org/2000/svg"
      ><path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
        ></path></svg>

      Search
      <code
        class="hidden sm:block ml-3 rounded border font-bold border-neutral-soft px-2 py-1 text-xs leading-none"
      >
        /
      </code>
    </button>

    <Overlay
      @isOpen={{this.isOpen}}
      @onClose={{this.toggle}}
      @didClose={{this.didClose}}
      @backdrop="blur"
    >
      <div
        class="p-4 mx-auto text-white mt-20 max-w-md w-full dark"
        {{this.registerContainerElement}}
      >
        <div
          class="bg-neutral-subtle backdrop-blur bg-opacity-80 rounded overflow-hidden border border-neutral-subtle"
        >
          {{!  template-lint-disable self-closing-void-elements  }}
          <VisuallyHidden>
            <label for="docfy-jump-to-input">
              Search
            </label>
          </VisuallyHidden>
          <input
            id="docfy-jump-to-input"
            autocomplete="off"
            placeholder="Search..."
            class="p-4 bg-transparent w-full focus:outline-none placeholder-neutral-soft
              {{if this.results.length "border-b border-neutral-soft"}}
              "
            {{on "input" this.search}}
            {{on "keydown" this.onInputKeyDown}}
          />
          {{!  template-lint-enable self-closing-void-elements  }}

          <div class="space-y-2 max-h-96 overflow-y-scroll">
            {{#each this.results as |result index|}}
              <DocfyLink
                @to={{result.item.url}}
                class="flex items-center p-4 outline-none focus-visible:ring ring-inset
                  {{if
                    (eq this.selected index)
                    "bg-brand-soft text-on-brand-soft"
                  }}"
                data-result={{index}}
                {{on "click" this.onItemClick}}
                {{on "mouseenter" this.selectElement}}
              >
                <span class="font-bold">
                  {{result.item.parentLabel}}
                </span>

                <svg
                  class="w-4 h-4 mx-2"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M9 5l7 7-7 7"
                  ></path>
                </svg>

                <span class="text-neutral-strong">
                  {{result.item.title}}
                </span>
              </DocfyLink>
            {{/each}}
          </div>
        </div>
      </div>
    </Overlay>
  </template>
}
