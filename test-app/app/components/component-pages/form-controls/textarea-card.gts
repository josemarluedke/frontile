import { array, hash } from '@ember/helper';
import { Textarea } from 'frontile';
import WorkbenchCard from 'test-app/components/workbench/card';
import WorkbenchSection from 'test-app/components/workbench/section';
import WorkbenchPanes from 'test-app/components/workbench/panes';
import WorkbenchSpecimen from 'test-app/components/workbench/specimen';
import WorkbenchStateMatrix from 'test-app/components/workbench/state-matrix';
import { TEXTAREA_SIZES } from 'test-app/utils/workbench/options';
import { ALL_FORM_STATES, STATE_ROWS } from './states';

<template>
  <WorkbenchCard
    @id="textarea"
    @title="Textarea"
    @description="A multi-line text field with Input's field styles."
    @sections={{array
      (hash id="states" label="States")
      (hash id="sizes" label="Sizes")
    }}
  >
    <WorkbenchSection @id="textarea-states" @title="States">
      <WorkbenchPanes @stacked={{true}}>
        <WorkbenchStateMatrix
          @rows={{STATE_ROWS}}
          @states={{ALL_FORM_STATES}}
          @rowLabel="Size"
          as |size state cell|
        >
          <div class="w-28">
            <Textarea
              @size={{size}}
              @value={{if cell.isFilled "Two lines of text that wrap."}}
              @isDisabled={{cell.isDisabled}}
              @isInvalid={{cell.isInvalid}}
              readonly={{cell.isReadonly}}
              placeholder="Placeholder"
              aria-label="Textarea {{state}}"
              {{cell.force}}
            />
          </div>
        </WorkbenchStateMatrix>
      </WorkbenchPanes>
    </WorkbenchSection>

    <WorkbenchSection @id="textarea-sizes" @title="Sizes">
      <div class="grid gap-6 sm:grid-cols-3">
        {{#each TEXTAREA_SIZES as |size|}}
          <WorkbenchSpecimen @label={{size}}>
            <Textarea
              @size={{size}}
              @label="Label"
              @description="Help text"
              placeholder="Placeholder"
            />
          </WorkbenchSpecimen>
        {{/each}}
      </div>
    </WorkbenchSection>
  </WorkbenchCard>
</template>
