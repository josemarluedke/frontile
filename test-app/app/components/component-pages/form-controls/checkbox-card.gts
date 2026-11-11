import { array, hash } from '@ember/helper';
import { Checkbox } from 'frontile';
import WorkbenchCard from 'test-app/components/workbench/card';
import WorkbenchSection from 'test-app/components/workbench/section';
import WorkbenchPanes from 'test-app/components/workbench/panes';
import WorkbenchSpecimen from 'test-app/components/workbench/specimen';
import WorkbenchStateMatrix from 'test-app/components/workbench/state-matrix';
import { CHECKBOX_SIZES } from 'test-app/utils/workbench/options';
import { FORM_STATES_NO_READONLY, STATE_ROWS } from './states';

<template>
  <WorkbenchCard
    @id="checkbox"
    @title="Checkbox"
    @description="A single checkbox. Filled is checked; a checkbox has no read-only mode. The box itself has no invalid styling: invalid shows only as the feedback message."
    @sections={{array
      (hash id="states" label="States")
      (hash id="sizes" label="Sizes")
    }}
  >
    <WorkbenchSection @id="checkbox-states" @title="States">
      <WorkbenchPanes @stacked={{true}}>
        <WorkbenchStateMatrix
          @rows={{STATE_ROWS}}
          @states={{FORM_STATES_NO_READONLY}}
          @rowLabel="Size"
          as |size state cell|
        >
          <Checkbox
            @size={{size}}
            @label={{state}}
            @checked={{cell.isFilled}}
            @isDisabled={{cell.isDisabled}}
            @isInvalid={{cell.isInvalid}}
            @errors={{if cell.isInvalid (array "Required")}}
            {{cell.force}}
          />
        </WorkbenchStateMatrix>
      </WorkbenchPanes>
    </WorkbenchSection>

    <WorkbenchSection @id="checkbox-sizes" @title="Sizes">
      <div class="flex flex-wrap items-start gap-8">
        {{#each CHECKBOX_SIZES as |size|}}
          <WorkbenchSpecimen @label={{size}}>
            <Checkbox
              @size={{size}}
              @label="Remember me"
              @description="Help text"
              @checked={{true}}
            />
          </WorkbenchSpecimen>
        {{/each}}
      </div>
    </WorkbenchSection>
  </WorkbenchCard>
</template>
