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
    /** Start a collapsible panel already open. */
    startOpen?: boolean;
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
  @tracked isOpen = this.args.startOpen ?? false;

  get toggleLabel(): string {
    return this.isOpen ? 'Hide code' : 'Show code';
  }

  @action
  toggle(): void {
    this.isOpen = !this.isOpen;
  }

  <template>
    <div class="code-panel" ...attributes>
      <div class="code-panel__chrome">
        <span class="code-panel__dots" aria-hidden="true">
          <span class="code-panel__dot"></span>
          <span class="code-panel__dot"></span>
          <span class="code-panel__dot"></span>
        </span>

        {{#if @label}}
          <span
            class="code-panel__label font-code text-code-sm"
          >{{@label}}</span>
        {{/if}}

        {{#if @isCollapsible}}
          <span class="code-panel__action">
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
          class="code-panel__body font-code text-code-md"
        ><span class="code-panel__prompt" aria-hidden="true">$</span> {{@code}}</pre>
      {{else if @isCollapsible}}
        <Collapsible @isOpen={{this.isOpen}}>
          <pre
            class="code-panel__body font-code text-code-sm"
          >{{highlightCode @code @language}}</pre>
        </Collapsible>
      {{else}}
        <pre
          class="code-panel__body font-code text-code-sm"
        >{{highlightCode @code @language}}</pre>
      {{/if}}
    </div>
  </template>
}
