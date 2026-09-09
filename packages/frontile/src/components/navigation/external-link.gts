import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { useStyles } from '@frontile/theme';
import type { TOC } from '@ember/component/template-only';
import type { ExternalLinkSlots, SlotsToClasses } from '@frontile/theme';

/**
 * Heroicons `arrow-top-right-on-square`. An arrow leaving a box reads as
 * "opens elsewhere"; a bare diagonal arrow is too easily taken for decoration.
 *
 * Unsized on purpose -- the `icon` slot wraps it and drives the size from the
 * inherited font size.
 */
const IconExternalLink: TOC<{ Element: SVGElement }> = <template>
  <svg
    xmlns="http://www.w3.org/2000/svg"
    fill="none"
    viewBox="0 0 24 24"
    stroke-width="1.5"
    stroke="currentColor"
    data-test-icon="external-link"
    ...attributes
  >
    <path
      stroke-linecap="round"
      stroke-linejoin="round"
      d="M13.5 6H5.25A2.25 2.25 0 0 0 3 8.25v10.5A2.25 2.25 0 0 0 5.25 21h10.5A2.25 2.25 0 0 0 18 18.75V10.5m-10.5 6L21 3m0 0h-5.25M21 3v5.25"
    />
  </svg>
</template>;

/**
 * Wraps whatever glyph is in play. `inline-flex` on the wrapper (the anchor
 * itself stays `inline`, so links still break across lines) means
 * whitespace-only children are discarded by flex layout, and the glyph cannot
 * be nudged off-centre by template formatting.
 */
const Glyph: TOC<{
  Args: { class: string; hasCustomIcon: boolean };
  Blocks: { default: [] };
}> = <template>
  <span class={{@class}} aria-hidden="true" data-test-id="external-link-icon">
    {{! The has-block keyword cannot be read from a getter, so the caller
        decides and passes the answer in. Whitespace here is free: flex layout
        discards whitespace-only children. }}
    {{#if @hasCustomIcon}}{{yield}}{{else}}<IconExternalLink />{{/if}}
  </span>
</template>;

export interface ExternalLinkSignature {
  Args: {
    /** The absolute URL to link to. */
    href: string;

    /**
     * The browsing context to open in. Any frame name is accepted; the four
     * keywords are listed so editors can complete them.
     *
     * @defaultValue '_blank'
     */
    target?: '_blank' | '_self' | '_parent' | '_top' | (string & {});

    /**
     * Replaces the default `rel`. Left off, `noopener noreferrer` is applied
     * whenever the link opens a new browsing context.
     */
    rel?: string;

    /**
     * @defaultValue 'always'
     */
    underline?: 'always' | 'hover' | 'none';

    /**
     * Which side of the text the glyph sits on.
     *
     * @defaultValue 'end'
     */
    iconPlacement?: 'start' | 'end';

    /**
     * Set to `false` to drop the glyph. The `target`, `rel` and new-tab
     * announcement are unaffected.
     *
     * @defaultValue true
     */
    showIcon?: boolean;

    /**
     * The visually-hidden text announced when the link opens a new tab. Pass
     * an empty or blank string to suppress it.
     *
     * @defaultValue '(opens in a new tab)'
     */
    newTabLabel?: string;

    /**
     * Custom class name, it will override the default ones using Tailwind Merge
     * library.
     */
    class?: string;

    /**
     * Custom CSS classes for styling the individual slots: `base` for the
     * anchor, `icon` for the glyph wrapper.
     */
    classes?: SlotsToClasses<ExternalLinkSlots>;
  };
  Element: HTMLAnchorElement;
  Blocks: {
    /** The link text. */
    default: [];

    /** Replaces the built-in glyph, keeping its size and spacing. */
    icon: [];
  };
}

/**
 * A link to another site.
 *
 * It opens a new tab, marks itself with an external-link glyph, protects the
 * opener with `rel="noopener noreferrer"`, and tells assistive technology that
 * a new tab is coming — so the four cannot drift apart. For in-app navigation
 * use `TabNav` or Ember's `LinkTo`.
 */
class ExternalLink extends Component<ExternalLinkSignature> {
  get target(): string {
    return this.args.target ?? '_blank';
  }

  /**
   * Every target but `_self` lands the user somewhere else. Both the `rel`
   * default and the new-tab announcement hang off this, so a `@target='_self'`
   * link neither carries a pointless `rel` nor claims to open a tab it does
   * not.
   */
  get opensNewContext(): boolean {
    return this.target !== '_self';
  }

  /**
   * `??`, not `||`, so an explicit `@rel=""` clears the default rather than
   * falling back to it.
   */
  get rel(): string | undefined {
    return (
      this.args.rel ??
      (this.opensNewContext ? 'noopener noreferrer' : undefined)
    );
  }

  get newTabLabel(): string | undefined {
    if (!this.opensNewContext) {
      return undefined;
    }

    const label = this.args.newTabLabel ?? '(opens in a new tab)';

    // Trimmed, so a whitespace-only label is suppressed like an empty one --
    // it would announce nothing while still adding a node.
    return label.trim() === '' ? undefined : label;
  }

  get showIcon(): boolean {
    return this.args.showIcon !== false;
  }

  get iconAtStart(): boolean {
    return this.showIcon && this.args.iconPlacement === 'start';
  }

  get iconAtEnd(): boolean {
    return this.showIcon && !this.iconAtStart;
  }

  @cached
  get classNames() {
    const { externalLink } = useStyles();
    const { classes } = this.args;

    const { base, icon } = externalLink({
      underline: this.args.underline,
      iconPlacement: this.args.iconPlacement
    });

    return {
      base: base({ class: [classes?.base, this.args.class] }),
      icon: icon({ class: classes?.icon })
    };
  }

  <template>
    {{! No whitespace anywhere inside the anchor: a stray newline collapses to
        a space that the anchor's own underline then draws. The one space that
        is wanted -- separating the link text from the announcement for a
        screen reader -- sits inside the sr-only span, which is out of flow and
        so costs no layout. It is covered by a test, since prettier is told to
        leave this line alone and the space is invisible in review. }}
    {{! prettier-ignore }}
    <a
      href={{@href}}
      target={{this.target}}
      rel={{this.rel}}
      class={{this.classNames.base}}
      data-test-id="external-link"
      data-component="external-link"
      ...attributes
    >{{#if this.iconAtStart}}<Glyph @class={{this.classNames.icon}} @hasCustomIcon={{has-block "icon"}}>{{yield to="icon"}}</Glyph>{{/if}}{{yield}}{{#if this.newTabLabel}}<span class="sr-only" data-test-id="external-link-new-tab-label"> {{this.newTabLabel}}</span>{{/if}}{{#if this.iconAtEnd}}<Glyph @class={{this.classNames.icon}} @hasCustomIcon={{has-block "icon"}}>{{yield to="icon"}}</Glyph>{{/if}}</a>
  </template>
}

export { ExternalLink };
export default ExternalLink;
