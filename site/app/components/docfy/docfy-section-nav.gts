import Component from '@glimmer/component';
import { service } from '@ember/service';
import { hash } from '@ember/helper';
import { DocfyLink, DocfyOutput } from '@docfy/ember';
import { TabNav } from 'frontile';
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
      <div class="sticky top-16 z-10 -mx-4 lg:-mx-6 mb-6 lg:mb-8">
        <div
          class="bg-surface-canvas backdrop-blur-xl backdrop-saturate-150 px-4 lg:px-6 pt-3 lg:pt-4"
        >
          <TabNav
            @label="Documentation sections"
            @variant="underline"
            @intent="primary"
            @size="sm"
            @classes={{hash list="overflow-x-auto scrollbar-hide"}}
            as |tabNav|
          >
            {{#each node.children as |child|}}
              {{#let (this.getFirstPageUrl child) as |url|}}
                {{#if url}}
                  <DocfyLink
                    @to={{url}}
                    class={{tabNav.itemClass}}
                    {{tabNav.setupItem (this.isActive child)}}
                  >
                    {{child.label}}
                  </DocfyLink>
                {{/if}}
              {{/let}}
            {{/each}}
          </TabNav>
        </div>
      </div>
    </DocfyOutput>
  </template>
}
