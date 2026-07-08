import Component from '@glimmer/component';

import { surfaceOverlayLevels } from '../../utils/theme-colors';

interface SurfaceShowcaseSignature {
  Args: {
    type: 'overlay' | 'roles';
    sideBySide?: boolean;
  };
}

export default class SurfaceShowcase extends Component<SurfaceShowcaseSignature> {
  get overlayLevels() {
    return surfaceOverlayLevels;
  }

  get isOverlay() {
    return this.args.type === 'overlay';
  }

  get isRoles() {
    return this.args.type === 'roles';
  }

  get surfaceRoles() {
    return ['app', 'canvas', 'card', 'modal', 'input'];
  }

  private overlayClasses: Record<string, string> = {
    subtle: 'bg-surface-overlay-subtle',
    soft: 'bg-surface-overlay-soft',
    medium: 'bg-surface-overlay-medium',
    strong: 'bg-surface-overlay-strong',
  };

  private surfaceRoleClasses: Record<string, string> = {
    app: 'bg-surface-app',
    canvas: 'bg-surface-canvas',
    card: 'bg-surface-card',
    modal: 'bg-surface-modal',
    input: 'bg-surface-input',
  };

  private surfaceRoleLabels: Record<string, string> = {
    app: 'App',
    canvas: 'Canvas',
    card: 'Card',
    modal: 'Modal',
    input: 'Input',
  };

  private surfaceRoleDescriptions: Record<string, string> = {
    app: 'Root application background, base layer',
    canvas: 'Component contrast baseline, may cover app',
    card: 'Elevated content containers, article cards',
    modal: 'Modals, drawers, popovers, dropdowns — highest elevation',
    input: 'Form controls: inputs, checkboxes, radios',
  };

  getOverlayClass = (level: string): string => {
    return this.overlayClasses[level] || '';
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
      {{#if this.isOverlay}}
        {{! Overlay Demonstration }}
        <div
          class="p-6 rounded-lg bg-surface-app border border-neutral-subtle"
        >
          <h4 class="text-sm font-semibold mb-4 text-neutral-strong">
            Surface Overlay (on an app base)
          </h4>
          <p class="text-sm text-neutral-firm mb-4">
            These overlays are translucent and stack on top of a solid base
            background.
          </p>

          {{! Stack overlays }}
          <div class="space-y-4">
            {{#each this.overlayLevels as |level|}}
              <div class="{{this.getOverlayClass level}} p-6 rounded">
                <div class="flex items-center justify-between">
                  <span class="font-mono text-sm text-neutral-strong">
                    surface-overlay-{{level}}
                  </span>
                  <span class="text-xs text-neutral-firm">
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
            <p class="text-sm text-neutral-firm mb-4">
              Overlays can stack on top of each other:
            </p>
            <div class="bg-surface-overlay-soft p-4 rounded">
              <div class="text-sm text-neutral-strong mb-2">Layer 1 (soft)</div>
              <div class="bg-surface-overlay-medium p-4 rounded">
                <div class="text-sm text-neutral-strong mb-2">Layer 2 (medium)</div>
                <div class="bg-surface-overlay-strong p-4 rounded">
                  <div class="text-sm text-neutral-strong">Layer 3 (strong)</div>
                </div>
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
              class="p-6 rounded-lg border border-neutral-subtle bg-surface-app"
            >
              <h4 class="text-sm font-semibold mb-2 text-neutral-strong">
                Surface Roles in Light Mode
              </h4>
              <p class="text-xs text-neutral-firm mb-4">
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
                      <span class="text-xs text-neutral-firm">
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
              class="p-6 rounded-lg border border-neutral-subtle bg-surface-app"
            >
              <h4 class="text-sm font-semibold mb-2 text-neutral-strong">
                Surface Roles in Dark Mode
              </h4>
              <p class="text-xs text-neutral-firm mb-4">
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
                      <span class="text-xs text-neutral-firm">
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
