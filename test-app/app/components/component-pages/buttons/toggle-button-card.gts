import { array, hash } from '@ember/helper';
import { ToggleButton } from 'frontile';
import WorkbenchCard from 'test-app/components/workbench/card';
import WorkbenchSection from 'test-app/components/workbench/section';
import WorkbenchPanes from 'test-app/components/workbench/panes';
import WorkbenchSpecimen from 'test-app/components/workbench/specimen';
import WorkbenchStateMatrix from 'test-app/components/workbench/state-matrix';
import ToggleButtonLive from './toggle-button-live';
import {
  TOGGLE_BUTTON_COLORS,
  TOGGLE_BUTTON_SIZES
} from 'test-app/utils/workbench/options';

const SELECTION = [
  { id: 'off', title: 'Off', isSelected: false },
  { id: 'on', title: 'On', isSelected: true }
];

<template>
  <WorkbenchCard
    @id="toggle-button"
    @title="ToggleButton"
    @description="A button that stays pressed. The theme styles only the outline variant, so the matrix varies color."
    @sections={{array
      (hash id="off" label="Off")
      (hash id="on" label="On")
      (hash id="sizes" label="Sizes")
      (hash id="live" label="Live")
    }}
  >
    {{#each SELECTION as |selection|}}
      <WorkbenchSection
        @id="toggle-button-{{selection.id}}"
        @title={{selection.title}}
        @subtitle="Colors by state"
      >
        <WorkbenchPanes @inverse={{true}} @stacked={{true}}>
          <WorkbenchStateMatrix
            @rows={{TOGGLE_BUTTON_COLORS}}
            @rowLabel="Color"
            data-selected={{if selection.isSelected "true" "false"}}
            as |color state cell|
          >
            <ToggleButton
              @color={{color}}
              @size="sm"
              @isSelected={{selection.isSelected}}
              aria-label="{{color}} {{selection.id}} {{state}}"
              disabled={{cell.isDisabled}}
              {{cell.force}}
            >Toggle</ToggleButton>
          </WorkbenchStateMatrix>
        </WorkbenchPanes>
      </WorkbenchSection>
    {{/each}}

    <WorkbenchSection @id="toggle-button-sizes" @title="Sizes">
      <div class="flex flex-wrap items-start gap-6">
        {{#each TOGGLE_BUTTON_SIZES as |size|}}
          <WorkbenchSpecimen @label={{size}} @measure={{true}}>
            <ToggleButton
              @size={{size}}
              @isSelected={{true}}
            >Toggle</ToggleButton>
          </WorkbenchSpecimen>
        {{/each}}
      </div>
    </WorkbenchSection>

    <WorkbenchSection
      @id="toggle-button-live"
      @title="Live"
      @subtitle="Click to toggle"
    >
      <ToggleButtonLive />
    </WorkbenchSection>
  </WorkbenchCard>
</template>
