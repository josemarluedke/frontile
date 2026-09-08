import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { on } from '@ember/modifier';
import { guidFor } from '@ember/object/internals';
import { element } from 'ember-element-helper';
import Collapsible from '../../utilities/collapsible';
import { ChevronDownIcon } from '../icons';
import type { AccordionContext, HeadingLevel } from './accordion';
import type Owner from '@ember/owner';

/**
 * `eq` is not available from `@ember/helper`, and a dynamic tag needs a string.
 * A plain module-scope function works as a helper, as in `divider.gts`.
 */
function headingTag(level: HeadingLevel): string {
  return `h${level}`;
}

interface AccordionItemArgs {
  /**
   * Names this item so it can be addressed from outside -- `@keys`,
   * `@defaultKeys`, a query param, persisted state. Optional: without one the
   * item still works, it is simply not externally addressable.
   *
   * @defaultValue a generated unique id
   */
  key?: string;

  /**
   * Opens this item initially, without needing a key anywhere. Ignored when
   * the accordion is controlled or when `@defaultKeys` is passed. In `single`
   * mode, if several items declare it, the first in document order wins.
   *
   * @defaultValue false
   */
  isDefaultOpen?: boolean;

  /** Shorthand for the `title` block. */
  title?: string;

  /** Shorthand for the `subtitle` block. */
  subtitle?: string;

  /**
   * Disables this item alone: it cannot be toggled and arrow-key navigation
   * steps over it.
   *
   * @defaultValue false
   */
  isDisabled?: boolean;

  /** Class names appended to this item's theme classes. */
  class?: string;

  /**
   * Supplied by Accordion. Not part of the public API.
   *
   * @internal
   */
  context: AccordionContext;
}

interface AccordionItemSignature {
  Args: AccordionItemArgs;
  Blocks: {
    default: [{ isOpen: boolean; toggle: () => void }];
    content: [{ isOpen: boolean; toggle: () => void }];
    title: [{ isOpen: boolean; toggle: () => void }];
    subtitle: [{ isOpen: boolean; toggle: () => void }];
    startContent: [{ isOpen: boolean; toggle: () => void }];
    indicator: [{ isOpen: boolean; toggle: () => void }];
  };
  Element: HTMLDivElement;
}

class AccordionItem extends Component<AccordionItemSignature> {
  /**
   * Identity. Falls back to a guid rather than an index: an index silently
   * reassigns open state the moment an item sits behind an `{{#if}}`.
   */
  readonly key: string;

  constructor(owner: Owner, args: AccordionItemArgs) {
    super(owner, args);
    this.key = this.args.key ?? guidFor(this);

    // Registered from the constructor, which runs in document order during
    // render, so the root can resolve single mode's "first one wins" without
    // writing tracked state mid-render.
    if (this.args.isDefaultOpen) {
      this.args.context.registerDefaultOpen(this.key);
    }
  }

  willDestroy(): void {
    super.willDestroy();
    this.args.context.unregisterDefaultOpen(this.key);
  }

  get isOpen(): boolean {
    return this.args.context.isOpen(this.key);
  }

  /**
   * A collapsed `Collapsible` is `height: 0; overflow: hidden` -- gone to the
   * eye, but its focusable children are still in the tab order. `inert` is
   * what actually removes them. Glimmer normalizes a dynamic attribute bound
   * to `false` or `undefined` to `removeAttribute`, so both render identically;
   * `undefined` is chosen because it directly states the intent for a boolean
   * attribute.
   */
  get inert(): true | undefined {
    return this.isOpen ? undefined : true;
  }

  get isDisabled(): boolean {
    return !!this.args.isDisabled || this.args.context.isGroupDisabled;
  }

  get triggerId(): string {
    return `${guidFor(this)}-trigger`;
  }

  get panelId(): string {
    return `${guidFor(this)}-panel`;
  }

  toggle = (): void => {
    if (this.isDisabled) {
      return;
    }
    this.args.context.toggle(this.key);
  };

  handleKeydown = (event: KeyboardEvent): void => {
    if (
      event.key !== 'ArrowDown' &&
      event.key !== 'ArrowUp' &&
      event.key !== 'Home' &&
      event.key !== 'End'
    ) {
      return;
    }

    event.preventDefault();
    this.args.context.focusSibling(
      event.currentTarget as HTMLElement,
      event.key
    );
  };

  <template>
    <div
      data-open="{{this.isOpen}}"
      data-disabled="{{this.isDisabled}}"
      class="{{@context.itemClass}} {{@class}}"
      ...attributes
    >
      {{#let (element (headingTag @context.headingLevel)) as |Heading|}}
        <Heading class={{@context.headingClass}}>
          <button
            type="button"
            data-fr-accordion-trigger
            id={{this.triggerId}}
            aria-expanded="{{this.isOpen}}"
            aria-controls={{this.panelId}}
            aria-disabled="{{this.isDisabled}}"
            data-open="{{this.isOpen}}"
            data-disabled="{{this.isDisabled}}"
            class={{@context.triggerClass}}
            {{on "click" this.toggle}}
            {{on "keydown" this.handleKeydown}}
          >
            {{#if (has-block "startContent")}}
              <span class={{@context.startContentClass}}>
                {{yield
                  (hash isOpen=this.isOpen toggle=this.toggle)
                  to="startContent"
                }}
              </span>
            {{/if}}

            <span class={{@context.titleWrapperClass}}>
              <span class={{@context.titleClass}}>
                {{#if (has-block "title")}}
                  {{yield
                    (hash isOpen=this.isOpen toggle=this.toggle)
                    to="title"
                  }}
                {{else}}
                  {{@title}}
                {{/if}}
              </span>

              {{#if (if (has-block "subtitle") true @subtitle)}}
                <span class={{@context.subtitleClass}}>
                  {{#if (has-block "subtitle")}}
                    {{yield
                      (hash isOpen=this.isOpen toggle=this.toggle)
                      to="subtitle"
                    }}
                  {{else}}
                    {{@subtitle}}
                  {{/if}}
                </span>
              {{/if}}
            </span>

            {{#unless @context.hideIndicator}}
              <span aria-hidden="true" class={{@context.indicatorClass}}>
                {{#if (has-block "indicator")}}
                  {{yield
                    (hash isOpen=this.isOpen toggle=this.toggle)
                    to="indicator"
                  }}
                {{else}}
                  <ChevronDownIcon />
                {{/if}}
              </span>
            {{/unless}}
          </button>
        </Heading>
      {{/let}}

      <Collapsible
        @isOpen={{this.isOpen}}
        role="region"
        id={{this.panelId}}
        aria-labelledby={{this.triggerId}}
        inert={{this.inert}}
        class={{@context.contentClass}}
      >
        <div class={{@context.contentBodyClass}}>
          {{#if (has-block "content")}}
            {{yield (hash isOpen=this.isOpen toggle=this.toggle) to="content"}}
          {{else}}
            {{yield (hash isOpen=this.isOpen toggle=this.toggle)}}
          {{/if}}
        </div>
      </Collapsible>
    </div>
  </template>
}

export { AccordionItem, type AccordionItemSignature, type AccordionItemArgs };
export default AccordionItem;
