import Component from '@glimmer/component';
import { hash } from '@ember/helper';

import {
  surfaceSolidLevels,
  surfaceOverlayLevels,
} from '../../utils/theme-colors';

interface SurfaceShowcaseSignature {
  Args: {
    type: 'solid' | 'overlay' | 'overlay-inverse' | 'roles';
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

  get isRoles() {
    return this.args.type === 'roles';
  }

  get surfaceRoles() {
    return [
      'app',
      'canvas',
      'card',
      'panel',
      'popover',
      'overlayContent',
      'inset',
    ];
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
    0: 'text-on-surface-solid-0',
    1: 'text-on-surface-solid-1',
    2: 'text-on-surface-solid-2',
    3: 'text-on-surface-solid-3',
    4: 'text-on-surface-solid-4',
    5: 'text-on-surface-solid-5',
    6: 'text-on-surface-solid-6',
    7: 'text-on-surface-solid-7',
    8: 'text-on-surface-solid-8',
    9: 'text-on-surface-solid-9',
    10: 'text-on-surface-solid-10',
    11: 'text-on-surface-solid-11',
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

  private surfaceRoleClasses: Record<string, string> = {
    app: 'bg-surface-app',
    canvas: 'bg-surface-canvas',
    card: 'bg-surface-card',
    panel: 'bg-surface-panel',
    popover: 'bg-surface-popover',
    overlayContent: 'bg-surface-overlay-content',
    inset: 'bg-surface-inset',
  };

  private surfaceRoleLabels: Record<string, string> = {
    app: 'App',
    canvas: 'Canvas',
    card: 'Card',
    panel: 'Panel',
    popover: 'Popover',
    overlayContent: 'Overlay Content',
    inset: 'Inset',
  };

  private surfaceRoleDescriptions: Record<string, string> = {
    app: 'Root application background, base layer',
    canvas: 'Component contrast baseline, may cover app',
    card: 'Elevated content containers, article cards',
    panel: 'Sidebars, navigation, grouped sections',
    popover: 'Tooltips, dropdowns, floating UI',
    overlayContent: 'Dialogs, overlays, blocking UI',
    inset: 'Input wells, recessed areas, code blocks',
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

  getSurfaceRoleClass = (role: string): string => {
    return this.surfaceRoleClasses[role] || '';
  };

  getSurfaceRoleLabel = (role: string): string => {
    return this.surfaceRoleLabels[role] || '';
  };

  getSurfaceRoleDescription = (role: string): string => {
    return this.surfaceRoleDescriptions[role] || '';
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
                      {{this.getSurfaceTextClass level}}
                      p-3 rounded border border-neutral-subtle flex items-center justify-between"
                  >
                    <span class="font-mono text-xs">
                      surface-solid-{{level}}
                    </span>
                    <span class="text-xs">
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
              <h4
                class="text-sm font-semibold mb-2 text-on-surface-solid-0"
              >Dark Mode</h4>
              <p class="text-xs text-on-surface-solid-0 mb-4">0 is black, 11 is
                white</p>
              <div class="space-y-2">
                {{#each this.solidLevels as |level|}}
                  <div
                    class="{{this.getSurfaceBgClass level}}
                      {{this.getSurfaceTextClass level}}
                      p-3 rounded border border-neutral-subtle flex items-center justify-between"
                  >
                    <span class="font-mono text-xs">
                      surface-solid-{{level}}
                    </span>
                    <span class="text-xs">
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

      {{else if this.isOverlayInverse}}
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

      {{else}}
        {{! Surface Roles Demonstration }}
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {{! Light mode }}
          <div class="light">
            <div
              class="p-6 rounded-lg border border-neutral-subtle bg-surface-solid-1"
            >
              <h4 class="text-sm font-semibold mb-2 text-surface-solid-11">
                Surface Roles in Light Mode
              </h4>
              <p class="text-xs text-surface-solid-10 mb-4">
                Semantic surface tokens for different UI contexts
              </p>
              <div class="space-y-2">
                {{#each this.surfaceRoles as |role|}}
                  <div
                    class="{{this.getSurfaceRoleClass role}}
                      p-4 rounded border border-neutral-subtle"
                  >
                    <div class="flex flex-col gap-1">
                      <span class="font-mono text-xs text-surface-solid-11">
                        surface-{{role}}
                      </span>
                      <span class="text-xs font-semibold text-neutral-strong">
                        {{this.getSurfaceRoleLabel role}}
                      </span>
                      <span class="text-xs text-neutral-soft">
                        {{this.getSurfaceRoleDescription role}}
                      </span>
                    </div>
                  </div>
                {{/each}}
              </div>
            </div>
          </div>

          {{! Dark mode }}
          <div class="dark">
            <div
              class="p-6 rounded-lg border border-neutral-subtle bg-surface-solid-1"
            >
              <h4 class="text-sm font-semibold mb-2 text-neutral-strong">
                Surface Roles in Dark Mode
              </h4>
              <p class="text-xs text-neutral-soft mb-4">
                Semantic surface tokens for different UI contexts
              </p>
              <div class="space-y-2">
                {{#each this.surfaceRoles as |role|}}
                  <div
                    class="{{this.getSurfaceRoleClass role}}
                      p-4 rounded border border-neutral-subtle"
                  >
                    <div class="flex flex-col gap-1">
                      <span class="font-mono text-xs text-neutral-strong">
                        surface-{{role}}
                      </span>
                      <span class="text-xs font-semibold text-neutral-strong">
                        {{this.getSurfaceRoleLabel role}}
                      </span>
                      <span class="text-xs text-neutral-soft">
                        {{this.getSurfaceRoleDescription role}}
                      </span>
                    </div>
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
