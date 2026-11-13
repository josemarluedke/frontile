import { array, hash } from '@ember/helper';
import { Chip } from 'frontile';
import WorkbenchCard from 'test-app/components/workbench/card';
import WorkbenchSection from 'test-app/components/workbench/section';
import WorkbenchPanes from 'test-app/components/workbench/panes';
import WorkbenchSpecimen from 'test-app/components/workbench/specimen';
import {
  CHIP_COLORS,
  CHIP_SIZES,
  CHIP_VARIANTS
} from 'test-app/utils/workbench/options';

/** Shows the close button without doing anything. */
function noop(): void {}

<template>
  <WorkbenchCard
    @id="chip"
    @title="Chip"
    @description="A compact label. Sizes, every color in each variant, and the closable form."
    @sections={{array
      (hash id="sizes" label="Sizes")
      (hash id="colors" label="Colors")
      (hash id="closable" label="Closable")
    }}
  >
    <WorkbenchSection @id="chip-sizes" @title="Sizes">
      <div class="flex flex-wrap items-start gap-6">
        {{#each CHIP_SIZES as |size|}}
          <WorkbenchSpecimen @label={{size}} @measure={{true}}>
            <Chip @size={{size}} @color="primary">Chip</Chip>
          </WorkbenchSpecimen>
        {{/each}}
      </div>
    </WorkbenchSection>

    <WorkbenchSection @id="chip-colors" @title="Colors" @subtitle="Variants">
      <WorkbenchPanes @inverse={{true}}>
        <div class="flex flex-col gap-4">
          {{#each CHIP_VARIANTS as |variant|}}
            <WorkbenchSpecimen @label={{variant}}>
              <div class="flex flex-wrap gap-2">
                {{#each CHIP_COLORS as |color|}}
                  <Chip @variant={{variant}} @color={{color}}>{{color}}</Chip>
                {{/each}}
              </div>
            </WorkbenchSpecimen>
          {{/each}}
          <WorkbenchSpecimen @label="with dot">
            <div class="flex flex-wrap gap-2">
              {{#each CHIP_COLORS as |color|}}
                <Chip
                  @variant="soft"
                  @color={{color}}
                  @withDot={{true}}
                >{{color}}</Chip>
              {{/each}}
            </div>
          </WorkbenchSpecimen>
        </div>
      </WorkbenchPanes>
    </WorkbenchSection>

    <WorkbenchSection @id="chip-closable" @title="Closable">
      <WorkbenchPanes @inverse={{true}}>
        <div class="flex flex-col gap-4">
          {{#each CHIP_VARIANTS as |variant|}}
            <WorkbenchSpecimen @label={{variant}}>
              <div class="flex flex-wrap gap-2">
                <Chip
                  @variant={{variant}}
                  @color="primary"
                  @onClose={{noop}}
                  @closeButtonTitle="Remove {{variant}} chip"
                >Closable</Chip>
                <Chip
                  @variant={{variant}}
                  @color="primary"
                  @onClose={{noop}}
                  @isDisabled={{true}}
                  @closeButtonTitle="Remove disabled {{variant}} chip"
                >Disabled</Chip>
              </div>
            </WorkbenchSpecimen>
          {{/each}}
        </div>
      </WorkbenchPanes>
    </WorkbenchSection>
  </WorkbenchCard>
</template>
