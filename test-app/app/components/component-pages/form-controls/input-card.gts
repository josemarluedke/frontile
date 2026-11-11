import { array, hash } from '@ember/helper';
import { Input, Textarea } from 'frontile';
import WorkbenchCard from 'test-app/components/workbench/card';
import WorkbenchSection from 'test-app/components/workbench/section';
import WorkbenchPanes from 'test-app/components/workbench/panes';
import WorkbenchSpecimen from 'test-app/components/workbench/specimen';
import WorkbenchStateMatrix from 'test-app/components/workbench/state-matrix';
import { INPUT_SIZES } from 'test-app/utils/workbench/options';
import { ALL_FORM_STATES, STATE_ROWS } from './states';

<template>
  <WorkbenchCard
    @id="input"
    @title="Input"
    @description="A single-line text field. Focus is frozen; every other column is a real value or argument."
    @sections={{array
      (hash id="states" label="States")
      (hash id="sizes" label="Sizes")
      (hash id="content" label="Start / end content")
      (hash id="multiline" label="Multiline")
    }}
  >
    <WorkbenchSection @id="input-states" @title="States">
      <WorkbenchPanes @stacked={{true}}>
        <WorkbenchStateMatrix
          @rows={{STATE_ROWS}}
          @states={{ALL_FORM_STATES}}
          @rowLabel="Size"
          as |size state cell|
        >
          <div class="w-28">
            <Input
              @size={{size}}
              @value={{if cell.isFilled "Ada Lovelace"}}
              @isDisabled={{cell.isDisabled}}
              @isInvalid={{cell.isInvalid}}
              readonly={{cell.isReadonly}}
              placeholder="Placeholder"
              aria-label="Input {{state}}"
              {{cell.force}}
            />
          </div>
        </WorkbenchStateMatrix>
      </WorkbenchPanes>
    </WorkbenchSection>

    <WorkbenchSection @id="input-sizes" @title="Sizes">
      <div class="grid gap-6 sm:grid-cols-3">
        {{#each INPUT_SIZES as |size|}}
          <WorkbenchSpecimen @label={{size}}>
            <Input
              @size={{size}}
              @label="Label"
              @description="Help text"
              placeholder="Placeholder"
            />
          </WorkbenchSpecimen>
        {{/each}}
      </div>
    </WorkbenchSection>

    <WorkbenchSection
      @id="input-content"
      @title="Start / end content"
      @subtitle="Blocks inside the field, and the clear button"
    >
      <div class="grid gap-6 sm:grid-cols-3">
        <WorkbenchSpecimen @label="start">
          <Input @label="Amount" placeholder="0.00">
            <:startContent>$</:startContent>
          </Input>
        </WorkbenchSpecimen>
        <WorkbenchSpecimen @label="end">
          <Input @label="Weight" placeholder="0">
            <:endContent>kg</:endContent>
          </Input>
        </WorkbenchSpecimen>
        <WorkbenchSpecimen @label="clearable">
          <Input @label="Search" @value="frontile" @isClearable={{true}} />
        </WorkbenchSpecimen>
      </div>
    </WorkbenchSection>

    <WorkbenchSection
      @id="input-multiline"
      @title="Multiline"
      @subtitle="Textarea shares Input's field styles; its own card has every state"
    >
      <div class="grid gap-6 sm:grid-cols-2">
        <WorkbenchSpecimen @label="textarea">
          <Textarea @label="Notes" placeholder="Write something" />
        </WorkbenchSpecimen>
        <WorkbenchSpecimen @label="textarea, invalid">
          <Textarea
            @label="Notes"
            @value="Too short"
            @errors={{array "Write at least 20 characters"}}
          />
        </WorkbenchSpecimen>
      </div>
    </WorkbenchSection>
  </WorkbenchCard>
</template>
