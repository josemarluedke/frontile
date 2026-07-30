import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { ButtonGroup } from 'frontile';

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
    setTimeout(() => {
      if (this.status === 'copied' || this.status === 'error') {
        this.status = 'idle';
      }
    }, 2000);
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

  <template>
    <div class="inline-flex" data-test-id="docfy-copy-page" ...attributes>
      <ButtonGroup @appearance="outlined" @size="sm" as |g|>
        <g.Button @onPress={{this.copyPage}} data-test-id="copy-page-primary">
          {{this.primaryLabel}}
        </g.Button>
      </ButtonGroup>
    </div>
  </template>
}
