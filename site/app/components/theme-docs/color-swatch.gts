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
    'neutral-subtle': 'bg-neutral-subtle',
    'neutral-soft': 'bg-neutral-soft',
    'neutral-medium': 'bg-neutral-medium',
    'neutral-strong': 'bg-neutral-strong',
    'brand-subtle': 'bg-brand-subtle',
    'brand-soft': 'bg-brand-soft',
    'brand-medium': 'bg-brand-medium',
    'brand-strong': 'bg-brand-strong',
    'success-subtle': 'bg-success-subtle',
    'success-soft': 'bg-success-soft',
    'success-medium': 'bg-success-medium',
    'success-strong': 'bg-success-strong',
    'danger-subtle': 'bg-danger-subtle',
    'danger-soft': 'bg-danger-soft',
    'danger-medium': 'bg-danger-medium',
    'danger-strong': 'bg-danger-strong',
    'warning-subtle': 'bg-warning-subtle',
    'warning-soft': 'bg-warning-soft',
    'warning-medium': 'bg-warning-medium',
    'warning-strong': 'bg-warning-strong',
    'inverse-subtle': 'bg-inverse-subtle',
    'inverse-soft': 'bg-inverse-soft',
    'inverse-medium': 'bg-inverse-medium',
    'inverse-strong': 'bg-inverse-strong',
  };

  // Corresponding "on-" text colors for each background
  private onColorClassMap: Record<string, string> = {
    'neutral-subtle': 'text-on-neutral-subtle',
    'neutral-soft': 'text-on-neutral-soft',
    'neutral-medium': 'text-on-neutral-medium',
    'neutral-strong': 'text-on-neutral-strong',
    'brand-subtle': 'text-on-brand-subtle',
    'brand-soft': 'text-on-brand-soft',
    'brand-medium': 'text-on-brand-medium',
    'brand-strong': 'text-on-brand-strong',
    'success-subtle': 'text-on-success-subtle',
    'success-soft': 'text-on-success-soft',
    'success-medium': 'text-on-success-medium',
    'success-strong': 'text-on-success-strong',
    'danger-subtle': 'text-on-danger-subtle',
    'danger-soft': 'text-on-danger-soft',
    'danger-medium': 'text-on-danger-medium',
    'danger-strong': 'text-on-danger-strong',
    'warning-subtle': 'text-on-warning-subtle',
    'warning-soft': 'text-on-warning-soft',
    'warning-medium': 'text-on-warning-medium',
    'warning-strong': 'text-on-warning-strong',
    'inverse-subtle': 'text-on-inverse-subtle',
    'inverse-soft': 'text-on-inverse-soft',
    'inverse-medium': 'text-on-inverse-medium',
    'inverse-strong': 'text-on-inverse-strong',
  };

  get bgClass() {
    const key = `${this.args.category}-${this.args.level}`;
    return this.bgClassMap[key] || '';
  }

  get description() {
    return getColorLevelDescription(this.args.level);
  }

  get textColor() {
    // Use the automatically generated "on-" color for this background
    const key = `${this.args.category}-${this.args.level}`;
    return this.onColorClassMap[key] || 'text-surface-solid-11';
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
          <div class="text-xs text-neutral-medium truncate">
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
