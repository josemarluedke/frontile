import { array, hash } from '@ember/helper';
import { Select } from 'frontile';
import WorkbenchCard from 'test-app/components/workbench/card';
import WorkbenchSection from 'test-app/components/workbench/section';
import WorkbenchPanes from 'test-app/components/workbench/panes';
import WorkbenchSpecimen from 'test-app/components/workbench/specimen';
import WorkbenchStateMatrix from 'test-app/components/workbench/state-matrix';
import forceWithin from 'test-app/utils/workbench/force-within';
import { SELECT_SIZES } from 'test-app/utils/workbench/options';
import { FORM_STATES_NO_READONLY, SELECT_ITEMS, STATE_ROWS } from './states';

// Select's `...attributes` lands on its outer wrapper, but the focus style is
// `focus:` on the trigger button inside, so the force attribute goes there.
// Scoped to the field: the hidden native mirror `<select>` earlier in the DOM
// is also `data-part="input"`.
const TRIGGER = '[data-part="chips-field"] > [data-part="input"]';

<template>
  <WorkbenchCard
    @id="select"
    @title="Select"
    @description="A custom listbox select. Focus is forced on the trigger button, where the focus style lives. Single-mode Select shows no invalid styling (library bug: the trigger never gets aria-invalid); the invalid columns show that as-is."
    @sections={{array
      (hash id="states" label="States")
      (hash id="sizes" label="Sizes")
    }}
  >
    <WorkbenchSection @id="select-states" @title="States">
      <WorkbenchPanes @stacked={{true}}>
        <WorkbenchStateMatrix
          @rows={{STATE_ROWS}}
          @states={{FORM_STATES_NO_READONLY}}
          @rowLabel="Size"
          as |size state cell|
        >
          <div class="w-28">
            <Select
              @items={{SELECT_ITEMS}}
              @inputSize={{size}}
              @placeholder="Choose"
              @selectedKey={{if cell.isFilled "Banana"}}
              @isDisabled={{cell.isDisabled}}
              @isInvalid={{cell.isInvalid}}
              {{forceWithin cell.attribute TRIGGER}}
            />
          </div>
        </WorkbenchStateMatrix>
      </WorkbenchPanes>
    </WorkbenchSection>

    <WorkbenchSection @id="select-sizes" @title="Sizes">
      <div class="grid gap-6 sm:grid-cols-3">
        {{#each SELECT_SIZES as |size|}}
          <WorkbenchSpecimen @label={{size}}>
            <Select
              @items={{SELECT_ITEMS}}
              @inputSize={{size}}
              @label="Label"
              @description="Help text"
              @placeholder="Choose a fruit"
            />
          </WorkbenchSpecimen>
        {{/each}}
      </div>
    </WorkbenchSection>
  </WorkbenchCard>
</template>
