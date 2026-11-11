import pageTitle from 'ember-page-title/helpers/page-title';
import { array, hash } from '@ember/helper';
import WorkbenchCard from 'test-app/components/workbench/card';
import WorkbenchSection from 'test-app/components/workbench/section';
import WorkbenchPanes from 'test-app/components/workbench/panes';
import WorkbenchSwatch from 'test-app/components/workbench/swatch';

const ROLES = [
  'neutral',
  'primary',
  'secondary',
  'tertiary',
  'success',
  'warning',
  'danger'
] as const;
const LEVELS = [
  'subtle',
  'muted',
  'soft',
  'mild',
  'DEFAULT',
  'firm',
  'strong',
  'bolder'
] as const;

interface Pair {
  token: string;
  onToken: string;
}

/** DEFAULT is the bare `{role}` / `on-{role}`. */
function pairs(role: string): Pair[] {
  return LEVELS.map((level) =>
    level === 'DEFAULT'
      ? { token: role, onToken: `on-${role}` }
      : { token: `${role}-${level}`, onToken: `on-${role}-${level}` }
  );
}

const CARDS = ROLES.map((role) => ({
  role,
  id: `theme-${role}`,
  pairs: pairs(role)
}));

const SURFACES = [
  'app',
  'canvas',
  'card',
  'table',
  'drawer',
  'input',
  'modal'
].map((name) => `surface-${name}`);
const OVERLAY_LEVELS = ['subtle', 'soft', 'mild', 'firm', 'strong'];
const OVERLAYS = OVERLAY_LEVELS.map((l) => `surface-overlay-${l}`);
const LIFTS = OVERLAY_LEVELS.map((l) => `surface-lift-${l}`);
const UTILITY = ['background', 'focus', 'divider'];

const GRID = 'grid grid-cols-2 gap-2';

<template>
  {{pageTitle "Theme"}}
  <h1 class="text-neutral-bolder mb-6 text-2xl font-semibold">Theme</h1>

  <div class="flex flex-col gap-8">
    {{#each CARDS as |card|}}
      <WorkbenchCard
        @id={{card.id}}
        @title={{card.role}}
        @description="The {{card.role}} role at each level, with its on-* contrast color."
        @sections={{array (hash id="levels" label="Levels")}}
      >
        <WorkbenchSection @id="{{card.id}}-levels" @title="Levels">
          <WorkbenchPanes as |scheme|>
            <div class={{GRID}} data-scheme={{scheme}}>
              {{#each card.pairs as |p|}}
                <WorkbenchSwatch @token={{p.token}} @onToken={{p.onToken}} />
              {{/each}}
            </div>
          </WorkbenchPanes>
        </WorkbenchSection>
      </WorkbenchCard>
    {{/each}}

    <WorkbenchCard
      @id="theme-surfaces"
      @title="Surfaces"
      @description="Surface roles, each inset on the canvas. Only input, modal and drawer have an on-* color."
      @sections={{array (hash id="roles" label="Roles")}}
    >
      <WorkbenchSection @id="theme-surfaces-roles" @title="Roles">
        <WorkbenchPanes as |scheme|>
          <div class={{GRID}} data-scheme={{scheme}}>
            {{#each SURFACES as |token|}}
              <div class="bg-surface-canvas rounded-md p-2">
                <WorkbenchSwatch @token={{token}} />
              </div>
            {{/each}}
          </div>
        </WorkbenchPanes>
      </WorkbenchSection>
    </WorkbenchCard>

    <WorkbenchCard
      @id="theme-overlays"
      @title="Overlays and lifts"
      @description="Overlays sit on the app surface; lifts sit on primary."
      @sections={{array
        (hash id="overlays" label="Overlays")
        (hash id="lifts" label="Lifts")
      }}
    >
      <WorkbenchSection @id="theme-overlays-overlays" @title="Overlays">
        <WorkbenchPanes as |scheme|>
          <div class={{GRID}} data-scheme={{scheme}}>
            {{#each OVERLAYS as |token|}}
              <WorkbenchSwatch @token={{token}} />
            {{/each}}
          </div>
        </WorkbenchPanes>
      </WorkbenchSection>
      <WorkbenchSection @id="theme-overlays-lifts" @title="Lifts">
        <WorkbenchPanes as |scheme|>
          <div class={{GRID}} data-scheme={{scheme}}>
            {{#each LIFTS as |token|}}
              <div class="bg-primary rounded-md p-2">
                <WorkbenchSwatch @token={{token}} />
              </div>
            {{/each}}
          </div>
        </WorkbenchPanes>
      </WorkbenchSection>
    </WorkbenchCard>

    <WorkbenchCard
      @id="theme-utility"
      @title="Utility"
      @description="Background, focus ring and divider colors."
      @sections={{array (hash id="colors" label="Colors")}}
    >
      <WorkbenchSection @id="theme-utility-colors" @title="Colors">
        <WorkbenchPanes as |scheme|>
          <div class={{GRID}} data-scheme={{scheme}}>
            {{#each UTILITY as |token|}}
              <WorkbenchSwatch @token={{token}} />
            {{/each}}
          </div>
        </WorkbenchPanes>
      </WorkbenchSection>
    </WorkbenchCard>
  </div>
</template>
