import type { TOC } from '@ember/component/template-only';

export interface Signature {
  Args: {
    /** The accent label above the heading. */
    eyebrow: string;
    /** The section heading. */
    title: string;
    /**
     * Hold the heading at one step down. For a section whose header sits in a
     * narrow column rather than across the page.
     */
    isCompact?: boolean;
  };
  Blocks: {
    /** The supporting sentence below the heading. */
    default: [];
  };
  Element: HTMLDivElement;
}

/**
 * The three-part opening every section on this page shares: an accent eyebrow,
 * a heading, and one supporting sentence.
 *
 * It exists because the typography here is a contract, not a set of choices —
 * the eyebrow is the only page-scale use of the `label` role, the heading is
 * the `header` role two steps below the hero's marquee, and the lede is
 * deliberately smaller than the hero's so nothing outranks it. Written by hand
 * at each section, that contract drifted within a single sitting.
 *
 * The wrapper is the reveal target, so a section's header animates in as one
 * block rather than three. Its measure is left to the call site, since the
 * page's headers sit in columns of three different widths.
 */
const SectionIntro: TOC<Signature> = <template>
  <div class="reveal" ...attributes>
    <p class="eyebrow mb-4">{{@eyebrow}}</p>
    <h2
      class="font-header text-header-2xl text-neutral-bolder text-balance
        {{unless @isCompact 'sm:text-header-3xl'}}"
    >{{@title}}</h2>
    <p class="mt-4 font-body text-body-sm text-neutral-firm text-pretty">
      {{yield}}
    </p>
  </div>
</template>;

export default SectionIntro;
