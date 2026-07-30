import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { ButtonGroup, Dropdown } from 'frontile';

export interface DocfyCopyPageSignature {
  Args: {
    url: string;
    title: string;
  };
  Element: HTMLDivElement;
}

type CopyStatus = 'idle' | 'copying' | 'copied' | 'error';

export default class DocfyCopyPage extends Component<DocfyCopyPageSignature> {
  @tracked status: CopyStatus = 'idle';

  resetTimer?: ReturnType<typeof setTimeout>;

  get mdUrl(): string {
    return `${window.location.origin}${this.args.url}.md`;
  }

  buildPrompt(): string {
    return `Use web browsing to access this Frontile documentation page: ${this.mdUrl}. I want to ask some questions about the ${this.args.title} component.`;
  }

  get chatGptUrl(): string {
    return `https://chatgpt.com/?hints=search&q=${encodeURIComponent(this.buildPrompt())}`;
  }

  get claudeUrl(): string {
    return `https://claude.ai/new?q=${encodeURIComponent(this.buildPrompt())}`;
  }

  get primaryLabel(): string {
    switch (this.status) {
      case 'copying':
        return 'Copying…';
      case 'copied':
        return 'Copied!';
      case 'error':
        return 'Unavailable';
      default:
        return 'Copy Page';
    }
  }

  resetAfterDelay(): void {
    if (this.resetTimer) {
      clearTimeout(this.resetTimer);
    }
    this.resetTimer = setTimeout(() => {
      if (this.isDestroying || this.isDestroyed) {
        return;
      }
      if (this.status === 'copied' || this.status === 'error') {
        this.status = 'idle';
      }
    }, 2000);
  }

  override willDestroy(): void {
    super.willDestroy();
    if (this.resetTimer) {
      clearTimeout(this.resetTimer);
      this.resetTimer = undefined;
    }
  }

  @action
  async copyPage(): Promise<void> {
    this.status = 'copying';
    try {
      const response = await fetch(this.mdUrl);
      if (!response.ok) {
        throw new Error(`Failed to fetch ${this.mdUrl}: ${response.status}`);
      }
      const text = await response.text();
      await navigator.clipboard.writeText(text);
      this.status = 'copied';
    } catch {
      this.status = 'error';
    } finally {
      this.resetAfterDelay();
    }
  }

  @action
  openInChatGpt(): void {
    window.open(this.chatGptUrl, '_blank', 'noopener,noreferrer');
  }

  @action
  openInClaude(): void {
    window.open(this.claudeUrl, '_blank', 'noopener,noreferrer');
  }

  @action
  viewAsMarkdown(): void {
    window.open(this.mdUrl, '_blank', 'noopener,noreferrer');
  }

  // The anchor keeps a real `href` so middle-click/ctrl-click/"copy link
  // address" work natively. A plain left-click is instead routed through
  // the Dropdown's onAction -> viewAsMarkdown (which also covers keyboard
  // activation, since a menuitem's Enter/Space never reaches this anchor) —
  // so a plain click must not navigate too, or it would open two tabs.
  @action
  guardAnchorClick(event: MouseEvent): void {
    if (
      event.button === 0 &&
      !event.metaKey &&
      !event.ctrlKey &&
      !event.shiftKey &&
      !event.altKey
    ) {
      // Plain left-click: let handleMenuAction's viewAsMarkdown() open the
      // tab instead, so it stays consistent with keyboard activation.
      event.preventDefault();
    } else {
      // Modifier-click (open in background tab/window, etc.): let the
      // browser handle the anchor's real href natively, and stop this
      // click from also bubbling to the menu item's onAction, which would
      // otherwise open a second tab via viewAsMarkdown().
      event.stopPropagation();
    }
  }

  @action
  handleMenuAction(key: string): void {
    if (key === 'view-as-markdown') {
      this.viewAsMarkdown();
    } else if (key === 'copy-page') {
      this.copyPage();
    } else if (key === 'open-chatgpt') {
      this.openInChatGpt();
    } else if (key === 'open-claude') {
      this.openInClaude();
    }
  }

  <template>
    <div class="inline-flex" data-test-id="docfy-copy-page" ...attributes>
      <ButtonGroup @appearance="outlined" @size="xs" as |g|>
        <g.Button @onPress={{this.copyPage}} data-test-id="copy-page-primary">
          {{this.primaryLabel}}
        </g.Button>

        <Dropdown as |d|>
          <d.Trigger
            @appearance="outlined"
            @size="xs"
            @isInGroup={{true}}
            aria-label="More page actions"
            data-test-id="copy-page-trigger"
          >
            <svg
              class="w-4 h-4"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
              aria-hidden="true"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M19 9l-7 7-7-7"
              />
            </svg>
          </d.Trigger>

          <d.Menu
            @onAction={{this.handleMenuAction}}
            @disableTransitions={{true}}
            as |Item|
          >
            <Item @key="view-as-markdown">
              <a
                href={{this.mdUrl}}
                target="_blank"
                rel="noopener noreferrer"
                data-test-id="copy-page-view-markdown"
                {{on "click" this.guardAnchorClick}}
              >View as markdown</a>
            </Item>
            <Item @key="copy-page">Copy Page</Item>
            <Item @key="open-chatgpt">Open in ChatGPT</Item>
            <Item @key="open-claude">Open in Claude</Item>
          </d.Menu>
        </Dropdown>
      </ButtonGroup>
    </div>
  </template>
}
