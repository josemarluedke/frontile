import { array, hash } from '@ember/helper';
import { Switch } from 'frontile';
import WorkbenchCard from 'test-app/components/workbench/card';
import WorkbenchSection from 'test-app/components/workbench/section';
import WorkbenchPanes from 'test-app/components/workbench/panes';
import WorkbenchSpecimen from 'test-app/components/workbench/specimen';
import WorkbenchStateMatrix from 'test-app/components/workbench/state-matrix';
import { SWITCH_SIZES } from 'test-app/utils/workbench/options';
import { FORM_STATES_NO_READONLY, STATE_ROWS } from './states';

<template>
  <WorkbenchCard
    @id="switch"
    @title="Switch"
    @description="An on/off toggle. Filled is on. Focus is forced on the hidden input; the track draws the ring. The track has no invalid styling: invalid shows only as the feedback message."
    @sections={{array
      (hash id="states" label="States")
      (hash id="sizes" label="Sizes")
    }}
  >
    <WorkbenchSection @id="switch-states" @title="States">
      <WorkbenchPanes @stacked={{true}}>
        <WorkbenchStateMatrix
          @rows={{STATE_ROWS}}
          @states={{FORM_STATES_NO_READONLY}}
          @rowLabel="Size"
          as |size state cell|
        >
          <Switch
            @size={{size}}
            @label={{cell.label}}
            @defaultSelected={{cell.isFilled}}
            @isDisabled={{cell.isDisabled}}
            @isInvalid={{cell.isInvalid}}
            @errors={{if cell.isInvalid (array "Required")}}
            {{cell.force}}
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
