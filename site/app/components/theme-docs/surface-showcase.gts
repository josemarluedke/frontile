import Component from '@glimmer/component';

import {
  surfaceOverlayLevels,
  surfaceLiftLevels,
} from '../../utils/theme-colors';

interface SurfaceShowcaseSignature {
  Args: {
    type: 'overlay' | 'lift' | 'roles';
    sideBySide?: boolean;
  };
}

export default class SurfaceShowcase extends Component<SurfaceShowcaseSignature> {
  get overlayLevels() {
    return surfaceOverlayLevels;
  }

  get liftLevels() {
    return surfaceLiftLevels;
  }

  get isOverlay() {
    return this.args.type === 'overlay';
  }

  get isLift() {
    return this.args.type === 'lift';
  }

  get isRoles() {
    return this.args.type === 'roles';
  }

  get surfaceRoles() {
    return ['app', 'canvas', 'card', 'table', 'modal', 'input'];
  }

  private overlayClasses: Record<string, string> = {
    subtle: 'bg-surface-overlay-subtle',
    soft: 'bg-surface-overlay-soft',
    mild: 'bg-surface-overlay-mild',
    firm: 'bg-surface-overlay-firm',
    strong: 'bg-surface-overlay-strong',
  };

  private liftClasses: Record<string, string> = {
    subtle: 'bg-surface-lift-subtle',
    soft: 'bg-surface-lift-soft',
    mild: 'bg-surface-lift-mild',
    firm: 'bg-surface-lift-firm',
    strong: 'bg-surface-lift-strong',
  };

  private surfaceRoleClasses: Record<string, string> = {
    app: 'bg-surface-app',
    canvas: 'bg-surface-canvas',
    card: 'bg-surface-card',
    table: 'bg-surface-table',
    modal: 'bg-surface-modal',
    input: 'bg-surface-input',
  };

  private surfaceRoleLabels: Record<string, string> = {
    app: 'App',
    canvas: 'Canvas',
    card: 'Card',
    table: 'Table',
    modal: 'Modal',
    input: 'Input',
  };

  private surfaceRoleDescriptions: Record<string, string> = {
    app: 'Root application background, base layer',
    canvas: 'Component contrast baseline, may cover app',
    card: 'Elevated content containers, article cards',
    table: 'Data tables — a card that must occlude, so never translucent',
    modal: 'Modals, drawers, popovers, dropdowns — highest elevation',
    input: 'Form controls: inputs, checkboxes, radios',
  };

  private overlayDescriptions: Record<string, string> = {
    subtle: 'Translucent layer',
    soft: 'Translucent layer',
    mild: 'Translucent layer',
    firm: 'Translucent layer',
    strong: 'Heaviest step — the modal/drawer backdrop in light mode',
  };

  // `strong` is the scrim step and inverts against the page — black 75% in
  // light, white 95% in dark — so its ink has to invert too. There is no
  // `on-surface-overlay-*` token: translucent veils are excluded from
  // on-color generation, since contrast depends on what shows through.
  private overlayInkClasses: Record<string, string> = {
    strong: 'text-white dark:text-black',
  };

  getOverlayClass = (level: string): string => {
    return this.overlayClasses[level] || '';
  };

  getOverlayInkClass = (level: string): string => {
    return this.overlayInkClasses[level] || 'text-neutral-strong';
  };

  getOverlayMutedInkClass = (level: string): string => {
    return this.overlayInkClasses[level]
      ? `${this.overlayInkClasses[level]} opacity-70`
      : 'text-neutral-firm';
  };

  getOverlayDescription = (level: string): string => {
    return this.overlayDescriptions[level] || 'Translucent layer';
  };

  getLiftClass = (level: string): string => {
    return this.liftClasses[level] || '';
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
        <div class="p-6 rounded-lg bg-surface-app border border-neutral-subtle">
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
                  <span
                    class="font-mono text-sm {{this.getOverlayInkClass level}}"
                  >
                    surface-overlay-{{level}}
                  </span>
                  <span class="text-xs {{this.getOverlayMutedInkClass level}}">
                    {{this.getOverlayDescription level}}
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
              <div class="bg-surface-overlay-mild p-4 rounded">
                <div class="text-sm text-neutral-strong mb-2">Layer 2 (mild)</div>
                <div class="bg-surface-overlay-firm p-4 rounded">
                  <div class="text-sm text-neutral-strong">Layer 3 (firm)</div>
                </div>
              </div>
            </div>
          </div>
        </div>

      {{else if this.isLift}}
        {{! Lift Demonstration }}
        <div
          class="p-6 rounded-lg bg-surface-canvas border border-neutral-subtle"
        >
          <h4 class="text-sm font-semibold mb-4 text-neutral-strong">
            Surface Lift (over page content)
          </h4>
          <p class="text-sm text-neutral-firm mb-4">
            Lift veils run the opposite direction from overlay — white in light
            mode, black in dark mode — so the element reads as floating above
            what it covers.
          </p>

          {{! Lift levels }}
          <div class="space-y-3">
            {{#each this.liftLevels as |level|}}
              <div class="{{this.getLiftClass level}} p-4 rounded">
                <span class="font-mono text-sm text-neutral-bolder">
                  surface-lift-{{level}}
                </span>
              </div>
            {{/each}}
          </div>

          {{! Overlay vs lift, side by side }}
          <div class="mt-6">
            <h5 class="text-sm font-semibold mb-2 text-neutral-strong">
              Overlay vs Lift
            </h5>
            <p class="text-sm text-neutral-firm mb-4">
              The same level, one from each family, on the same base:
            </p>
            <div class="grid grid-cols-2 gap-4">
              <div class="bg-surface-overlay-mild p-4 rounded text-center">
                <span class="font-mono text-xs text-neutral-strong">
                  overlay-mild
                </span>
                <p class="text-xs text-neutral-firm mt-1">recedes</p>
              </div>
              <div class="bg-surface-lift-mild p-4 rounded text-center">
                <span class="font-mono text-xs text-neutral-bolder">
                  lift-mild
                </span>
                <p class="text-xs text-neutral-firm mt-1">advances</p>
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
