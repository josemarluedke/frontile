import { array, hash } from '@ember/helper';
import { ButtonGroup } from 'frontile';
import WorkbenchCard from 'test-app/components/workbench/card';
import WorkbenchSection from 'test-app/components/workbench/section';
import WorkbenchPanes from 'test-app/components/workbench/panes';
import WorkbenchSpecimen from 'test-app/components/workbench/specimen';
import {
  BUTTON_GROUP_SIZES,
  BUTTON_GROUP_VARIANTS
} from 'test-app/utils/workbench/options';

<template>
  <WorkbenchCard
    @id="button-group"
    @title="ButtonGroup"
    @description="Buttons joined into one control. The group passes variant, color and size to each button."
    @sections={{array
      (hash id="variants" label="Variants")
      (hash id="sizes" label="Sizes")
    }}
  >
    <WorkbenchSection @id="button-group-variants" @title="Variants">
      <WorkbenchPanes @inverse={{true}}>
        <div class="flex flex-col gap-4">
          {{#each BUTTON_GROUP_VARIANTS as |variant|}}
            <WorkbenchSpecimen @label={{variant}}>
              <ButtonGroup
                @variant={{variant}}
                @color="primary"
                @size="sm"
                aria-label="{{variant}} group"
                as |g|
              >
                <g.Button>Day</g.Button>
                <g.Button>Week</g.Button>
                <g.Button>Month</g.Button>
              </ButtonGroup>
            </WorkbenchSpecimen>
          {{/each}}
        </div>
      </WorkbenchPanes>
    </WorkbenchSection>

    <WorkbenchSection @id="button-group-sizes" @title="Sizes">
      <div class="flex flex-col gap-4">
        {{#each BUTTON_GROUP_SIZES as |size|}}
          <WorkbenchSpecimen @label={{size}}>
            <ButtonGroup
              @size={{size}}
              @variant="outline"
              aria-label="{{size}} group"
              as |g|
            >
              <g.Button>Day</g.Button>
              <g.Button>Week</g.Button>
              <g.Button>Month</g.Button>
            </ButtonGroup>
          </WorkbenchSpecimen>
        {{/each}}
      </div>
    </WorkbenchSection>
  </WorkbenchCard>
</template>
