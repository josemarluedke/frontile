import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { on } from '@ember/modifier';
import { action } from '@ember/object';
import { VisuallyHidden } from 'frontile';
import { Drawer } from 'frontile';
import IconMenu from '~icons/lucide/menu';
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
      class="fixed z-1 bottom-4 right-4 flex items-center p-4 border rounded-full lg:hidden bg-primary backdrop-filter backdrop-blur bg-opacity-90 text-on-primary border-primary-firm focus-visible:ring outline-none"
      {{on "click" this.toggle}}
    >
      <VisuallyHidden>Contents</VisuallyHidden>
      <IconMenu class="size-8" />
    </button>

    {{! Drag-to-close is opt-in for side placements, so ask for it here: this
        panel is opened by thumb on a phone, and a swipe back toward the edge
        it came from is the gesture people already expect there. The handle it
        adds is a real button, so nothing depends on the gesture alone.

        The body padding is tightened from the component default (24px/32px).
        That default is sized for prose in a content drawer; this body is a
        nav list whose rows carry their own touch targets, and the full
        padding pushed the first item a long way below the header. }}
    <Drawer
      @isOpen={{this.isOpen}}
      @onClose={{this.toggle}}
      @size="xs"
      @allowDragToClose={{true}}
      @classes={{hash body="px-4 py-2"}}
      class="outline-none focus-visible:ring ring-inset"
      as |m|
    >
      <m.Header>
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
