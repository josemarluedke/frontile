import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { LinkTo } from '@ember/routing';
import { Collapsible, VisuallyHidden } from 'frontile';
import DocfyThemeSwitcher from './docfy-theme-switcher';
import IconMenu from '~icons/lucide/menu';
import IconX from '~icons/lucide/x';

/**
 * The site's global chrome, in three regions.
 *
 * Left is identity — the wordmark with the version docked to it, so the pair
 * reads as "Frontile v0.17" rather than as a wordmark plus an anonymous
 * control. Centre is search, which is the single most-used control on a
 * reference site and so is given the middle rather than being tucked against
 * the logo. Right is navigation and utilities.
 *
 * The two flanking regions are `flex-1`, which is what holds the centre region
 * on the actual centre line regardless of how wide the left and right contents
 * grow.
 *
 * Below `md` the primary links and GitHub move into a disclosure panel under
 * the bar; the version dropdown, search and theme switcher stay in the bar
 * itself, because losing the ability to switch versions on a phone is how the
 * previous header failed.
 */

interface DocfyHeaderSignature {
  Args: {
    indexRoute?: string;
    githubUrl: string;
    disableThemeSwitcher?: boolean;
  };
  Blocks: {
    /** The wordmark, linked to the index route. */
    title: [];
    /** Docked to the wordmark — the version dropdown. */
    brand: [];
    /** The centre region — search. */
    center: [];
    /**
     * Primary destinations. Yielded twice: once into the desktop bar and once
     * into the mobile panel, with the classes for that shape.
     */
    nav: [string];
  };
  Element: HTMLElement;
}

/*
 * Active styling hangs off `aria-current`, not off a second class appended by
 * the consumer. Two plain utilities setting the same property — `border-transparent`
 * and `border-primary-soft` — are decided by the order Tailwind emits them,
 * not by the order they appear in the attribute, and the transparent one wins:
 * the previous header's active link silently never lit. An `aria-[current=page]:`
 * variant carries an extra attribute selector, so it outranks the base utility
 * by specificity and cannot lose. It also keeps the visual state and the state
 * announced to assistive tech from drifting apart, since they are now the same
 * fact.
 */
/*
 * Emphasis runs the way the token scale does: `firm` at rest, `strong` — a
 * step up, not down — for hover and for current. The header this replaces had
 * the pair inverted, so the current link was painted *lighter* than its
 * neighbours.
 *
 * The rule under a current link is `border-primary`, the solid resting fill.
 * `primary-soft` is a 10%-alpha surface wash meant for fills and decorative
 * borders; as a 2px underline it reads as nothing at all.
 */
const BAR_LINK =
  'text-neutral-firm transition pb-1.5 pt-1.5 border-b-2 border-transparent hover:border-primary-mild hover:text-neutral-strong outline-none focus-visible:ring aria-[current=page]:border-primary aria-[current=page]:text-neutral-strong';

const PANEL_LINK =
  'flex items-center rounded-lg px-3 py-2.5 text-base text-neutral-firm transition hover:bg-neutral-subtle hover:text-neutral-strong outline-none focus-visible:ring aria-[current=page]:bg-neutral-subtle aria-[current=page]:text-neutral-strong aria-[current=page]:font-medium';

export default class DocfyHeader extends Component<DocfyHeaderSignature> {
  @tracked isMenuOpen = false;

  @action toggleMenu(): void {
    this.isMenuOpen = !this.isMenuOpen;
  }

  @action closeMenu(): void {
    this.isMenuOpen = false;
  }

  /**
   * The panel holds nothing but links, so any click inside it is a navigation
   * and the panel should get out of the way. Keyed off the container rather
   * than each link so a link added later needs no wiring.
   */
  @action handlePanelClick(): void {
    this.closeMenu();
  }

  @action handleKeydown(event: KeyboardEvent): void {
    if (event.key === 'Escape') {
      this.closeMenu();
    }
  }

  <template>
    <div class="sticky top-0 z-1">
      <header
        class="h-16 border-b border-neutral-subtle/50 bg-neutral-subtle/60 backdrop-blur-xl backdrop-saturate-150"
        ...attributes
      >
        <div
          class="flex items-center h-full gap-3 px-4 mx-auto sm:px-6 max-w-screen-2xl"
        >
          <div
            class="flex items-center gap-2 sm:gap-3 shrink-0 md:flex-1 md:min-w-0"
          >
            <LinkTo
              @route={{if @indexRoute @indexRoute "index"}}
              class="text-neutral-firm text-lg font-bold outline-none focus-visible:ring shrink-0"
            >
              {{yield to="title"}}
            </LinkTo>

            {{! Below sm the bar cannot hold the wordmark, the version, search,
                the theme control and the menu button at once — it overflowed by
                40px and pushed the menu button off-screen. The version is the
                one of those a phone reader needs least often, so it moves into
                the panel rather than any of them being dropped. }}
            <div class="hidden sm:flex sm:items-center">
              {{yield to="brand"}}
            </div>
          </div>

          {{! Dead-centre only from md up, where the flanking flex-1 regions can
              hold it there. On a phone there is no middle to give away: the
              search collapses to an icon and joins the right-hand cluster. }}
          <div class="flex justify-center ml-auto shrink-0 md:ml-0">
            {{yield to="center"}}
          </div>

          <div
            class="flex items-center justify-end gap-1 shrink-0 sm:gap-2 md:flex-1"
          >
            <nav
              aria-label="Primary"
              class="items-center hidden gap-6 mr-1 md:flex"
            >
              {{yield BAR_LINK to="nav"}}
            </nav>

            <span
              aria-hidden="true"
              class="hidden w-px h-5 mx-1 md:block bg-neutral-soft"
            ></span>

            <a
              href={{@githubUrl}}
              target="_blank"
              rel="noopener noreferrer"
              class="hidden p-1.5 transition rounded-lg md:inline-flex text-neutral-firm outline-none focus-visible:ring hover:text-neutral-strong hover:bg-neutral-subtle"
            >
              <svg viewBox="0 0 20 20" class="w-5 h-5 fill-current">
                <title>
                  Frontile on GitHub
                </title>
                <path
                  d="M10 0a10 10 0 0 0-3.16 19.49c.5.1.68-.22.68-.48l-.01-1.7c-2.78.6-3.37-1.34-3.37-1.34-.46-1.16-1.11-1.47-1.11-1.47-.9-.62.07-.6.07-.6 1 .07 1.53 1.03 1.53 1.03.9 1.52 2.34 1.08 2.91.83.1-.65.35-1.09.63-1.34-2.22-.25-4.55-1.11-4.55-4.94 0-1.1.39-1.99 1.03-2.69a3.6 3.6 0 0 1 .1-2.64s.84-.27 2.75 1.02a9.58 9.58 0 0 1 5 0c1.91-1.3 2.75-1.02 2.75-1.02.55 1.37.2 2.4.1 2.64.64.7 1.03 1.6 1.03 2.69 0 3.84-2.34 4.68-4.57 4.93.36.31.68.92.68 1.85l-.01 2.75c0 .26.18.58.69.48A10 10 0 0 0 10 0"
                ></path>
              </svg>
            </a>

            {{#unless @disableThemeSwitcher}}
              <DocfyThemeSwitcher />
            {{/unless}}

            <button
              type="button"
              aria-expanded={{if this.isMenuOpen "true" "false"}}
              aria-controls="site-menu"
              class="p-1.5 transition rounded-lg md:hidden text-neutral-firm outline-none focus-visible:ring hover:text-neutral-strong hover:bg-neutral-subtle"
              {{on "click" this.toggleMenu}}
              {{on "keydown" this.handleKeydown}}
            >
              <VisuallyHidden>
                {{if this.isMenuOpen "Close menu" "Open menu"}}
              </VisuallyHidden>
              {{#if this.isMenuOpen}}
                <IconX aria-hidden="true" class="size-5" />
              {{else}}
                <IconMenu aria-hidden="true" class="size-5" />
              {{/if}}
            </button>
          </div>
        </div>
      </header>

      <div class="md:hidden">
        <Collapsible @isOpen={{this.isMenuOpen}}>
          {{! template-lint-disable no-invalid-interactive }}
          <div
            id="site-menu"
            class="flex flex-col gap-1 px-4 py-3 border-b border-neutral-subtle/50 bg-neutral-subtle/95 backdrop-blur-xl backdrop-saturate-150"
            {{on "click" this.handlePanelClick}}
            {{on "keydown" this.handleKeydown}}
          >
            <div class="flex px-3 pt-1 pb-3 sm:hidden">
              {{yield to="brand"}}
            </div>

            {{! Distinct from the bar's "Primary": both navs are in the DOM at
                once (the panel collapses rather than unmounts), and two
                same-named landmarks would leave a screen reader unable to
                tell them apart. }}
            <nav aria-label="Site menu" class="flex flex-col gap-1">
              {{yield PANEL_LINK to="nav"}}
            </nav>

            <span aria-hidden="true" class="h-px my-2 bg-neutral-soft"></span>

            <a
              href={{@githubUrl}}
              target="_blank"
              rel="noopener noreferrer"
              class={{PANEL_LINK}}
            >
              <svg
                aria-hidden="true"
                viewBox="0 0 20 20"
                class="w-5 h-5 mr-3 fill-current"
              >
                <path
                  d="M10 0a10 10 0 0 0-3.16 19.49c.5.1.68-.22.68-.48l-.01-1.7c-2.78.6-3.37-1.34-3.37-1.34-.46-1.16-1.11-1.47-1.11-1.47-.9-.62.07-.6.07-.6 1 .07 1.53 1.03 1.53 1.03.9 1.52 2.34 1.08 2.91.83.1-.65.35-1.09.63-1.34-2.22-.25-4.55-1.11-4.55-4.94 0-1.1.39-1.99 1.03-2.69a3.6 3.6 0 0 1 .1-2.64s.84-.27 2.75 1.02a9.58 9.58 0 0 1 5 0c1.91-1.3 2.75-1.02 2.75-1.02.55 1.37.2 2.4.1 2.64.64.7 1.03 1.6 1.03 2.69 0 3.84-2.34 4.68-4.57 4.93.36.31.68.92.68 1.85l-.01 2.75c0 .26.18.58.69.48A10 10 0 0 0 10 0"
                ></path>
              </svg>
              GitHub
            </a>
          </div>
        </Collapsible>
      </div>
    </div>
  </template>
}
