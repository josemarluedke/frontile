import Component from '@glimmer/component';
import { cached, tracked } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { modifier } from 'ember-modifier';
import { useStyles, type SlotsToClasses } from '@frontile/theme';
import AccordionItem from './item';
import type { AccordionSlots, AccordionVariants } from '@frontile/theme';
import type { WithBoundArgs } from '@glint/template';

type HeadingLevel = 2 | 3 | 4 | 5 | 6;

interface AccordionArgs {
  /**
   * Whether one item or several may be open at a time.
   *
   * @defaultValue 'single'
   */
  selectionMode?: 'single' | 'multiple';

  /**
   * The keys of the open items.
   *
   * *Passing* this argument at all puts the component in controlled mode --
   * passing it as `undefined` included. Omit it entirely to let `Accordion`
   * track the open items itself.
   */
  keys?: string[];

  /**
   * Seeds the open items when uncontrolled. Takes precedence over any item's
   * `@isDefaultOpen`.
   */
  defaultKeys?: string[];

  /** Called with the new set of open keys whenever an item is toggled. */
  onChange?: (keys: string[]) => void;

  /**
   * Whether the open item can be closed again in `single` mode. Has no effect
   * in `multiple` mode.
   *
   * @defaultValue true
   */
  isCollapsible?: boolean;

  /**
   * Disables every item.
   *
   * @defaultValue false
   */
  isDisabled?: boolean;

  /**
   * The container treatment.
   *
   * @defaultValue 'separated'
   */
  variant?: AccordionVariants['variant'];

  /**
   * Drives padding and text size.
   *
   * @defaultValue 'md'
   */
  size?: AccordionVariants['size'];

  /**
   * Hides the chevron on every item.
   *
   * @defaultValue false
   */
  hideIndicator?: boolean;

  /**
   * The heading level each trigger is wrapped in. Pick the one that fits the
   * surrounding page outline.
   *
   * @defaultValue 3
   */
  headingLevel?: HeadingLevel;

  /** Class names for each slot of the component, merged with the theme's. */
  classes?: SlotsToClasses<AccordionSlots>;
}

interface AccordionContext {
  itemClass: string;
  headingClass: string;
  triggerClass: string;
  startContentClass: string;
  titleWrapperClass: string;
  titleClass: string;
  subtitleClass: string;
  indicatorClass: string;
  contentClass: string;
  contentBodyClass: string;
  isGroupDisabled: boolean;
  hideIndicator: boolean;
  headingLevel: HeadingLevel;
  isOpen: (key: string) => boolean;
  toggle: (key: string) => void;
  registerDefaultOpen: (key: string) => void;
  unregisterDefaultOpen: (key: string) => void;
  focusSibling: (from: HTMLElement, key: string) => void;
}

interface AccordionSignature {
  Args: AccordionArgs;
  Blocks: {
    default: [
      {
        Item: WithBoundArgs<typeof AccordionItem, 'context'>;
      }
    ];
  };
  Element: HTMLDivElement;
}

class Accordion extends Component<AccordionSignature> {
  /**
   * Uncontrolled mode's own state. `undefined` means "not interacted with
   * yet", which is what lets `@defaultKeys` and the items' own
   * `@isDefaultOpen` seed the initial state without ever writing tracked state
   * during render.
   */
  @tracked private _keys: string[] | undefined;

  /**
   * Keys of items that declared `@isDefaultOpen`, in document order.
   *
   * Untracked on purpose: items push into this from their constructor, which
   * runs during render. A tracked write there would raise a backtracking
   * assertion. Nothing reads it after the first interaction, so it never needs
   * to be reactive.
   */
  #defaultOpenKeys: string[] = [];

  #element: HTMLElement | undefined;

  setupRoot = modifier((element: HTMLElement) => {
    this.#element = element;

    return (): void => {
      this.#element = undefined;
    };
  });

  @cached
  get styles() {
    const { accordion } = useStyles();

    return accordion({
      variant: this.args.variant,
      size: this.args.size,
      isDisabled: this.args.isDisabled
    });
  }

  get selectionMode(): 'single' | 'multiple' {
    return this.args.selectionMode ?? 'single';
  }

  /**
   * Whether `@keys` was *passed* decides the mode -- not whether it holds a
   * value. Glimmer's named-args object carries a key for every argument
   * written in the invoking template, so `in` distinguishes `@keys={{undefined}}`
   * from an omitted `@keys`.
   */
  get isControlled(): boolean {
    return 'keys' in this.args;
  }

  get openKeys(): string[] {
    if (this.isControlled) {
      return this.args.keys ?? [];
    }

    if (this._keys !== undefined) {
      return this._keys;
    }

    if (this.args.defaultKeys) {
      return this.args.defaultKeys;
    }

    // Items declaring `@isDefaultOpen`. In single mode only the first in
    // document order can win, and document order is exactly the order the
    // items' constructors ran in.
    return this.selectionMode === 'single'
      ? this.#defaultOpenKeys.slice(0, 1)
      : this.#defaultOpenKeys;
  }

  isOpen = (key: string): boolean => this.openKeys.includes(key);

  toggle = (key: string): void => {
    if (this.args.isDisabled) {
      return;
    }

    const current = this.openKeys;
    const isCurrentlyOpen = current.includes(key);
    let next: string[];

    if (this.selectionMode === 'multiple') {
      next = isCurrentlyOpen
        ? current.filter((candidate) => candidate !== key)
        : [...current, key];
    } else if (isCurrentlyOpen) {
      if (this.args.isCollapsible === false) {
        return;
      }
      next = [];
    } else {
      next = [key];
    }

    this._keys = next;
    this.args.onChange?.(next);
  };

  registerDefaultOpen = (key: string): void => {
    if (!this.#defaultOpenKeys.includes(key)) {
      this.#defaultOpenKeys.push(key);
    }
  };

  unregisterDefaultOpen = (key: string): void => {
    this.#defaultOpenKeys = this.#defaultOpenKeys.filter(
      (candidate) => candidate !== key
    );
  };

  /**
   * Every trigger belonging to *this* accordion, in DOM order.
   *
   * Read from the DOM rather than from a registration list so the order is
   * always the rendered one. The `closest` check is what keeps a nested
   * accordion from stealing its parent's arrow keys.
   */
  #triggers(): HTMLElement[] {
    if (!this.#element) {
      return [];
    }

    const root = this.#element;
    return [
      ...root.querySelectorAll<HTMLElement>('[data-part="trigger"]')
    ].filter((element) => element.closest('[data-component]') === root);
  }

  focusSibling = (from: HTMLElement, key: string): void => {
    const triggers = this.#triggers();
    if (triggers.length === 0) {
      return;
    }

    const index = triggers.indexOf(from);

    const isFocusable = (element: HTMLElement | undefined): boolean =>
      !!element && element.getAttribute('aria-disabled') !== 'true';

    // Walk rather than jump, so a disabled neighbour is stepped over instead
    // of swallowing the keypress. The double modulo is what keeps a backwards
    // walk positive -- JavaScript's `%` returns a negative remainder for a
    // negative left operand, so a single `%` would index off the front.
    const step = (start: number, delta: number): HTMLElement | undefined => {
      const total = triggers.length;
      for (let offset = 1; offset <= total; offset++) {
        const index = (((start + delta * offset) % total) + total) % total;
        const candidate = triggers[index];
        if (isFocusable(candidate)) {
          return candidate;
        }
      }
      return undefined;
    };

    const fromEdge = (delta: number): HTMLElement | undefined => {
      const ordered = delta > 0 ? triggers : [...triggers].reverse();
      return ordered.find((candidate) => isFocusable(candidate));
    };

    let target: HTMLElement | undefined;

    switch (key) {
      case 'ArrowDown':
        target = index === -1 ? fromEdge(1) : step(index, 1);
        break;
      case 'ArrowUp':
        target = index === -1 ? fromEdge(-1) : step(index, -1);
        break;
      case 'Home':
        target = fromEdge(1);
        break;
      case 'End':
        target = fromEdge(-1);
        break;
      default:
        return;
    }

    target?.focus();
  };

  @cached
  get context(): AccordionContext {
    const { classes } = this.args;

    return {
      itemClass: this.styles.item({ class: classes?.item }),
      headingClass: this.styles.heading({ class: classes?.heading }),
      triggerClass: this.styles.trigger({ class: classes?.trigger }),
      startContentClass: this.styles.startContent({
        class: classes?.startContent
      }),
      titleWrapperClass: this.styles.titleWrapper({
        class: classes?.titleWrapper
      }),
      titleClass: this.styles.title({ class: classes?.title }),
      subtitleClass: this.styles.subtitle({ class: classes?.subtitle }),
      indicatorClass: this.styles.indicator({ class: classes?.indicator }),
      contentClass: this.styles.content({ class: classes?.content }),
      contentBodyClass: this.styles.contentBody({
        class: classes?.contentBody
      }),
      isGroupDisabled: this.args.isDisabled ?? false,
      hideIndicator: this.args.hideIndicator ?? false,
      headingLevel: this.args.headingLevel ?? 3,
      isOpen: this.isOpen,
      toggle: this.toggle,
      registerDefaultOpen: this.registerDefaultOpen,
      unregisterDefaultOpen: this.unregisterDefaultOpen,
      focusSibling: this.focusSibling
    };
  }

  <template>
    <div
      data-component="accordion"
      data-part="base"
      class={{this.styles.base class=@classes.base}}
      {{this.setupRoot}}
      ...attributes
    >
      {{! @glint-ignore: WithBoundArgs vs. a plain class component }}
      {{yield (hash Item=(component AccordionItem context=this.context))}}
    </div>
  </template>
}

export {
  Accordion,
  type AccordionSignature,
  type AccordionArgs,
  type AccordionContext,
  type HeadingLevel
};
export default Accordion;
