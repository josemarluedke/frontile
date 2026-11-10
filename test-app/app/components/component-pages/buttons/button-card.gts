import { Button } from 'frontile';
import WorkbenchCard from 'test-app/components/workbench/card';
import WorkbenchSection from 'test-app/components/workbench/section';
import WorkbenchPanes from 'test-app/components/workbench/panes';
import WorkbenchSpecimen from 'test-app/components/workbench/specimen';
import WorkbenchStateMatrix from 'test-app/components/workbench/state-matrix';
import {
  BUTTON_COLORS,
  BUTTON_SIZES,
  BUTTON_VARIANTS
} from 'test-app/utils/workbench/options';

const SECTIONS = [
  { id: 'sizes', label: 'Sizes' },
  ...BUTTON_COLORS.map((color) => ({ id: color, label: color }))
];

<template>
  <WorkbenchCard
    @id="button"
    @title="Button"
    @description="Every size, then each color as variants by interaction state. Hover, pressed and focus are frozen, not hovered."
    @sections={{SECTIONS}}
  >
    <WorkbenchSection @id="button-sizes" @title="Sizes">
      <div class="flex flex-wrap items-start gap-6">
        {{#each BUTTON_SIZES as |size|}}
          <WorkbenchSpecimen @label={{size}} @measure={{true}}>
            <Button @size={{size}} @color="primary">Button</Button>
          </WorkbenchSpecimen>
        {{/each}}
      </div>
    </WorkbenchSection>

    {{#each BUTTON_COLORS as |color|}}
      <WorkbenchSection
        @id="button-{{color}}"
        @title={{color}}
        @subtitle="Variants by state"
      >
        {{! A five-column matrix overflows a third of the page, so stack the panes. }}
        <WorkbenchPanes @inverse={{true}} class="lg:grid-cols-1!">
          <WorkbenchStateMatrix
            @rows={{BUTTON_VARIANTS}}
            data-color={{color}}
            as |variant state cell|
          >
            <Button
              @color={{color}}
              @variant={{variant}}
              @size="sm"
              aria-label="{{color}} {{variant}} {{state}}"
              disabled={{cell.isDisabled}}
              {{cell.force}}
            >Button</Button>
          </WorkbenchStateMatrix>
        </WorkbenchPanes>
      </WorkbenchSection>
    {{/each}}
  </WorkbenchCard>
</template>
