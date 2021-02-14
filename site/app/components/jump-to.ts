import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { inject as service } from '@ember/service';
import { DocfyService } from '@docfy/ember';
import RouterService from '@ember/routing/router-service';
import { PageMetadata, NestedPageMetadata } from '@docfy/core/lib/types';
import Fuse from 'fuse.js';

interface ResultItem {
  item: PageMetadata;
}

export default class JumpToComponent extends Component {
  @service docfy!: DocfyService;
  @service router!: RouterService;

  @tracked isOpen = false;

  @tracked pattern?: string;
  @tracked results?: ResultItem[];
  @tracked selected?: number;
  @tracked resultsContainerElement?: HTMLElement;

  fuse = new Fuse(this.docfy.flat, {
    keys: ['title'],
    threshold: 0.4
  });

  selectNext(): void {
    if (!this.results) {
      return;
    }

    if (typeof this.selected !== 'undefined') {
      if (this.selected + 1 < this.results.length) {
        this.selected += 1;
      }
    } else {
      this.selected = 0;
    }
  }

  selectPrevious(): void {
    if (!this.results) {
      return;
    }

    if (typeof this.selected !== 'undefined') {
      if (this.selected - 1 >= 0) {
        this.selected -= 1;
      }
    }
  }

  @action setupShortcut(): void {
    document.addEventListener('keydown', this.handleGlobalKeyDown);
  }

  @action teardownShortcut(): void {
    document.removeEventListener('keydown', this.handleGlobalKeyDown);
  }

  @action handleGlobalKeyDown(event: KeyboardEvent): void {
    if (
      !['INPUT', 'TEXTAREA'].includes((event.target as HTMLElement).tagName)
    ) {
      if (event.key === '/') {
        this.isOpen = true;
      }
    }
  }

  @action registerContainerElement(element: HTMLElement): void {
    this.resultsContainerElement = element;
  }

  @action search(event: KeyboardEvent): void {
    const pattern = (event.target as HTMLInputElement).value;

    this.results = this.fuse.search(pattern).map((item) => {
      return {
        item: item.item
      };
    });
    this.selected = undefined;
    this.selectNext();
  }

  @action toggle(): void {
    this.isOpen = !this.isOpen;
  }

  @action didClose(): void {
    this.results = undefined;
  }

  @action onItemClick(event: MouseEvent): void {
    event.preventDefault();
    this.isOpen = false;
    const href = (event.target as HTMLElement).getAttribute('href') || '/';
    this.router.transitionTo(href);
  }

  @action selectElement(event: MouseEvent): void {
    const index = Number(
      (event.target as HTMLElement).getAttribute('data-result')
    );
    this.selected = index;
  }

  @action onInputKeydown(event: KeyboardEvent): void {
    if (event.key === 'ArrowDown') {
      this.selectNext();
      event.preventDefault();
    } else if (event.key === 'ArrowUp') {
      this.selectPrevious();
      event.preventDefault();
    } else if (event.key === 'Enter') {
      event.preventDefault();
      if (this.resultsContainerElement) {
        const link = this.resultsContainerElement.querySelector(
          `[data-result="${this.selected}"]`
        ) as HTMLElement | undefined;
        if (link) {
          link.click();
        }
      }
    }
  }
}
