import { array, hash } from '@ember/helper';
import { Switch } from 'frontile';
import WorkbenchCard from 'test-app/components/workbench/card';
import WorkbenchSection from 'test-app/components/workbench/section';
import WorkbenchPanes from 'test-app/components/workbench/panes';
import WorkbenchSpecimen from 'test-app/components/workbench/specimen';
import WorkbenchStateMatrix from 'test-app/components/workbench/state-matrix';
import { SWITCH_SIZES } from 'test-app/utils/workbench/options';
import { FORM_STATES_NO_READONLY_NO_FOCUS, STATE_ROWS } from './states';

<template>
  <WorkbenchCard
    @id="switch"
    @title="Switch"
    @description="An on/off toggle. Filled is on. The track's focus ring colour only follows real keyboard focus, so a frozen focus would be drawn wrong and the focus columns are omitted; tab to a switch to see it. The track has no invalid styling: invalid shows only as the feedback message."
    @sections={{array
      (hash id="states" label="States")
      (hash id="sizes" label="Sizes")
    }}
  >
    <WorkbenchSection @id="switch-states" @title="States">
      <WorkbenchPanes @stacked={{true}}>
        <WorkbenchStateMatrix
          @rows={{STATE_ROWS}}
          @states={{FORM_STATES_NO_READONLY_NO_FOCUS}}
          @rowLabel="Size"
          as |size state cell|
        >
          <Switch
            @size={{size}}
            @label={{state}}
            @defaultSelected={{cell.isFilled}}
            @isDisabled={{cell.isDisabled}}
            @isInvalid={{cell.isInvalid}}
            @errors={{if cell.isInvalid (array "Required")}}
          />
        </WorkbenchStateMatrix>
      </WorkbenchPanes>
    </WorkbenchSection>

    <WorkbenchSection @id="switch-sizes" @title="Sizes">
      <div class="flex flex-wrap items-start gap-8">
        {{#each SWITCH_SIZES as |size|}}
          <WorkbenchSpecimen @label={{size}}>
            <div class="flex flex-col gap-2">
              <Switch @size={{size}} @label="Off" />
              <Switch
                @size={{size}}
                @label="On"
                @description="Help text"
                @defaultSelected={{true}}
              />
            </div>
          </WorkbenchSpecimen>
        {{/each}}
      </div>
    </WorkbenchSection>
  </WorkbenchCard>
</template>
