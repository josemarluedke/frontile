import { array, hash } from '@ember/helper';
import { NativeSelect } from 'frontile';
import WorkbenchCard from 'test-app/components/workbench/card';
import WorkbenchSection from 'test-app/components/workbench/section';
import WorkbenchPanes from 'test-app/components/workbench/panes';
import WorkbenchSpecimen from 'test-app/components/workbench/specimen';
import WorkbenchStateMatrix from 'test-app/components/workbench/state-matrix';
import { NATIVE_SELECT_SIZES } from 'test-app/utils/workbench/options';
import { FORM_STATES_NO_READONLY, SELECT_ITEMS, STATE_ROWS } from './states';

<template>
  <WorkbenchCard
    @id="native-select"
    @title="NativeSelect"
    @description="The browser's own select with Input's field styles. A select has no read-only mode. The component ignores @isDisabled (library bug), so the disabled cell uses the native disabled attribute."
    @sections={{array
      (hash id="states" label="States")
      (hash id="sizes" label="Sizes")
    }}
  >
    <WorkbenchSection @id="native-select-states" @title="States">
      <WorkbenchPanes @stacked={{true}}>
        <WorkbenchStateMatrix
          @rows={{STATE_ROWS}}
          @states={{FORM_STATES_NO_READONLY}}
          @rowLabel="Size"
          as |size state cell|
        >
          <div class="w-28">
            {{! NativeSelect never binds @isDisabled to its <select>, so the
                native attribute is what disables it. }}
            <NativeSelect
              @items={{SELECT_ITEMS}}
              @size={{size}}
              @allowEmpty={{true}}
              @placeholder="Choose"
              @selectedKey={{if cell.isFilled "Banana" ""}}
              @isInvalid={{cell.isInvalid}}
              disabled={{cell.isDisabled}}
              aria-label="NativeSelect {{state}}"
              {{cell.force}}
            />
          </div>
        </WorkbenchStateMatrix>
      </WorkbenchPanes>
    </WorkbenchSection>

    <WorkbenchSection @id="native-select-sizes" @title="Sizes">
      <div class="grid gap-6 sm:grid-cols-3">
        {{#each NATIVE_SELECT_SIZES as |size|}}
          <WorkbenchSpecimen @label={{size}}>
            <NativeSelect
              @items={{SELECT_ITEMS}}
              @size={{size}}
              @label="Label"
              @description="Help text"
              @allowEmpty={{true}}
              @placeholder="Choose a fruit"
            />
          </WorkbenchSpecimen>
        {{/each}}
      </div>
    </WorkbenchSection>
  </WorkbenchCard>
</template>
