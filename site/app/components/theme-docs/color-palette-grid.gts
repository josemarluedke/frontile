import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { hash } from '@ember/helper';
import ColorSwatch from './color-swatch';

import {
  colorLevels,
  getCategoryDisplayName,
  getCategoryDescription,
  type ColorCategory,
} from '../../utils/theme-colors';

interface ColorPaletteGridSignature {
  Args: {
    category: ColorCategory;
    showDescription?: boolean;
    sideBySide?: boolean;
  };
}

export default class ColorPaletteGrid extends Component<ColorPaletteGridSignature> {
  @tracked copiedClass: string | null = null;
  @tracked copyTimeout: ReturnType<typeof setTimeout> | null = null;

  get categoryName() {
    return getCategoryDisplayName(this.args.category);
  }

  get categoryDescription() {
    return getCategoryDescription(this.args.category);
  }

  get levels() {
    return colorLevels;
  }

  @action
  handleCopy(className: string) {
    this.copiedClass = className;

    if (this.copyTimeout) {
      clearTimeout(this.copyTimeout);
    }

    this.copyTimeout = setTimeout(() => {
      this.copiedClass = null;
    }, 2000);
  }

  willDestroy() {
    super.willDestroy();
    if (this.copyTimeout) {
      clearTimeout(this.copyTimeout);
    }
  }

  <template>
    <div class="color-palette-grid">
      {{! Header }}
      <div class="mb-6">
        <p class="text-neutral-medium">
          {{this.categoryDescription}}
        </p>
      </div>

      {{! Copy notification }}
      {{#if this.copiedClass}}
        <div
          class="mb-4 p-3 bg-success-subtle text-success-strong rounded border border-success-soft"
        >
          <div class="flex items-center gap-2">
            <svg
              class="size-5"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M5 13l4 4L19 7"
              />
            </svg>
            <span class="font-mono text-sm">{{this.copiedClass}}</span>
            <span class="text-sm">copied to clipboard!</span>
          </div>
        </div>
      {{/if}}

      {{! Grid layout }}
      {{#if @sideBySide}}
        {{! Side by side light/dark mode }}
        <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
          {{! Light Mode }}
          <div class="light">
            <h4 class="text-sm font-semibold mb-4 text-neutral-strong">Light
              Mode</h4>
            <div class="grid grid-cols-1 gap-2">
              {{#each this.levels as |level|}}
                <ColorSwatch
                  @category={{@category}}
                  @level={{level}}
                  @mode="light"
                  @showDescription={{@showDescription}}
                  @onCopy={{this.handleCopy}}
                />
              {{/each}}
            </div>
          </div>

          {{! Dark Mode }}
          <div class="dark">
            <h4 class="text-sm font-semibold mb-4 text-neutral-strong">Dark Mode</h4>
            <div class="grid grid-cols-1 gap-2">
              {{#each this.levels as |level|}}
                <ColorSwatch
                  @category={{@category}}
                  @level={{level}}
                  @mode="dark"
                  @showDescription={{@showDescription}}
                  @onCopy={{this.handleCopy}}
                />
              {{/each}}
            </div>
          </div>
        </div>
      {{else}}
        {{! Single column (current theme) }}
        <div class="grid grid-cols-1 gap-2">
          {{#each this.levels as |level|}}
            <ColorSwatch
              @category={{@category}}
              @level={{level}}
              @showDescription={{@showDescription}}
              @onCopy={{this.handleCopy}}
            />
          {{/each}}
        </div>
      {{/if}}
    </div>
  </template>
}
