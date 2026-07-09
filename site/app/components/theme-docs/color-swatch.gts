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
    'neutral-DEFAULT': 'bg-neutral',
    'neutral-firm': 'bg-neutral-firm',
    'neutral-strong': 'bg-neutral-strong',
    'neutral-bolder': 'bg-neutral-bolder',
    'primary-subtle': 'bg-primary-subtle',
    'primary-muted': 'bg-primary-muted',
    'primary-soft': 'bg-primary-soft',
    'primary-DEFAULT': 'bg-primary',
    'primary-firm': 'bg-primary-firm',
    'primary-strong': 'bg-primary-strong',
    'primary-bolder': 'bg-primary-bolder',
    'accent-subtle': 'bg-accent-subtle',
    'accent-muted': 'bg-accent-muted',
    'accent-soft': 'bg-accent-soft',
    'accent-DEFAULT': 'bg-accent',
    'accent-firm': 'bg-accent-firm',
    'accent-strong': 'bg-accent-strong',
    'accent-bolder': 'bg-accent-bolder',
    'success-subtle': 'bg-success-subtle',
    'success-muted': 'bg-success-muted',
    'success-soft': 'bg-success-soft',
    'success-DEFAULT': 'bg-success',
    'success-firm': 'bg-success-firm',
    'success-strong': 'bg-success-strong',
    'success-bolder': 'bg-success-bolder',
    'danger-subtle': 'bg-danger-subtle',
    'danger-muted': 'bg-danger-muted',
    'danger-soft': 'bg-danger-soft',
    'danger-DEFAULT': 'bg-danger',
    'danger-firm': 'bg-danger-firm',
    'danger-strong': 'bg-danger-strong',
    'danger-bolder': 'bg-danger-bolder',
    'warning-subtle': 'bg-warning-subtle',
    'warning-muted': 'bg-warning-muted',
    'warning-soft': 'bg-warning-soft',
    'warning-DEFAULT': 'bg-warning',
    'warning-firm': 'bg-warning-firm',
    'warning-strong': 'bg-warning-strong',
    'warning-bolder': 'bg-warning-bolder',
  };

  // Corresponding "on-" text colors for each background
  private onColorClassMap: Record<string, string> = {
    'neutral-subtle': 'text-on-neutral-subtle',
    'neutral-muted': 'text-on-neutral-muted',
    'neutral-soft': 'text-on-neutral-soft',
    'neutral-DEFAULT': 'text-on-neutral',
    'neutral-firm': 'text-on-neutral-firm',
    'neutral-strong': 'text-on-neutral-strong',
    'neutral-bolder': 'text-on-neutral-bolder',
    'primary-subtle': 'text-on-primary-subtle',
    'primary-muted': 'text-on-primary-muted',
    'primary-soft': 'text-on-primary-soft',
    'primary-DEFAULT': 'text-on-primary',
    'primary-firm': 'text-on-primary-firm',
    'primary-strong': 'text-on-primary-strong',
    'primary-bolder': 'text-on-primary-bolder',
    'accent-subtle': 'text-on-accent-subtle',
    'accent-muted': 'text-on-accent-muted',
    'accent-soft': 'text-on-accent-soft',
    'accent-DEFAULT': 'text-on-accent',
    'accent-firm': 'text-on-accent-firm',
    'accent-strong': 'text-on-accent-strong',
    'accent-bolder': 'text-on-accent-bolder',
    'success-subtle': 'text-on-success-subtle',
    'success-muted': 'text-on-success-muted',
    'success-soft': 'text-on-success-soft',
    'success-DEFAULT': 'text-on-success',
    'success-firm': 'text-on-success-firm',
    'success-strong': 'text-on-success-strong',
    'success-bolder': 'text-on-success-bolder',
    'danger-subtle': 'text-on-danger-subtle',
    'danger-muted': 'text-on-danger-muted',
    'danger-soft': 'text-on-danger-soft',
    'danger-DEFAULT': 'text-on-danger',
    'danger-firm': 'text-on-danger-firm',
    'danger-strong': 'text-on-danger-strong',
    'danger-bolder': 'text-on-danger-bolder',
    'warning-subtle': 'text-on-warning-subtle',
    'warning-muted': 'text-on-warning-muted',
    'warning-soft': 'text-on-warning-soft',
    'warning-DEFAULT': 'text-on-warning',
    'warning-firm': 'text-on-warning-firm',
    'warning-strong': 'text-on-warning-strong',
    'warning-bolder': 'text-on-warning-bolder',
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
      class="color-swatch-button group relative flex items-center gap-4 rounded p-3 transition-all hover:ring-2 hover:ring-primary bg-surface-overlay-subtle hover:bg-surface-overlay-soft"
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
          <div class="text-xs text-neutral-firm truncate">
            {{this.description}}
          </div>
        {{/if}}
        <div class="font-mono text-xs text-neutral-strong truncate">
          {{this.bgClass}}
        </div>
      </div>

      {{! Copy indicator }}
      {{#if this.isHovered}}
        <div class="text-xs text-primary whitespace-nowrap">
          Click to copy
        </div>
      {{/if}}
    </button>
  </template>
}
