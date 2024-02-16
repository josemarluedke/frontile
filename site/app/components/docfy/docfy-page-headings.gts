import Component from '@glimmer/component';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import DocfyOutput from '@docfy/ember/components/docfy-output';
import docfyEq from '@docfy/ember/helpers/docfy-eq';

// http://goo.gl/5HLl8
const easeInOutQuad = (t: number, b: number, c: number, d: number): number => {
  t /= d / 2;
  if (t < 1) {
    return (c / 2) * t * t + b;
  }
  t--;
  return (-c / 2) * (t * (t - 2) - 1) + b;
};

function scrollTo(
  toPosition: number,
  callback?: () => void,
  duration = 500
): void {
  const scrollingElement = document.scrollingElement
    ? document.scrollingElement
    : document.body;
  const startPosition = scrollingElement.scrollTop;
  const change = toPosition - startPosition;
  let currentTime = 0;
  const increment = 20;

  const animateScroll = (): void => {
    currentTime += increment;
    scrollingElement.scrollTop = easeInOutQuad(
      currentTime,
      startPosition,
      change,
      duration
    );

    if (currentTime < duration) {
      requestAnimationFrame(animateScroll);
    } else {
      if (callback && typeof callback === 'function') {
        callback();
      }
    }
  };
  animateScroll();
}

function scrollToElement(
  element: HTMLElement,
  callback?: () => void,
  duration = 500
): void {
  const toPosition = element.offsetTop;
  scrollTo(toPosition, callback, duration);
}

interface Signature {
  Args: {
    currentHeadingId?: string;
  };
}

export default class PageHeadings extends Component<Signature> {
  @action onClick(evt: MouseEvent): void {
    const href = (evt.target as HTMLElement).getAttribute('href');
    if (href) {
      const toElement = document.querySelector(href) as HTMLElement;

      scrollToElement(toElement);
    }
  }
  <template>
    <div
      class="overflow-y-auto sticky top-16 max-h-(screen-16) pt-12 pb-4 -mt-12 text-sm"
    >
      <DocfyOutput @fromCurrentURL={{true}} as |page|>
        {{#if page.headings.length}}
          <ul>
            {{#each page.headings as |heading|}}
              <li class="pb-2 border-l border-gray-400 dark:border-gray-700">
                <a
                  href="#{{heading.id}}"
                  class="transition block px-2 py-1 border-l-2 hover:text-primary-700 dark:hover:text-primary-300
                    {{if
                      (docfyEq heading.id @currentHeadingId)
                      'border-primary-700 text-primary-700 dark:border-primary-400 dark:text-primary-400'
                      'border-transparent'
                    }}"
                  {{on "click" this.onClick}}
                >
                  {{heading.title}}
                </a>

                {{#if heading.headings.length}}
                  <ul class="">
                    {{#each heading.headings as |subHeading|}}
                      <li>
                        <a
                          href="#{{subHeading.id}}"
                          class="transition block pl-6 py-1 border-l-2 hover:text-primary-700 dark:hover:text-primary-300
                            {{if
                              (docfyEq subHeading.id @currentHeadingId)
                              'border-primary-700 text-primary-700 dark:border-primary-400 dark:text-primary-400'
                              'border-transparent'
                            }}"
                          {{on "click" this.onClick}}
                        >
                          {{subHeading.title}}
                        </a>
                      </li>
                    {{/each}}
                  </ul>
                {{/if}}
              </li>
            {{/each}}
          </ul>
        {{/if}}
      </DocfyOutput>
    </div>
  </template>
}
