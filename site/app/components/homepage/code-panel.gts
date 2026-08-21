import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Button, Collapsible } from 'frontile';
import highlightCode from 'site/helpers/highlight-code';

export interface Signature {
  Args: {
    code: string;
    /** Any language lowlight knows; `gjs`/`gts` map to js/ts. */
    language?: string;
    /** Filename or caption shown in the window chrome. */
    label?: string;
    /** Render a shell prompt rather than highlighted source. */
    isTerminal?: boolean;
    /** Put the body behind a toggle, for snippets long enough to dominate. */
    isCollapsible?: boolean;
  };
  Element: HTMLDivElement;
}

/**
 * A code "window": dark panel, chrome dots, a soft primary glow, and syntax
 * highlighting through the site's existing lowlight helper.
 *
 * Why the panel stays dark in both themes: the bundled highlight.js theme
 * (`app/styles/highlight.css`) is GitHub Dark with fixed token colors, so a
 * light surface would put mid-tone syntax colors on white. The surface uses the
 * dedicated `--color-code-*` tokens rather than the theme's scheme-dependent
 * neutrals, which invert between light and dark.
 *
 * Long snippets take `@isCollapsible`, which uses Frontile's own Collapsible,
 * so a forty-line config does not out-weigh the thing it explains.
 */
export default class CodePanel extends Component<Signature> {
  @tracked isOpen = false;

  /**
   * Collapsible always renders its block — it hides the content with
   * `height: 0; overflow: hidden` — so without this the syntax highlighter ran
   * over the whole snippet at first paint for zero visible pixels, and again on
   * every re-render of the panel's source.
   */
  @tracked hasOpened = false;

  get toggleLabel(): string {
    return this.isOpen ? 'Hide code' : 'Show code';
  }

  @action
  toggle(): void {
    this.isOpen = !this.isOpen;
    this.hasOpened = this.hasOpened || this.isOpen;
  }

  <template>
    {{! Dark in both schemes via the --color-code-* tokens, lifted by a real
        offset glow drawn from the accent rather than a zero-offset halo. }}
    <div
      class="overflow-hidden rounded-xl border border-code-border
        bg-code-surface
        shadow-[0_18px_40px_-24px_var(--color-primary-soft),0_2px_10px_-6px_var(--color-surface-overlay-firm),inset_0_1px_0_rgb(255_255_255/0.04)]"
      ...attributes
    >
      <div
        class="flex items-center gap-3 border-b border-code-border
          bg-code-chrome px-3.5 py-2"
      >
        {{! Traffic-light chrome. The status hues are used as *illustration*
            here — they depict a window's controls and report no state, which is
            why this is not a breach of the status-means-status rule. They are
            decorative, aria-hidden, and never the only carrier of meaning.
            Written per dot rather than as :nth-child so the colour is visible
            where the markup is. }}
        <span class="flex flex-none gap-1.5" aria-hidden="true">
          <span class="size-2.5 rounded-full bg-danger"></span>
          <span class="size-2.5 rounded-full bg-warning"></span>
          <span class="size-2.5 rounded-full bg-success"></span>
        </span>

        {{#if @label}}
          <span
            class="min-w-0 truncate font-code text-code-sm text-neutral"
          >{{@label}}</span>
        {{/if}}

        {{#if @isCollapsible}}
          <span class="ml-auto flex-none text-code-ink">
            <Button
              @appearance="minimal"
              @size="xs"
              @onPress={{this.toggle}}
              aria-expanded={{if this.isOpen "true" "false"}}
            >{{this.toggleLabel}}</Button>
          </span>
        {{/if}}
      </div>

      {{#if @isTerminal}}
        <pre
          class="m-0 overflow-x-auto px-5 py-[1.125rem] font-code text-code-md text-code-ink"
        ><span class="select-none text-code-prompt" aria-hidden="true">$</span> {{@code}}</pre>
      {{else if @isCollapsible}}
        <Collapsible @isOpen={{this.isOpen}}>
          {{#if this.hasOpened}}
            <pre
              class="m-0 overflow-x-auto px-5 py-[1.125rem] font-code text-code-sm text-code-ink"
            >{{highlightCode @code @language}}</pre>
          {{/if}}
        </Collapsible>
      {{else}}
        <pre
          class="m-0 overflow-x-auto px-5 py-[1.125rem] font-code text-code-sm text-code-ink"
        >{{highlightCode @code @language}}</pre>
      {{/if}}
    </div>
  </template>
}
