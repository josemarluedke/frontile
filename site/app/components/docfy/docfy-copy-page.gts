import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
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
  handleMenuAction(key: string): void {
    if (key === 'copy-page') {
      this.copyPage();
    } else if (key === 'open-chatgpt') {
      this.openInChatGpt();
    } else if (key === 'open-claude') {
      this.openInClaude();
    }
    // 'view-as-markdown' is a plain <a>; the browser handles it natively.
  }

  <template>
    <div class="inline-flex" data-test-id="docfy-copy-page" ...attributes>
      <ButtonGroup @appearance="outlined" @size="sm" as |g|>
        <g.Button @onPress={{this.copyPage}} data-test-id="copy-page-primary">
          {{this.primaryLabel}}
        </g.Button>

        <Dropdown as |d|>
          <d.Trigger
            @appearance="outlined"
            @size="sm"
            @isInGroup={{true}}
            data-test-id="copy-page-trigger"
          >
            <svg
              class="w-4 h-4"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
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
