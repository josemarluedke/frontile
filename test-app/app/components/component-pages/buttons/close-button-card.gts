import { array, hash } from '@ember/helper';
import { CloseButton } from 'frontile';
import WorkbenchCard from 'test-app/components/workbench/card';
import WorkbenchSection from 'test-app/components/workbench/section';
import WorkbenchPanes from 'test-app/components/workbench/panes';
import WorkbenchSpecimen from 'test-app/components/workbench/specimen';
import WorkbenchStateMatrix from 'test-app/components/workbench/state-matrix';
import {
  CLOSE_BUTTON_SIZES,
  CLOSE_BUTTON_VARIANTS
} from 'test-app/utils/workbench/options';

<template>
  <WorkbenchCard
    @id="close-button"
    @title="CloseButton"
    @description="The dismiss control used by Chip, Modal and Drawer."
    @sections={{array
      (hash id="sizes" label="Sizes")
      (hash id="states" label="States")
    }}
  >
    <WorkbenchSection @id="close-button-sizes" @title="Sizes">
      <div class="flex flex-wrap items-start gap-6">
        {{#each CLOSE_BUTTON_SIZES as |size|}}
          <WorkbenchSpecimen @label={{size}} @measure={{true}}>
            <CloseButton @size={{size}} @title="Close {{size}}" />
          </WorkbenchSpecimen>
        {{/each}}
      </div>
    </WorkbenchSection>

    <WorkbenchSection
      @id="close-button-states"
      @title="States"
      @subtitle="Variants by state"
    >
      <WorkbenchPanes @inverse={{true}} @stacked={{true}}>
        <WorkbenchStateMatrix
          @rows={{CLOSE_BUTTON_VARIANTS}}
          as |variant state cell|
        >
          <CloseButton
            @variant={{variant}}
            @size="sm"
            @title="Close {{variant}} {{state}}"
            disabled={{cell.isDisabled}}
            {{cell.force}}
          />
        </WorkbenchStateMatrix>
      </WorkbenchPanes>
    </WorkbenchSection>
  </WorkbenchCard>
</template>
