import { array, hash } from '@ember/helper';
import { CheckboxGroup } from 'frontile';
import WorkbenchCard from 'test-app/components/workbench/card';
import WorkbenchSection from 'test-app/components/workbench/section';
import WorkbenchPanes from 'test-app/components/workbench/panes';
import WorkbenchSpecimen from 'test-app/components/workbench/specimen';
import WorkbenchStateMatrix from 'test-app/components/workbench/state-matrix';
import { CHECKBOX_GROUP_SIZES } from 'test-app/utils/workbench/options';
import { FORM_STATES_NO_READONLY, STATE_ROWS } from './states';

<template>
  <WorkbenchCard
    @id="checkbox-group"
    @title="CheckboxGroup"
    @description="Checkboxes under one label. Focus is forced on the first option. Invalid shows as the group's feedback message; the options themselves have no invalid styling."
    @sections={{array
      (hash id="states" label="States")
      (hash id="sizes" label="Sizes")
    }}
  >
    <WorkbenchSection @id="checkbox-group-states" @title="States">
      <WorkbenchPanes @stacked={{true}}>
        <WorkbenchStateMatrix
          @rows={{STATE_ROWS}}
          @states={{FORM_STATES_NO_READONLY}}
          @rowLabel="Size"
          as |size state cell|
        >
          <CheckboxGroup
            @size={{size}}
            @label={{state}}
            @isDisabled={{cell.isDisabled}}
            @isInvalid={{cell.isInvalid}}
            @errors={{if cell.isInvalid (array "Required")}}
            as |Checkbox|
          >
            <Checkbox
              @label="Email"
              @checked={{cell.isFilled}}
              {{cell.force}}
            />
            <Checkbox @label="SMS" />
          </CheckboxGroup>
        </WorkbenchStateMatrix>
      </WorkbenchPanes>
    </WorkbenchSection>

    <WorkbenchSection @id="checkbox-group-sizes" @title="Sizes">
      <div class="flex flex-wrap items-start gap-8">
        {{#each CHECKBOX_GROUP_SIZES as |size|}}
          <WorkbenchSpecimen @label={{size}}>
            <CheckboxGroup
              @size={{size}}
              @label="Notify me by"
              @description="Help text"
              as |Checkbox|
            >
              <Checkbox @label="Email" @checked={{true}} />
              <Checkbox @label="SMS" />
            </CheckboxGroup>
          </WorkbenchSpecimen>
        {{/each}}
        <WorkbenchSpecimen @label="horizontal">
          <CheckboxGroup
            @label="Notify me by"
            @orientation="horizontal"
            as |Checkbox|
          >
            <Checkbox @label="Email" @checked={{true}} />
            <Checkbox @label="SMS" />
            <Checkbox @label="Push" />
          </CheckboxGroup>
        </WorkbenchSpecimen>
      </div>
    </WorkbenchSection>
  </WorkbenchCard>
</template>
