import { array, concat, hash } from '@ember/helper';
import { htmlSafe, type SafeString } from '@ember/template';
import WorkbenchCard from 'test-app/components/workbench/card';
import WorkbenchSection from 'test-app/components/workbench/section';
import WorkbenchPanes from 'test-app/components/workbench/panes';
import TokenValue from './token-value';
import DisabledOpacity from './disabled-opacity';

const RADII = [
  'none',
  'xs',
  'sm',
  'md',
  'lg',
  'xl',
  '2xl',
  '3xl',
  '4xl',
  'default',
  'pill'
].map((n) => ({ name: n, token: `--radius-${n}` }));

const ELEVATIONS = [0, 1, 2, 3, 4, 5].map((n) => ({
  name: String(n),
  token: `--shadow-elevation-${n}`
}));

const ICON_SIZES = [
  'pico',
  'nano',
  'micro',
  '3xs',
  '2xs',
  'xs',
  'sm',
  'md',
  'lg',
  'xl',
  '2xl',
  '3xl',
  'kilo',
  'mega'
].map((n) => ({ name: n, token: `--size-icon-${n}` }));

const BREAKPOINTS = ['sm', 'md', 'lg', 'xl', '2xl'].map((n) => ({
  name: n,
  token: `--breakpoint-${n}`
}));

/** Style values come from the constant token lists above, never user input. */
function style(css: string): SafeString {
  return htmlSafe(css);
}

const ITEM = 'flex flex-col items-start gap-1';
const LIST = 'flex flex-wrap items-end gap-4';

<template>
  <WorkbenchCard
    @id="global-radius"
    @title="Radius"
    @description="One knob (--radius) drives the scale. Each shape shows its computed border-radius."
    @sections={{array (hash id="scale" label="Scale")}}
  >
    <WorkbenchSection @id="global-radius-scale" @title="Scale">
      <WorkbenchPanes as |scheme|>
        <div class={{LIST}} data-scheme={{scheme}}>
          {{#each RADII as |r|}}
            <div data-token-item class={{ITEM}}>
              {{! template-lint-disable no-inline-styles }}
              <div
                data-token-shape
                class="bg-primary-mild border-primary h-14 w-14 border"
                style={{style (concat "border-radius: var(" r.token ")")}}
              ></div>
              <span class="text-xs font-medium">{{r.name}}</span>
              <TokenValue @name={{r.token}} @property="border-radius" />
            </div>
          {{/each}}
        </div>
      </WorkbenchPanes>
    </WorkbenchSection>
  </WorkbenchCard>

  <WorkbenchCard
    @id="global-elevation"
    @title="Elevation"
    @description="Shadow levels 0 to 5 on raised cards."
    @sections={{array (hash id="levels" label="Levels")}}
  >
    <WorkbenchSection @id="global-elevation-levels" @title="Levels">
      <WorkbenchPanes as |scheme|>
        <div class="grid grid-cols-2 gap-4" data-scheme={{scheme}}>
          {{#each ELEVATIONS as |e|}}
            <div data-token-item class={{ITEM}}>
              {{! template-lint-disable no-inline-styles }}
              <div
                data-token-shape
                class="bg-surface-card h-16 w-full rounded-md"
                style={{style (concat "box-shadow: var(" e.token ")")}}
              ></div>
              <span class="text-xs font-medium">{{e.name}}</span>
              <TokenValue @name={{e.token}} />
            </div>
          {{/each}}
        </div>
      </WorkbenchPanes>
    </WorkbenchSection>
  </WorkbenchCard>

  <WorkbenchCard
    @id="global-icon-sizes"
    @title="Icon sizes"
    @description="Squares at each icon size, with the resolved width."
    @sections={{array (hash id="sizes" label="Sizes")}}
  >
    <WorkbenchSection @id="global-icon-sizes-sizes" @title="Sizes">
      <WorkbenchPanes as |scheme|>
        <div class={{LIST}} data-scheme={{scheme}}>
          {{#each ICON_SIZES as |s|}}
            <div data-token-item class={{ITEM}}>
              {{! template-lint-disable no-inline-styles }}
              <div
                data-token-shape
                class="bg-primary"
                style={{style
                  (concat "width: var(" s.token "); height: var(" s.token ")")
                }}
              ></div>
              <span class="text-xs font-medium">{{s.name}}</span>
              <TokenValue @name={{s.token}} @property="width" />
            </div>
          {{/each}}
        </div>
      </WorkbenchPanes>
    </WorkbenchSection>
  </WorkbenchCard>

  <WorkbenchCard
    @id="global-opacity"
    @title="Disabled opacity"
    @description="A disabled Button in each pane and the opacity it resolves to."
    @sections={{array (hash id="button" label="Button")}}
  >
    <WorkbenchSection @id="global-opacity-button" @title="Button">
      <WorkbenchPanes as |scheme|>
        <div data-scheme={{scheme}}>
          <DisabledOpacity />
        </div>
      </WorkbenchPanes>
    </WorkbenchSection>
  </WorkbenchCard>

  <WorkbenchCard
    @id="global-breakpoints"
    @title="Breakpoints"
    @description="Tailwind's responsive breakpoints, read from --breakpoint-*."
    @sections={{array (hash id="values" label="Values")}}
  >
    <WorkbenchSection @id="global-breakpoints-values" @title="Values">
      <WorkbenchPanes as |scheme|>
        <dl class="flex flex-col gap-2" data-scheme={{scheme}}>
          {{#each BREAKPOINTS as |b|}}
            <div data-token-item class="flex items-baseline gap-3">
              <dt class="w-10 text-xs font-medium">{{b.name}}</dt>
              <dd><TokenValue @name={{b.token}} /></dd>
            </div>
          {{/each}}
        </dl>
      </WorkbenchPanes>
    </WorkbenchSection>
  </WorkbenchCard>
</template>
