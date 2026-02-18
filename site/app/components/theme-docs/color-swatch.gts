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
    'neutral-muted': 'bg-neutral-muted',
    'neutral-soft': 'bg-neutral-soft',
    'neutral-medium': 'bg-neutral-medium',
    'neutral-firm': 'bg-neutral-firm',
    'neutral-strong': 'bg-neutral-strong',
    'neutral-bolder': 'bg-neutral-bolder',
    'neutral-boldest': 'bg-neutral-boldest',
    'brand-subtle': 'bg-brand-subtle',
    'brand-muted': 'bg-brand-muted',
    'brand-soft': 'bg-brand-soft',
    'brand-medium': 'bg-brand-medium',
    'brand-firm': 'bg-brand-firm',
    'brand-strong': 'bg-brand-strong',
    'brand-bolder': 'bg-brand-bolder',
    'brand-boldest': 'bg-brand-boldest',
    'accent-subtle': 'bg-accent-subtle',
    'accent-muted': 'bg-accent-muted',
    'accent-soft': 'bg-accent-soft',
    'accent-medium': 'bg-accent-medium',
    'accent-firm': 'bg-accent-firm',
    'accent-strong': 'bg-accent-strong',
    'accent-bolder': 'bg-accent-bolder',
    'accent-boldest': 'bg-accent-boldest',
    'success-subtle': 'bg-success-subtle',
    'success-muted': 'bg-success-muted',
    'success-soft': 'bg-success-soft',
    'success-medium': 'bg-success-medium',
    'success-firm': 'bg-success-firm',
    'success-strong': 'bg-success-strong',
    'success-bolder': 'bg-success-bolder',
    'success-boldest': 'bg-success-boldest',
    'danger-subtle': 'bg-danger-subtle',
    'danger-muted': 'bg-danger-muted',
    'danger-soft': 'bg-danger-soft',
    'danger-medium': 'bg-danger-medium',
    'danger-firm': 'bg-danger-firm',
    'danger-strong': 'bg-danger-strong',
    'danger-bolder': 'bg-danger-bolder',
    'danger-boldest': 'bg-danger-boldest',
    'warning-subtle': 'bg-warning-subtle',
    'warning-muted': 'bg-warning-muted',
    'warning-soft': 'bg-warning-soft',
    'warning-medium': 'bg-warning-medium',
    'warning-firm': 'bg-warning-firm',
    'warning-strong': 'bg-warning-strong',
    'warning-bolder': 'bg-warning-bolder',
    'warning-boldest': 'bg-warning-boldest',
    'inverse-subtle': 'bg-inverse-subtle',
    'inverse-muted': 'bg-inverse-muted',
    'inverse-soft': 'bg-inverse-soft',
    'inverse-medium': 'bg-inverse-medium',
    'inverse-firm': 'bg-inverse-firm',
    'inverse-strong': 'bg-inverse-strong',
    'inverse-bolder': 'bg-inverse-bolder',
    'inverse-boldest': 'bg-inverse-boldest',
  };

  // Corresponding "on-" text colors for each background
  private onColorClassMap: Record<string, string> = {
    'neutral-subtle': 'text-on-neutral-subtle',
    'neutral-muted': 'text-on-neutral-muted',
    'neutral-soft': 'text-on-neutral-soft',
    'neutral-medium': 'text-on-neutral-medium',
    'neutral-firm': 'text-on-neutral-firm',
    'neutral-strong': 'text-on-neutral-strong',
    'neutral-bolder': 'text-on-neutral-bolder',
    'neutral-boldest': 'text-on-neutral-boldest',
    'brand-subtle': 'text-on-brand-subtle',
    'brand-muted': 'text-on-brand-muted',
    'brand-soft': 'text-on-brand-soft',
    'brand-medium': 'text-on-brand-medium',
    'brand-firm': 'text-on-brand-firm',
    'brand-strong': 'text-on-brand-strong',
    'brand-bolder': 'text-on-brand-bolder',
    'brand-boldest': 'text-on-brand-boldest',
    'accent-subtle': 'text-on-accent-subtle',
    'accent-muted': 'text-on-accent-muted',
    'accent-soft': 'text-on-accent-soft',
    'accent-medium': 'text-on-accent-medium',
    'accent-firm': 'text-on-accent-firm',
    'accent-strong': 'text-on-accent-strong',
    'accent-bolder': 'text-on-accent-bolder',
    'accent-boldest': 'text-on-accent-boldest',
    'success-subtle': 'text-on-success-subtle',
    'success-muted': 'text-on-success-muted',
    'success-soft': 'text-on-success-soft',
    'success-medium': 'text-on-success-medium',
    'success-firm': 'text-on-success-firm',
    'success-strong': 'text-on-success-strong',
    'success-bolder': 'text-on-success-bolder',
    'success-boldest': 'text-on-success-boldest',
    'danger-subtle': 'text-on-danger-subtle',
    'danger-muted': 'text-on-danger-muted',
    'danger-soft': 'text-on-danger-soft',
    'danger-medium': 'text-on-danger-medium',
    'danger-firm': 'text-on-danger-firm',
    'danger-strong': 'text-on-danger-strong',
    'danger-bolder': 'text-on-danger-bolder',
    'danger-boldest': 'text-on-danger-boldest',
    'warning-subtle': 'text-on-warning-subtle',
    'warning-muted': 'text-on-warning-muted',
    'warning-soft': 'text-on-warning-soft',
    'warning-medium': 'text-on-warning-medium',
    'warning-firm': 'text-on-warning-firm',
    'warning-strong': 'text-on-warning-strong',
    'warning-bolder': 'text-on-warning-bolder',
    'warning-boldest': 'text-on-warning-boldest',
    'inverse-subtle': 'text-on-inverse-subtle',
    'inverse-muted': 'text-on-inverse-muted',
    'inverse-soft': 'text-on-inverse-soft',
    'inverse-medium': 'text-on-inverse-medium',
    'inverse-firm': 'text-on-inverse-firm',
    'inverse-strong': 'text-on-inverse-strong',
    'inverse-bolder': 'text-on-inverse-bolder',
    'inverse-boldest': 'text-on-inverse-boldest',
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
        <div class="font-mono text-sm font-medium text-neutral-bolder truncate">
          {{this.className}}
        </div>
        {{#if @showDescription}}
          <div class="text-xs text-neutral truncate">
            {{this.description}}
          </div>
        {{/if}}
        <div class="font-mono text-xs text-neutral-strong truncate">
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
