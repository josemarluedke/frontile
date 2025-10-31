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
      class="fixed z-1 bottom-4 right-4 flex items-center p-4 border rounded-full lg:hidden bg-default-400 backdrop-filter backdrop-blur bg-opacity-70 text-white border-default-700 focus-visible:ring outline-none"
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
        class="dark:text-white hover:bg-default-800 outline-none focus-visible:ring"
      />
      <m.Header class="text-foreground">
        Contents
      </m.Header>
      <m.Body class="dark:text-white">
        <Content @node={{@node}} @onSidebarClick={{this.handleSidebarClick}} />
      </m.Body>
    </Drawer>

    <Content
      @node={{@node}}
      @onSidebarClick={{this.handleSidebarClick}}
      class="overflow-y-auto sticky top-16 max-h-screen-16 pt-4 pt-8 pb-4 lg:block hidden"
    />
  </template>
}
