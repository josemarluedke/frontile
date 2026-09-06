import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import pageTitle from 'ember-page-title/helpers/page-title';
import SidebarNav from './docfy-sidebar-nav';
import PageHeadings from './docfy-page-headings';
import DocfySectionNav from './docfy-section-nav';
import docfyIntersectHeadings from '../../modifiers/docfy-intersect-headings';
import DocfyCopyPage from './docfy-copy-page';
import { DocfyLink, DocfyOutput, DocfyPreviousAndNextPage } from '@docfy/ember';
import IconPencil from '~icons/lucide/pencil';
import IconArrowLeft from '~icons/lucide/arrow-left';
import IconArrowRight from '~icons/lucide/arrow-right';

interface Signature {
  Args: {
    scope: string;
    showSectionNav?: boolean;
  };
  Blocks: {
    default: [];
  };
}

export default class DocfyPage extends Component<Signature> {
  @tracked currentHeadingId?: string;

  setCurrentHeadingId = (id: string): void => {
    this.currentHeadingId = id;
  };

  <template>
    <div class="px-4 mx-auto lg:px-6 max-w-screen-2xl pb-16">
      <DocfyOutput @fromCurrentURL={{true}} as |page|>
        {{pageTitle "Documentation"}}
        {{pageTitle page.title}}
      </DocfyOutput>

      {{#if @showSectionNav}}
        <DocfySectionNav />
      {{/if}}

      <div class="relative lg:flex">
        <div class="flex-none pr-4 lg:w-64">
          <DocfyOutput @scope={{@scope}} as |node|>
            <SidebarNav @node={{node}} />
          </DocfyOutput>
        </div>

        <div class="flex-1 w-full min-w-0 px-0 pt-12 lg:px-10 relative">
          <DocfyOutput @fromCurrentURL={{true}} as |page|>
            <div class="top-0 right-0 absolute lg:pr-10 pt-14">
              <DocfyCopyPage @url={{page.url}} @title={{page.title}} />
            </div>
            <div
              {{docfyIntersectHeadings
                onIntersect=this.setCurrentHeadingId
                headings=page.headings
              }}
            >
              {{yield}}
            </div>
          </DocfyOutput>

          <div class="flex justify-between mt-10">
            <DocfyOutput @fromCurrentURL={{true}} as |page|>
              {{#if page.editUrl}}
                <a
                  href={{page.editUrl}}
                  target="_blank"
                  rel="noopener noreferrer"
                  class="flex items-center text-xs text-neutral-firm hover:text-primary"
                >
                  <IconPencil class="size-4 mr-2" />
                  Edit this page on GitHub
                </a>
              {{/if}}
            </DocfyOutput>
          </div>

          <div
            class="flex flex-wrap justify-between mt-5 mb-10 border-t border-neutral-subtle"
          >
            <DocfyPreviousAndNextPage as |previous next|>
              <div class="flex items-center pt-6 pr-2">
                {{#if previous}}
                  <IconArrowLeft class="size-4 mr-2" />

                  <DocfyLink
                    @to={{previous.url}}
                    class="text-lg text-primary hover:text-primary-strong"
                  >
                    {{previous.title}}
                  </DocfyLink>
                {{/if}}
              </div>
              <div class="flex items-center pt-6 pl-2">
                {{#if next}}
                  <DocfyLink
                    @to={{next.url}}
                    class="text-lg text-primary hover:text-primary-strong"
                  >
                    {{next.title}}
                  </DocfyLink>

                  <IconArrowRight class="size-4 ml-2" />
                {{/if}}
              </div>
            </DocfyPreviousAndNextPage>
          </div>
        </div>
        <div class="flex-none hidden w-56 pl-4 lg:block">
          <PageHeadings @currentHeadingId={{this.currentHeadingId}} />
        </div>
      </div>
    </div>
  </template>
}
