import { array, hash } from '@ember/helper';
import { SegmentedControl } from 'frontile';
import WorkbenchCard from 'test-app/components/workbench/card';
import WorkbenchSection from 'test-app/components/workbench/section';
import WorkbenchPanes from 'test-app/components/workbench/panes';
import WorkbenchSpecimen from 'test-app/components/workbench/specimen';
import SegmentedControlLive from './segmented-control-live';
import {
  SEGMENTED_CONTROL_COLORS,
  SEGMENTED_CONTROL_SIZES,
  SEGMENTED_CONTROL_VARIANTS
} from 'test-app/utils/workbench/options';

<template>
  <WorkbenchCard
    @id="segmented-control"
    @title="SegmentedControl"
    @description="Mutually exclusive options with a sliding indicator."
    @sections={{array
      (hash id="sizes" label="Sizes")
      (hash id="variants" label="Variants")
      (hash id="live" label="Live")
    }}
  >
    <WorkbenchSection @id="segmented-control-sizes" @title="Sizes">
      <div class="flex flex-wrap items-start gap-6">
        {{#each SEGMENTED_CONTROL_SIZES as |size|}}
          <WorkbenchSpecimen @label={{size}} @measure={{true}}>
            <SegmentedControl
              @size={{size}}
              @defaultValue="week"
              aria-label="{{size}} range"
              as |Ctl|
            >
              <Ctl.Item @value="day">Day</Ctl.Item>
              <Ctl.Item @value="week">Week</Ctl.Item>
              <Ctl.Item @value="month">Month</Ctl.Item>
            </SegmentedControl>
          </WorkbenchSpecimen>
        {{/each}}
      </div>
    </WorkbenchSection>

    <WorkbenchSection
      @id="segmented-control-variants"
      @title="Variants"
      @subtitle="Each color, plus a disabled item"
    >
      <WorkbenchPanes @inverse={{true}}>
        <div class="flex flex-col gap-4">
          {{#each SEGMENTED_CONTROL_VARIANTS as |variant|}}
            {{#each SEGMENTED_CONTROL_COLORS as |color|}}
              <WorkbenchSpecimen @label="{{variant}} / {{color}}">
                <SegmentedControl
                  @variant={{variant}}
                  @color={{color}}
                  @size="sm"
                  @defaultValue="week"
                  aria-label="{{variant}} {{color}} range"
                  as |Ctl|
                >
                  <Ctl.Item @value="day">Day</Ctl.Item>
                  <Ctl.Item @value="week">Week</Ctl.Item>
                  <Ctl.Item @value="month" @isDisabled={{true}}>Month</Ctl.Item>
                </SegmentedControl>
              </WorkbenchSpecimen>
            {{/each}}
          {{/each}}
        </div>
      </WorkbenchPanes>
    </WorkbenchSection>

    <WorkbenchSection
      @id="segmented-control-live"
      @title="Live"
      @subtitle="Controlled; the value is tracked state"
    >
      <SegmentedControlLive />
    </WorkbenchSection>
  </WorkbenchCard>
</template>
