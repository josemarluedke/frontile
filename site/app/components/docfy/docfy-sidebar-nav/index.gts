import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { action } from '@ember/object';
import { VisuallyHidden } from 'frontile';
import { Drawer } from 'frontile';
import Content from './content';
import type { NestedPageMetadata } from '@docfy/core/lib/types';

interface Signature {
  Args: {
    node: NestedPageMetadata;
  };
}

export default class SidebarNav extends Component<Signature> {
  @tracked isOpen = false;

  @action toggle(): void {
    this.isOpen = !this.isOpen;
  }

  @action handleSidebarClick(event: Event): void {
    if (this.isOpen) {
      const target = event.target as Element;

      if (['A', 'svg', 'path'].includes(target.tagName)) {
        let parentElement: Element | undefined = target;

        if (target.tagName == 'path') {
          parentElement = target.parentElement?.closest('svg')
            ?.parentElement as Element;
        } else if (target.tagName == 'svg') {
          parentElement = target.parentElement as Element;
        }

        if (
          parentElement &&
          parentElement.hasAttribute('data-ignore-auto-close')
        ) {
          return;
        }

        this.toggle();
      }
    }
  }
  <template>
    <button
      type="button"
      class="fixed z-1 bottom-4 right-4 flex items-center p-4 border rounded-full lg:hidden bg-brand-medium backdrop-filter backdrop-blur bg-opacity-90 text-on-brand-medium border-brand-firm focus-visible:ring outline-none"
      {{on "click" this.toggle}}
    >
      <VisuallyHidden>Contents</VisuallyHidden>
      <svg class="w-8" fill="currentColor" viewBox="0 0 20 20">
        <path
          d="M3 5a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zM3 10a1 1 0 011-1h6a1 1 0 110 2H4a1 1 0 01-1-1zM3 15a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z"
          clip-rule="evenodd"
          fill-rule="evenodd"
        ></path>
      </svg>
    </button>

    <Drawer
      @isOpen={{this.isOpen}}
      @onClose={{this.toggle}}
      @size="xs"
      @allowCloseButton={{false}}
      class="backdrop-filter backdrop-blur bg-opacity-80 outline-none focus-visible:ring ring-inset"
      as |m|
    >
      <m.CloseButton
        class="text-neutral-strong hover:bg-surface-overlay-soft outline-none focus-visible:ring"
      />
      <m.Header class="text-neutral-bolder">
        Contents
      </m.Header>
      <m.Body class="text-neutral-strong">
        <Content @node={{@node}} @onSidebarClick={{this.handleSidebarClick}} />
      </m.Body>
    </Drawer>

    <Content
      @node={{@node}}
      @onSidebarClick={{this.handleSidebarClick}}
      class="overflow-y-auto sticky top-28 max-h-screen-28 pt-12 pb-4 -mt-12 lg:block hidden"
    />
  </template>
}
