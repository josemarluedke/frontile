import { array, hash } from '@ember/helper';
import { Radio } from 'frontile';
import WorkbenchCard from 'test-app/components/workbench/card';
import WorkbenchSection from 'test-app/components/workbench/section';
import WorkbenchPanes from 'test-app/components/workbench/panes';
import WorkbenchSpecimen from 'test-app/components/workbench/specimen';
import WorkbenchStateMatrix from 'test-app/components/workbench/state-matrix';
import { RADIO_SIZES } from 'test-app/utils/workbench/options';
import { FORM_STATES_NO_READONLY, STATE_ROWS } from './states';

<template>
  <WorkbenchCard
    @id="radio"
    @title="Radio"
    @description="A single radio. Filled is selected; a radio has no read-only mode. Each cell has its own name so the browser does not group them. The radio itself has no invalid styling: invalid shows only as the feedback message."
    @sections={{array
      (hash id="states" label="States")
      (hash id="sizes" label="Sizes")
    }}
  >
    <WorkbenchSection @id="radio-states" @title="States">
      <WorkbenchPanes @stacked={{true}} as |scheme|>
        <WorkbenchStateMatrix
          @rows={{STATE_ROWS}}
          @states={{FORM_STATES_NO_READONLY}}
          @rowLabel="Size"
          as |size state cell|
        >
          <Radio
            @size={{size}}
            @name="radio-{{scheme}}-{{state}}"
            @value="on"
            @checkedValue={{if cell.isFilled "on"}}
            @label={{state}}
            @isDisabled={{cell.isDisabled}}
            @isInvalid={{cell.isInvalid}}
            @errors={{if cell.isInvalid (array "Required")}}
            {{cell.force}}
          />
        </WorkbenchStateMatrix>
      </WorkbenchPanes>
    </WorkbenchSection>

    <WorkbenchSection @id="radio-sizes" @title="Sizes">
      <div class="flex flex-wrap items-start gap-8">
        {{#each RADIO_SIZES as |size|}}
          <WorkbenchSpecimen @label={{size}}>
            <Radio
              @size={{size}}
              @name="radio-size-{{size}}"
              @value="on"
              @checkedValue="on"
              @label="Standard shipping"
              @description="Help text"
            />
          </WorkbenchSpecimen>
        {{/each}}
      </div>
    </WorkbenchSection>
  </WorkbenchCard>
</template>
