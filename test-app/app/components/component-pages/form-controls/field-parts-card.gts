import { array, hash } from '@ember/helper';
import { FormControl, FormDescription, FormFeedback, Label } from 'frontile';
import WorkbenchCard from 'test-app/components/workbench/card';
import WorkbenchSection from 'test-app/components/workbench/section';
import WorkbenchPanes from 'test-app/components/workbench/panes';
import WorkbenchSpecimen from 'test-app/components/workbench/specimen';
import {
  FORM_DESCRIPTION_SIZES,
  FORM_FEEDBACK_SIZES,
  FORM_FEEDBACK_STATUSES,
  LABEL_SIZES
} from 'test-app/utils/workbench/options';

<template>
  <WorkbenchCard
    @id="field-parts"
    @title="Field parts"
    @description="The pieces every control is built from: Label, FormDescription, FormFeedback, and FormControl, which wires them to the control."
    @sections={{array
      (hash id="states" label="States")
      (hash id="sizes" label="Sizes")
    }}
  >
    <WorkbenchSection
      @id="field-parts-states"
      @title="States"
      @subtitle="Label, feedback statuses, and a composed FormControl"
    >
      <WorkbenchPanes>
        <div class="flex flex-col gap-4">
          <WorkbenchSpecimen @label="label">
            <Label>Email address</Label>
          </WorkbenchSpecimen>
          <WorkbenchSpecimen @label="label, required">
            <Label @isRequired={{true}}>Email address</Label>
          </WorkbenchSpecimen>
          <WorkbenchSpecimen @label="description">
            <FormDescription>We never share your email.</FormDescription>
          </WorkbenchSpecimen>
          {{#each FORM_FEEDBACK_STATUSES as |status|}}
            <WorkbenchSpecimen @label="feedback, {{status}}">
              <FormFeedback
                @status={{status}}
                @messages="A {{status}} message"
              />
            </WorkbenchSpecimen>
          {{/each}}
          <WorkbenchSpecimen @label="form control">
            <FormControl
              @label="Email address"
              @description="We never share your email."
              @isRequired={{true}}
              as |c|
            >
              <input
                id={{c.id}}
                aria-describedby={{c.describedBy true}}
                class="border-neutral-soft rounded-md border px-2 py-1"
              />
            </FormControl>
          </WorkbenchSpecimen>
          <WorkbenchSpecimen @label="form control, invalid">
            <FormControl
              @label="Email address"
              @description="We never share your email."
              @errors={{array "Enter a valid email address"}}
              as |c|
            >
              <input
                id={{c.id}}
                aria-invalid="true"
                aria-describedby={{c.describedBy true true}}
                class="border-danger rounded-md border px-2 py-1"
              />
            </FormControl>
          </WorkbenchSpecimen>
        </div>
      </WorkbenchPanes>
    </WorkbenchSection>

    <WorkbenchSection @id="field-parts-sizes" @title="Sizes">
      <div class="grid gap-6 sm:grid-cols-3">
        {{#each LABEL_SIZES as |size|}}
          <WorkbenchSpecimen @label="label {{size}}" @measure={{true}}>
            <Label @size={{size}}>Email address</Label>
          </WorkbenchSpecimen>
        {{/each}}
        {{#each FORM_DESCRIPTION_SIZES as |size|}}
          <WorkbenchSpecimen @label="description {{size}}" @measure={{true}}>
            <FormDescription @size={{size}}>We never share your email.</FormDescription>
          </WorkbenchSpecimen>
        {{/each}}
        {{#each FORM_FEEDBACK_SIZES as |size|}}
          <WorkbenchSpecimen @label="feedback {{size}}" @measure={{true}}>
            <FormFeedback @size={{size}} @messages="Enter a valid email" />
          </WorkbenchSpecimen>
        {{/each}}
      </div>
    </WorkbenchSection>
  </WorkbenchCard>
</template>
