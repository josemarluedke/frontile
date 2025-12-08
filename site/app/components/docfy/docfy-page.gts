import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import pageTitle from 'ember-page-title/helpers/page-title';
import SidebarNav from './docfy-sidebar-nav';
import PageHeadings from './docfy-page-headings';
import DocsSectionNav from './docs-section-nav';
import docfyIntersectHeadings from '../../modifiers/docfy-intersect-headings';
import { DocfyLink, DocfyPreviousAndNextPage, DocfyOutput } from '@docfy/ember';

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
        <DocsSectionNav />
      {{/if}}

      <div class="relative lg:flex">
        <div class="flex-none pr-4 lg:w-64">
          <DocfyOutput @scope={{@scope}} as |node|>
            <SidebarNav @node={{node}} />
          </DocfyOutput>
        </div>

        <div class="flex-1 w-full min-w-0 px-0 pt-12 lg:px-10">
          <DocfyOutput @fromCurrentURL={{true}} as |page|>
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
                  class="flex items-center text-xs hover:text-brand-medium dark:hover:text-primary-400"
                >
                  <svg class="w-4 mr-2" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      d="M13.586 3.586a2 2 0 112.828 2.828l-.793.793-2.828-2.828.793-.793zM11.379 5.793L3 14.172V17h2.828l8.38-8.379-2.83-2.828z"
                    ></path>
                  </svg>
                  Edit this page on GitHub
                </a>
              {{/if}}
            </DocfyOutput>
          </div>

          <div
            class="flex flex-wrap justify-between mt-5 mb-10 border-t border-gray-400 dark:border-gray-800"
          >
            <DocfyPreviousAndNextPage as |previous next|>
              <div class="flex items-center pt-6 pr-2">
                {{#if previous}}
                  <svg class="h-4 mr-2" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      d="M7.707 14.707a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 1.414L5.414 9H17a1 1 0 110 2H5.414l2.293 2.293a1 1 0 010 1.414z"
                      clip-rule="evenodd"
                      fill-rule="evenodd"
                    ></path>
                  </svg>

                  <DocfyLink
                    @to={{previous.url}}
                    class="text-lg text-brand-medium hover:text-brand-strong dark:text-primary-400 dark:hover:text-primary-300"
                  >
                    {{previous.title}}
                  </DocfyLink>
                {{/if}}
              </div>
              <div class="flex items-center pt-6 pl-2">
                {{#if next}}
                  <DocfyLink
                    @to={{next.url}}
                    class="text-lg text-brand-medium hover:text-brand-strong dark:text-primary-400 dark:hover:text-primary-300"
                  >
                    {{next.title}}
                  </DocfyLink>

                  <svg class="h-4 ml-2" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      d="M12.293 5.293a1 1 0 011.414 0l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-2.293-2.293a1 1 0 010-1.414z"
                      clip-rule="evenodd"
                      fill-rule="evenodd"
                    ></path>
                  </svg>
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
