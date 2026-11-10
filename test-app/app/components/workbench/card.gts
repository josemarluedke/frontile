import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { modifier } from 'ember-modifier';
import { Button } from 'frontile';

export interface WorkbenchCardSection {
  /** Appended to the card id: the chip links to `#{cardId}-{id}`. */
  id: string;
  label: string;
}

export interface WorkbenchCardSignature {
  Args: {
    /** The element id, and the anchor that **Copy link** points at. */
    id: string;
    title: string;
    description: string;
    /** One chip per entry, linking to `#{@id}-{section.id}`. */
    sections: WorkbenchCardSection[];
  };
  Blocks: { default: [] };
  Element: HTMLElement;
}

/**
 * One component's page in the workbench: a header band with the title,
 * description, section chips and a **Copy link** button, then the body.
 */
export default class WorkbenchCard extends Component<WorkbenchCardSignature> {
  @tracked copied = false;
  /** Set when the clipboard is unavailable, so the URL can be copied by hand. */
  @tracked fallbackUrl: string | null = null;

  get url(): string {
    const { origin, pathname, search } = window.location;
    return `${origin}${pathname}${search}#${this.args.id}`;
  }

  copyLink = async (): Promise<void> => {
    const url = this.url;
    try {
      // `navigator.clipboard` is undefined outside secure contexts; the
      // TypeError lands in the same fallback as a rejected write.
      await navigator.clipboard.writeText(url);
      this.fallbackUrl = null;
      this.copied = true;
    } catch {
      this.copied = false;
      this.fallbackUrl = url;
    }
  };

  selectOnInsert = modifier((input: HTMLInputElement) => {
    input.focus();
    input.select();
  });

  <template>
    <article
      id={{@id}}
      data-workbench-card
      class="bg-surface-card border-neutral-soft scroll-mt-4 overflow-hidden rounded-xl border"
      ...attributes
    >
      <header
        class="bg-neutral-subtle border-neutral-soft flex flex-col gap-3 border-b px-5 py-4"
      >
        <div class="flex items-start justify-between gap-4">
          <div class="flex min-w-0 flex-col gap-1">
            <h2
              class="text-neutral-bolder text-lg font-semibold"
            >{{@title}}</h2>
            <p class="text-neutral-firm text-sm">{{@description}}</p>
          </div>
          <Button
            @size="xs"
            @variant="outline"
            @color="neutral"
            data-workbench-copy-link
            {{on "click" this.copyLink}}
          >
            {{if this.copied "Copied" "Copy link"}}
          </Button>
        </div>
        {{#if this.fallbackUrl}}
          <label class="text-neutral-firm flex flex-col gap-1 text-xs">
            Copy this link:
            <input
              type="text"
              readonly
              value={{this.fallbackUrl}}
              data-workbench-copy-fallback
              class="bg-surface-input border-neutral-soft text-neutral-strong rounded-md border px-2 py-1 font-mono"
              {{this.selectOnInsert}}
            />
          </label>
        {{/if}}
        {{#if @sections.length}}
          <nav aria-label="{{@title}} sections" class="flex flex-wrap gap-1.5">
            {{#each @sections as |section|}}
              <a
                href="#{{@id}}-{{section.id}}"
                data-workbench-chip
                class="border-neutral-soft text-neutral-strong hover:bg-neutral-muted rounded-full border px-2.5 py-0.5 text-xs font-medium"
              >{{section.label}}</a>
            {{/each}}
          </nav>
        {{/if}}
      </header>
      <div class="flex flex-col gap-6 px-5 py-5">
        {{yield}}
      </div>
    </article>
  </template>
}
