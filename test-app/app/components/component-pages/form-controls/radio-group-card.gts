import { array, hash } from '@ember/helper';
import { RadioGroup } from 'frontile';
import WorkbenchCard from 'test-app/components/workbench/card';
import WorkbenchSection from 'test-app/components/workbench/section';
import WorkbenchPanes from 'test-app/components/workbench/panes';
import WorkbenchSpecimen from 'test-app/components/workbench/specimen';
import WorkbenchStateMatrix from 'test-app/components/workbench/state-matrix';
import { RADIO_GROUP_SIZES } from 'test-app/utils/workbench/options';
import { FORM_STATES_NO_READONLY, STATE_ROWS } from './states';

<template>
  <WorkbenchCard
    @id="radio-group"
    @title="RadioGroup"
    @description="Radios under one label. Focus is forced on the first option. Invalid shows as the group's feedback message; the options themselves have no invalid styling."
    @sections={{array
      (hash id="states" label="States")
      (hash id="sizes" label="Sizes")
    }}
  >
    <WorkbenchSection @id="radio-group-states" @title="States">
      <WorkbenchPanes @stacked={{true}} as |scheme|>
        <WorkbenchStateMatrix
          @rows={{STATE_ROWS}}
          @states={{FORM_STATES_NO_READONLY}}
          @rowLabel="Size"
          as |size state cell|
        >
          <RadioGroup
            @size={{size}}
            @name="radio-group-{{scheme}}-{{state}}"
            @label={{state}}
            @value={{if cell.isFilled "standard"}}
            @isDisabled={{cell.isDisabled}}
            @isInvalid={{cell.isInvalid}}
            @errors={{if cell.isInvalid (array "Required")}}
            as |Radio|
          >
            <Radio @value="standard" @label="Standard" {{cell.force}} />
            <Radio @value="express" @label="Express" />
          </RadioGroup>
        </WorkbenchStateMatrix>
      </WorkbenchPanes>
    </WorkbenchSection>

    <WorkbenchSection @id="radio-group-sizes" @title="Sizes">
      <div class="flex flex-wrap items-start gap-8">
        {{#each RADIO_GROUP_SIZES as |size|}}
          <WorkbenchSpecimen @label={{size}}>
            <RadioGroup
              @size={{size}}
              @name="radio-group-size-{{size}}"
              @label="Shipping"
              @description="Help text"
              @value="standard"
              as |Radio|
            >
              <Radio @value="standard" @label="Standard" />
              <Radio @value="express" @label="Express" />
            </RadioGroup>
          </WorkbenchSpecimen>
        {{/each}}
        <WorkbenchSpecimen @label="horizontal">
          <RadioGroup
            @name="radio-group-horizontal"
            @label="Shipping"
            @orientation="horizontal"
            @value="standard"
            as |Radio|
          >
            <Radio @value="standard" @label="Standard" />
            <Radio @value="express" @label="Express" />
            <Radio @value="pickup" @label="Pickup" />
          </RadioGroup>
        </WorkbenchSpecimen>
      </div>
    </WorkbenchSection>
  </WorkbenchCard>
</template>
