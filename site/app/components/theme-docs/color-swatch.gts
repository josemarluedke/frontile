import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import type { TOC } from '@ember/component/template-only';

import {
  getColorLevelDescription,
  type ColorCategory,
  type ColorLevel,
} from '../../utils/theme-colors';

interface ColorSwatchSignature {
  Args: {
    category: ColorCategory;
    level: ColorLevel;
    mode?: 'light' | 'dark';
    showDescription?: boolean;
    onCopy?: (className: string) => void;
  };
}

export default class ColorSwatch extends Component<ColorSwatchSignature> {
  @tracked isHovered = false;

  get className() {
    return `${this.args.category}.${this.args.level}`;
  }

  // Lookup tables with complete class strings for Tailwind detection
  private bgClassMap: Record<string, string> = {
    'neutral-contrast-1': 'bg-neutral-contrast-1',
    'neutral-subtle': 'bg-neutral-subtle',
    'neutral-soft': 'bg-neutral-soft',
    'neutral-medium': 'bg-neutral-medium',
    'neutral-strong': 'bg-neutral-strong',
    'neutral-contrast-2': 'bg-neutral-contrast-2',
    'brand-contrast-1': 'bg-brand-contrast-1',
    'brand-subtle': 'bg-brand-subtle',
    'brand-soft': 'bg-brand-soft',
    'brand-medium': 'bg-brand-medium',
    'brand-strong': 'bg-brand-strong',
    'brand-contrast-2': 'bg-brand-contrast-2',
    'success-contrast-1': 'bg-success-contrast-1',
    'success-subtle': 'bg-success-subtle',
    'success-soft': 'bg-success-soft',
    'success-medium': 'bg-success-medium',
    'success-strong': 'bg-success-strong',
    'success-contrast-2': 'bg-success-contrast-2',
    'danger-contrast-1': 'bg-danger-contrast-1',
    'danger-subtle': 'bg-danger-subtle',
    'danger-soft': 'bg-danger-soft',
    'danger-medium': 'bg-danger-medium',
    'danger-strong': 'bg-danger-strong',
    'danger-contrast-2': 'bg-danger-contrast-2',
    'warning-contrast-1': 'bg-warning-contrast-1',
    'warning-subtle': 'bg-warning-subtle',
    'warning-soft': 'bg-warning-soft',
    'warning-medium': 'bg-warning-medium',
    'warning-strong': 'bg-warning-strong',
    'warning-contrast-2': 'bg-warning-contrast-2',
    'inverse-contrast-1': 'bg-inverse-contrast-1',
    'inverse-subtle': 'bg-inverse-subtle',
    'inverse-soft': 'bg-inverse-soft',
    'inverse-medium': 'bg-inverse-medium',
    'inverse-strong': 'bg-inverse-strong',
    'inverse-contrast-2': 'bg-inverse-contrast-2',
  };

  get bgClass() {
    const key = `${this.args.category}-${this.args.level}`;
    return this.bgClassMap[key] || '';
  }

  get description() {
    return getColorLevelDescription(this.args.level);
  }

  get textColor() {
    // Determine appropriate text color based on background level
    const level = this.args.level;
    if (level === 'contrast-1' || level === 'subtle' || level === 'soft') {
      return 'text-surface-solid-11';
    }
    return 'text-surface-solid-0';
  }

  handleClick = () => {
    this.args.onCopy?.(this.bgClass);
    // Copy to clipboard
    if (typeof navigator !== 'undefined' && navigator.clipboard) {
      navigator.clipboard.writeText(this.bgClass);
    }
  };

  handleMouseEnter = () => {
    this.isHovered = true;
  };

  handleMouseLeave = () => {
    this.isHovered = false;
  };

  <template>
    <button
      type="button"
      class="color-swatch-button group relative flex items-center gap-4 rounded p-3 transition-all hover:ring-2 hover:ring-brand bg-surface-overlay-subtle hover:bg-surface-overlay-soft"
      {{on "click" this.handleClick}}
      {{on "mouseenter" this.handleMouseEnter}}
      {{on "mouseleave" this.handleMouseLeave}}
    >
      {{! Color square }}
      <div
        class="size-12 rounded border border-neutral-subtle shadow-sm
          {{this.bgClass}}"
      ></div>

      {{! Color info }}
      <div class="flex-1 text-left min-w-0">
        <div class="font-mono text-sm font-medium text-neutral-strong truncate">
          {{this.className}}
        </div>
        {{#if @showDescription}}
          <div class="text-xs text-neutral-soft truncate">
            {{this.description}}
          </div>
        {{/if}}
        <div class="font-mono text-xs text-neutral-medium truncate">
          {{this.bgClass}}
        </div>
      </div>

      {{! Copy indicator }}
      {{#if this.isHovered}}
        <div class="text-xs text-brand whitespace-nowrap">
          Click to copy
        </div>
      {{/if}}
    </button>
  </template>
}
