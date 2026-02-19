import Component from '@glimmer/component';
import { LinkTo } from '@ember/routing';
import DocfyThemeSwitcher from './docfy-theme-switcher';

interface DocfyHeaderSignature {
  Args: {
    indexRoute?: string;
    githubUrl: string;
    disableThemeSwitcher?: boolean;
  };
  Blocks: {
    title: [];
    left: [string, string];
    right: [string, string];
  };
  Element: HTMLDivElement;
}

export default class DocfyHeader extends Component<DocfyHeaderSignature> {
  <template>
    <div class="sticky top-0 z-1">
      <div
        class="h-16 border-b border-neutral-subtle/50 bg-neutral-subtle/60 backdrop-blur-xl backdrop-saturate-150"
        ...attributes
      >
        <div class="flex h-full px-4 mx-auto sm:px-6 max-w-screen-2xl">
          <div class="flex items-center mr-4">
            <LinkTo
              @route={{if @indexRoute @indexRoute "index"}}
              class="text-neutral-firm text-lg font-bold outline-none focus-visible:ring"
            >
              {{yield to="title"}}
            </LinkTo>
          </div>
          <div
            class="flex items-center justify-between flex-grow px-2 md:px-6 text-neutral-strong"
          >
            {{#let
              "text-neutral-strong transition pb-1.5 pt-1.5 border-b-2 border-transparent hover:border-brand-soft outline-none focus-visible:ring hover:text-neutral-firm"
              "border-brand-soft text-neutral-firm"
              as |linkClass linkClassActive|
            }}
              <div class="flex items-center gap-4">
                {{yield linkClass linkClassActive to="left"}}
              </div>

              <div class="flex items-center gap-4 sm:gap-6 ml-4">
                {{yield linkClass linkClassActive to="right"}}

                <a
                  href={{@githubUrl}}
                  target="_blank"
                  rel="noopener noreferrer"
                  class="transition text-neutral-strong outline-none focus-visible:ring hover:text-neutral-firm"
                >
                  <svg viewBox="0 0 20 20" class="w-6 h-6 fill-current">
                    <title>
                      GitHub
                    </title>
                    <path
                      d="M10 0a10 10 0 0 0-3.16 19.49c.5.1.68-.22.68-.48l-.01-1.7c-2.78.6-3.37-1.34-3.37-1.34-.46-1.16-1.11-1.47-1.11-1.47-.9-.62.07-.6.07-.6 1 .07 1.53 1.03 1.53 1.03.9 1.52 2.34 1.08 2.91.83.1-.65.35-1.09.63-1.34-2.22-.25-4.55-1.11-4.55-4.94 0-1.1.39-1.99 1.03-2.69a3.6 3.6 0 0 1 .1-2.64s.84-.27 2.75 1.02a9.58 9.58 0 0 1 5 0c1.91-1.3 2.75-1.02 2.75-1.02.55 1.37.2 2.4.1 2.64.64.7 1.03 1.6 1.03 2.69 0 3.84-2.34 4.68-4.57 4.93.36.31.68.92.68 1.85l-.01 2.75c0 .26.18.58.69.48A10 10 0 0 0 10 0"
                    ></path>
                  </svg>
                </a>

                {{#unless @disableThemeSwitcher}}
                  <DocfyThemeSwitcher class="sm:ml-6" />
                {{/unless}}
              </div>
            {{/let}}
          </div>
        </div>
      </div>
    </div>
  </template>
}
