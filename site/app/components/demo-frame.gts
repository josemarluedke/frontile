import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { htmlSafe } from '@ember/template';
import { schedule } from '@ember/runloop';
import { modifier } from 'ember-modifier';
import { Button, Modal, SegmentedControl } from 'frontile';
import IconMaximize from '~icons/lucide/maximize-2';
import IconExternalLink from '~icons/lucide/external-link';

/** The query parameter that puts a page in frame mode for one demo. */
const PARAM = 'demo-frame';

const WIDTHS = {
  phone: '390px',
  tablet: '768px',
  desktop: '100%',
} as const;

type Width = keyof typeof WIDTHS;

interface DemoFrameSignature {
  Args: {
    /** Unique on the page: it names this demo in the frame-mode URL. */
    id: string;
    /** Names the demo: the expand button, the viewer and its iframe. */
    label: string;
  };
  Blocks: { default: [] };
}

function frameParam(): string | null {
  if (typeof window === 'undefined') {
    return null;
  }
  return new URLSearchParams(window.location.search).get(PARAM);
}

/**
 * A stage for demos that need a whole screen, such as `AppLayout`. Inline it
 * gives the demo a fixed height and an expand button. Expanding opens a
 * full-screen viewer holding this same page in an iframe, at phone, tablet or
 * desktop width, so breakpoint-driven behavior (drawers, the bottom bar) runs
 * against the iframe's own window.
 *
 * In that iframe the page carries `?demo-frame=<id>`: the matching frame fills
 * the viewport and the rest of the page is hidden (see `.demo-frame-mode` in
 * docfy-demo.css). Frame mode is entered after render, so the prerendered
 * HTML rehydrates unchanged.
 */
export default class DemoFrame extends Component<DemoFrameSignature> {
  @tracked isFullscreen = false;
  @tracked isOpen = false;
  @tracked width: Width = 'desktop';

  enterFrameMode = modifier(() => {
    if (frameParam() !== this.args.id) {
      return;
    }
    const root = document.documentElement;
    // After the render that installed this modifier, which already read it.
    schedule('afterRender', () => {
      if (this.isDestroying) {
        return;
      }
      this.isFullscreen = true;
      root.classList.add('demo-frame-mode');
    });
    return () => root.classList.remove('demo-frame-mode');
  });

  get frameUrl(): string {
    if (typeof window === 'undefined') {
      return '';
    }
    const search = new URLSearchParams({ [PARAM]: this.args.id });
    return `${window.location.pathname}?${search.toString()}`;
  }

  get frameStyle() {
    return htmlSafe(`width: ${WIDTHS[this.width]}`);
  }

  open = (): void => {
    this.isOpen = true;
  };

  close = (): void => {
    this.isOpen = false;
  };

  setWidth = (value: string): void => {
    this.width = value as Width;
  };

  <template>
    <div
      class="demo-frame"
      data-demo-frame={{@id}}
      data-fullscreen="{{this.isFullscreen}}"
      {{this.enterFrameMode}}
    >
      {{#unless this.isFullscreen}}
        <Button
          @size="sm"
          @variant="ghost"
          @class="demo-frame__expand"
          aria-label="Expand {{@label}}"
          data-demo-frame-expand
          @onPress={{this.open}}
        >
          <IconMaximize class="size-4" aria-hidden="true" />
          Expand
        </Button>
      {{/unless}}
      <div class="demo-frame__stage" data-demo-frame-stage>
        {{yield}}
      </div>
    </div>

    <Modal
      @isOpen={{this.isOpen}}
      @onClose={{this.close}}
      @size="full"
      @classes={{hash base="demo-frame__viewer"}}
      as |m|
    >
      <m.Header @class="demo-frame__viewer-header">
        <span class="truncate">{{@label}}</span>
        <SegmentedControl
          @value={{this.width}}
          @onChange={{this.setWidth}}
          @size="sm"
          aria-label="Viewport width"
          as |Ctl|
        >
          <Ctl.Item @value="phone" data-value="phone">Phone</Ctl.Item>
          <Ctl.Item @value="tablet" data-value="tablet">Tablet</Ctl.Item>
          <Ctl.Item @value="desktop" data-value="desktop">Desktop</Ctl.Item>
        </SegmentedControl>
        <a
          href={{this.frameUrl}}
          target="_blank"
          rel="noopener"
          class="demo-frame__open"
          data-demo-frame-open
        >
          <IconExternalLink class="size-4" aria-hidden="true" />
          Open in new tab
        </a>
      </m.Header>
      <m.Body @class="demo-frame__viewer-body">
        <iframe
          src={{this.frameUrl}}
          title={{@label}}
          class="demo-frame__iframe"
          style={{this.frameStyle}}
        ></iframe>
      </m.Body>
    </Modal>
  </template>
}
