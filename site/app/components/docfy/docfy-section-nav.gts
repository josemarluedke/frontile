import Component from '@glimmer/component';
import { service } from '@ember/service';
import { DocfyOutput } from '@docfy/ember';
import DocfyLink from '@docfy/ember/components/docfy-link';
import type { NestedPageMetadata } from '@docfy/core/lib/types';
import type RouterService from '@ember/routing/router-service';

export default class DocfySectionNav extends Component {
  @service declare router: RouterService;

  getFirstPageUrl = (section: NestedPageMetadata): string | null => {
    // If section has direct pages, use the first one
    if (section.pages && section.pages.length > 0) {
      return section.pages[0].url;
    }

    // If section has children, find first page in first child
    if (section.children && section.children.length > 0) {
      return this.getFirstPageUrl(section.children[0]);
    }

    return null;
  };

  isActive = (section: NestedPageMetadata): boolean => {
    const currentUrl = this.router.currentURL;
    const firstPageUrl = this.getFirstPageUrl(section);

    if (!firstPageUrl) return false;

    // Extract the section path (e.g., "/docs/theming" from "/docs/theming/overview")
    const sectionPath = firstPageUrl.split('/').slice(0, 3).join('/');
    return currentUrl.startsWith(sectionPath);
  };

  <template>
    <DocfyOutput @scope="docs" as |node|>
      <nav class="sticky top-16 z-10 -mx-4 lg:-mx-6 mb-6 lg:mb-8">
        <div
          class="border-b border-neutral-subtle/50 bg-background/95 backdrop-blur-xl backdrop-saturate-150 px-4 lg:px-6 pt-3 lg:pt-4"
        >
          <div class="flex gap-4 lg:gap-8 overflow-x-auto scrollbar-hide">
            {{#each node.children as |child|}}
              {{#let (this.getFirstPageUrl child) as |url|}}
                {{#if url}}
                  <DocfyLink
                    @to={{url}}
                    class="pb-3 lg:pb-4 text-xs lg:text-sm font-medium transition-colors text-neutral-soft hover:text-neutral-strong hover:border-b-2 hover:border-brand-soft hover:-mb-px whitespace-nowrap
                      {{if
                        (this.isActive child)
                        'text-neutral-strong border-b-2 border-brand-strong -mb-px'
                      }}"
                  >
                    {{child.label}}
                  </DocfyLink>
                {{/if}}
              {{/let}}
            {{/each}}
          </div>
        </div>
      </nav>
    </DocfyOutput>
  </template>
}
