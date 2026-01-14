import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import { concat } from '@ember/helper';
import { service } from '@ember/service';
import DocfyLink from '@docfy/ember/components/docfy-link';
import { Chip } from 'frontile';
import type { NestedPageMetadata } from '@docfy/core/lib/types';
import type RouterService from '@ember/routing/router-service';
import type Owner from '@ember/owner';

interface Signature {
  Args: {
    onSidebarClick: (event: MouseEvent) => void;
    node: NestedPageMetadata;
  };
  Element: HTMLDivElement;
}

class Label extends Component<{ Args: { label: unknown } }> {
  get intent() {
    if (typeof this.args.label !== 'string') {
      return 'default';
    }

    if (this.args.label.toLowerCase() == 'new') {
      return 'default';
    } else if (this.args.label.toLowerCase() == 'updated') {
      return 'success';
    } else if (this.args.label.toLowerCase() == 'deprecated') {
      return 'danger';
    } else {
      return 'default';
    }
  }

  get label() {
    return typeof this.args.label === 'string' ? this.args.label : '';
  }

  <template>
    <Chip
      @size="sm"
      @appearance="faded"
      @intent={{this.intent}}
      @class="ml-1 !text-[10px] !px-1.5 !py-0 !h-4 !min-h-4"
    >
      {{this.label}}
    </Chip>
  </template>
}

export default class DocfySidebarNavContent extends Component<Signature> {
  @service declare router: RouterService;
  @tracked expandedSections = new Set<string>();

  constructor(owner: Owner, args: Signature['Args']) {
    super(owner, args);
    this.initializeExpandedSections();
  }

  initializeExpandedSections() {
    const currentURL = this.router.currentURL;
    const sectionsToExpand = new Set<string>();

    // Check all children for nested pages that match current URL
    this.args.node.children?.forEach((child) => {
      child.children?.forEach((subChild) => {
        const hasCurrentPage = subChild.pages?.some((page) => {
          return currentURL === page.url || currentURL?.startsWith(page.url);
        });

        if (hasCurrentPage) {
          const sectionKey = `${child.label}-${subChild.label}`;
          sectionsToExpand.add(sectionKey);
        }
      });
    });

    this.expandedSections = sectionsToExpand;
  }

  @action
  toggleSection(sectionKey: string) {
    if (this.expandedSections.has(sectionKey)) {
      // If section is expanded, collapse it
      this.expandedSections.delete(sectionKey);
    } else {
      // If section is collapsed, expand it and navigate to first page if not already in section
      this.expandedSections.add(sectionKey);

      // Check if current page is in this section
      const currentURL = this.router.currentURL;
      const isCurrentlyInSection = this.isCurrentPageInSection(
        sectionKey,
        currentURL
      );

      if (!isCurrentlyInSection) {
        // Navigate to first page in the section
        const firstPageUrl = this.getFirstPageInSection(sectionKey);
        if (firstPageUrl) {
          this.router.transitionTo(firstPageUrl);
        }
      }
    }
    this.expandedSections = new Set(this.expandedSections);
  }

  private isCurrentPageInSection(
    sectionKey: string,
    currentURL: string | null
  ): boolean {
    const [childLabel, subChildLabel] = sectionKey.split('-');

    // Find the matching section
    const child = this.args.node.children?.find((c) => c.label === childLabel);
    const subChild = child?.children?.find((sc) => sc.label === subChildLabel);

    return (
      subChild?.pages?.some(
        (page) => currentURL === page.url || currentURL?.startsWith(page.url)
      ) ?? false
    );
  }

  private getFirstPageInSection(sectionKey: string): string | null {
    const [childLabel, subChildLabel] = sectionKey.split('-');

    // Find the matching section
    const child = this.args.node.children?.find((c) => c.label === childLabel);
    const subChild = child?.children?.find((sc) => sc.label === subChildLabel);

    return subChild?.pages?.[0]?.url ?? null;
  }

  @action
  isExpanded(sectionKey: string) {
    return this.expandedSections.has(sectionKey);
  }
  <template>
    <div ...attributes>
      {{! template-lint-disable no-invalid-interactive }}
      <nav class="space-y-6" {{on "click" @onSidebarClick}}>
        {{! template-lint-enable no-invalid-interactive }}

        {{#if @node.pages}}
          <div>
            <ul class="space-y-0">
              {{#each @node.pages as |page|}}
                <li>
                  <DocfyLink
                    @to={{page.url}}
                    class="transition flex items-center px-6 py-1.5 text-sm text-neutral-medium hover:text-neutral-strong hover:bg-brand-subtle/20 outline-none focus-visible:ring-2 focus-visible:ring-brand-soft rounded"
                    @activeClass="bg-brand-soft/20 text-neutral-strong font-medium"
                  >
                    {{page.title}}
                  </DocfyLink>
                </li>
              {{/each}}
            </ul>
          </div>
        {{/if}}

        {{#each @node.children as |child|}}
          <div>
            <h3 class="px-6 py-1.5 text-base font-semibold">
              {{child.label}}
            </h3>

            <ul class="space-y-0">
              {{#each child.pages as |page|}}
                <li>
                  <DocfyLink
                    @to={{page.url}}
                    class="transition flex items-center px-6 py-1.5 text-sm text-neutral-medium hover:text-neutral-strong hover:bg-brand-subtle/20 outline-none focus-visible:ring-2 focus-visible:ring-brand-soft rounded"
                    @activeClass="bg-brand-soft/20 text-neutral-strong font-medium"
                  >
                    {{page.title}}
                    {{#if page.frontmatter.label}}
                      <Label @label={{page.frontmatter.label}} />
                    {{/if}}
                  </DocfyLink>
                </li>
              {{/each}}

              {{#each child.children as |subChild|}}
                <li>
                  <button
                    type="button"
                    class="flex w-full items-center justify-between px-6 py-1.5 text-left text-sm text-neutral-medium hover:text-neutral-strong hover:bg-neutral-subtle outline-none focus-visible:ring-2 focus-visible:ring-brand-soft rounded"
                    {{on
                      "click"
                      (fn
                        this.toggleSection
                        (concat child.label "-" subChild.label)
                      )
                    }}
                  >
                    <span>{{subChild.label}}</span>
                    <svg
                      class="h-3 w-3 transition-transform
                        {{if
                          (this.isExpanded
                            (concat child.label '-' subChild.label)
                          )
                          'rotate-90'
                          ''
                        }}"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M9 5l7 7-7 7"
                      />
                    </svg>
                  </button>

                  {{#if
                    (this.isExpanded (concat child.label "-" subChild.label))
                  }}
                    <ul class="space-y-0">
                      {{#each subChild.pages as |page|}}
                        <li>
                          <DocfyLink
                            @to={{page.url}}
                            class="transition flex items-center px-6 py-1.5 text-sm text-neutral-medium hover:text-neutral-strong hover:bg-brand-subtle/20 outline-none focus-visible:ring-2 focus-visible:ring-brand-soft rounded"
                            @activeClass="bg-brand-soft/20 text-neutral-strong font-medium"
                          >
                            {{page.title}}
                          </DocfyLink>
                        </li>
                      {{/each}}
                    </ul>
                  {{/if}}
                </li>
              {{/each}}
            </ul>
          </div>
        {{/each}}
      </nav>
    </div>
  </template>
}
