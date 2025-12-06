import Component from '@glimmer/component';
import { hash } from '@ember/helper';

import {
  surfaceSolidLevels,
  surfaceOverlayLevels,
} from '../../utils/theme-colors';

interface SurfaceShowcaseSignature {
  Args: {
    type: 'solid' | 'overlay' | 'overlay-inverse';
    sideBySide?: boolean;
  };
}

export default class SurfaceShowcase extends Component<SurfaceShowcaseSignature> {
  get solidLevels() {
    return surfaceSolidLevels;
  }

  get overlayLevels() {
    return surfaceOverlayLevels;
  }

  get isSolid() {
    return this.args.type === 'solid';
  }

  get isOverlay() {
    return this.args.type === 'overlay';
  }

  get isOverlayInverse() {
    return this.args.type === 'overlay-inverse';
  }

  // Complete class strings for Tailwind detection
  private surfaceBgClasses: Record<number, string> = {
    0: 'bg-surface-solid-0',
    1: 'bg-surface-solid-1',
    2: 'bg-surface-solid-2',
    3: 'bg-surface-solid-3',
    4: 'bg-surface-solid-4',
    5: 'bg-surface-solid-5',
    6: 'bg-surface-solid-6',
    7: 'bg-surface-solid-7',
    8: 'bg-surface-solid-8',
    9: 'bg-surface-solid-9',
    10: 'bg-surface-solid-10',
    11: 'bg-surface-solid-11',
  };

  private surfaceTextClasses: Record<number, string> = {
    0: 'text-surface-solid-0',
    1: 'text-surface-solid-1',
    2: 'text-surface-solid-2',
    3: 'text-surface-solid-3',
    4: 'text-surface-solid-4',
    5: 'text-surface-solid-5',
    6: 'text-surface-solid-6',
    7: 'text-surface-solid-7',
    8: 'text-surface-solid-8',
    9: 'text-surface-solid-9',
    10: 'text-surface-solid-10',
    11: 'text-surface-solid-11',
  };

  private overlayClasses: Record<string, string> = {
    subtle: 'bg-surface-overlay-subtle',
    soft: 'bg-surface-overlay-soft',
    medium: 'bg-surface-overlay-medium',
    strong: 'bg-surface-overlay-strong',
  };

  private overlayInverseClasses: Record<string, string> = {
    subtle: 'bg-surface-overlay-inverse-subtle',
    soft: 'bg-surface-overlay-inverse-soft',
    medium: 'bg-surface-overlay-inverse-medium',
    strong: 'bg-surface-overlay-inverse-strong',
  };

  getSurfaceBgClass = (level: number): string => {
    return this.surfaceBgClasses[level] || '';
  };

  getSurfaceTextClass = (level: number): string => {
    return this.surfaceTextClasses[level] || '';
  };

  getOverlayClass = (level: string, inverse: boolean = false): string => {
    return inverse
      ? this.overlayInverseClasses[level] || ''
      : this.overlayClasses[level] || '';
  };

  getTextColorForLevel = (level: number): number => {
    return level < 6 ? 11 : 0;
  };

  getSecondaryTextColorForLevel = (level: number): number => {
    return level < 6 ? 10 : 1;
  };

  <template>
    <div class="surface-showcase">
      {{#if this.isSolid}}
        {{! Solid Surface Demonstration - Show both themes side by side }}
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {{! Light mode }}
          <div class="light">
            <div
              class="p-6 rounded-lg border border-neutral-subtle bg-surface-solid-0"
            >
              <h4 class="text-sm font-semibold mb-2 text-surface-solid-11">Light
                Mode</h4>
              <p class="text-xs text-surface-solid-10 mb-4">0 is white, 11 is
                black</p>
              <div class="space-y-2">
                {{#each this.solidLevels as |level|}}
                  <div
                    class="{{this.getSurfaceBgClass level}}
                      p-3 rounded border border-neutral-subtle flex items-center justify-between"
                  >
                    <span
                      class="{{this.getSurfaceTextClass
                          (this.getTextColorForLevel level)
                        }}
                        font-mono text-xs"
                    >
                      surface-solid-{{level}}
                    </span>
                    <span
                      class="{{this.getSurfaceTextClass
                          (this.getSecondaryTextColorForLevel level)
                        }}
                        text-xs"
                    >
                      Level
                      {{level}}
                    </span>
                  </div>
                {{/each}}
              </div>
            </div>
          </div>

          {{! Dark mode }}
          <div class="dark">
            <div
              class="p-6 rounded-lg border border-neutral-subtle bg-surface-solid-0"
            >
              <h4 class="text-sm font-semibold mb-2 text-surface-solid-11">Dark
                Mode</h4>
              <p class="text-xs text-surface-solid-10 mb-4">0 is black, 11 is
                white</p>
              <div class="space-y-2">
                {{#each this.solidLevels as |level|}}
                  <div
                    class="{{this.getSurfaceBgClass level}}
                      p-3 rounded border border-neutral-subtle flex items-center justify-between"
                  >
                    <span
                      class="{{this.getSurfaceTextClass
                          (this.getTextColorForLevel level)
                        }}
                        font-mono text-xs"
                    >
                      surface-solid-{{level}}
                    </span>
                    <span
                      class="{{this.getSurfaceTextClass
                          (this.getSecondaryTextColorForLevel level)
                        }}
                        text-xs"
                    >
                      Level
                      {{level}}
                    </span>
                  </div>
                {{/each}}
              </div>
            </div>
          </div>
        </div>

      {{else if this.isOverlay}}
        {{! Overlay Demonstration }}
        <div
          class="p-6 rounded-lg bg-surface-solid-1 border border-neutral-subtle"
        >
          <h4 class="text-sm font-semibold mb-4 text-neutral-strong">
            Surface Overlay (on solid-1 base)
          </h4>
          <p class="text-sm text-neutral-soft mb-4">
            These overlays are translucent and stack on top of the solid base
            background.
          </p>

          {{! Stack overlays }}
          <div class="space-y-4">
            {{#each this.overlayLevels as |level|}}
              <div class="{{this.getOverlayClass level}} p-6 rounded">
                <div class="flex items-center justify-between">
                  <span class="font-mono text-sm text-surface-solid-11">
                    surface-overlay-{{level}}
                  </span>
                  <span class="text-xs text-neutral-soft">
                    Translucent layer
                  </span>
                </div>
              </div>
            {{/each}}
          </div>

          {{! Stacking demo }}
          <div class="mt-6 p-6 rounded bg-surface-overlay-subtle">
            <h5 class="text-sm font-semibold mb-2 text-neutral-strong">
              Stacking Example
            </h5>
            <p class="text-sm text-neutral-medium mb-4">
              Overlays can stack on top of each other:
            </p>
            <div class="bg-surface-overlay-soft p-4 rounded">
              <div class="text-sm text-neutral-strong mb-2">Layer 1 (soft)</div>
              <div class="bg-surface-overlay-medium p-4 rounded">
                <div class="text-sm text-neutral-strong mb-2">Layer 2 (medium)</div>
                <div class="bg-surface-overlay-strong p-4 rounded">
                  <div class="text-sm text-surface-solid-0">Layer 3 (strong)</div>
                </div>
              </div>
            </div>
          </div>
        </div>

      {{else}}
        {{! Overlay Inverse Demonstration }}
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {{! Light mode with inverse overlay }}
          <div class="light">
            <div
              class="p-6 rounded-lg border border-neutral-subtle bg-surface-solid-1"
            >
              <h4 class="text-sm font-semibold mb-2 text-neutral-strong">
                Inverse Overlay in Light Mode
              </h4>
              <p class="text-xs text-neutral-soft mb-4">
                Creates dark overlays on light backgrounds for high contrast.
              </p>
              <div class="space-y-2">
                {{#each this.overlayLevels as |level|}}
                  <div class="{{this.getOverlayClass level true}} p-4 rounded">
                    <span class="font-mono text-sm text-surface-solid-11">
                      surface-overlay-inverse-{{level}}
                    </span>
                  </div>
                {{/each}}
              </div>
            </div>
          </div>

          {{! Dark mode with inverse overlay }}
          <div class="dark">
            <div
              class="p-6 rounded-lg border border-neutral-subtle bg-surface-solid-1"
            >
              <h4 class="text-sm font-semibold mb-2 text-neutral-strong">
                Inverse Overlay in Dark Mode
              </h4>
              <p class="text-xs text-neutral-soft mb-4">
                Creates light overlays on dark backgrounds for high contrast.
              </p>
              <div class="space-y-2">
                {{#each this.overlayLevels as |level|}}
                  <div class="{{this.getOverlayClass level true}} p-4 rounded">
                    <span class="font-mono text-sm text-surface-solid-11">
                      surface-overlay-inverse-{{level}}
                    </span>
                  </div>
                {{/each}}
              </div>
            </div>
          </div>
        </div>
      {{/if}}
    </div>
  </template>
}
