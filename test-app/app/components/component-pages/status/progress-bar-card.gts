import { array, hash } from '@ember/helper';
import { ProgressBar } from 'frontile';
import WorkbenchCard from 'test-app/components/workbench/card';
import WorkbenchSection from 'test-app/components/workbench/section';
import WorkbenchPanes from 'test-app/components/workbench/panes';
import WorkbenchSpecimen from 'test-app/components/workbench/specimen';
import {
  PROGRESS_BAR_COLORS,
  PROGRESS_BAR_RADII,
  PROGRESS_BAR_SIZES,
  PROGRESS_BAR_VALUES
} from 'test-app/utils/workbench/options';

<template>
  <WorkbenchCard
    @id="progress-bar"
    @title="ProgressBar"
    @description="A determinate or indeterminate bar. Sizes and colors, each at 0, 50 and 100."
    @sections={{array
      (hash id="sizes" label="Sizes")
      (hash id="colors" label="Colors")
      (hash id="radius" label="Radius")
      (hash id="labels" label="Labels")
      (hash id="indeterminate" label="Indeterminate")
    }}
  >
    <WorkbenchSection
      @id="progress-bar-sizes"
      @title="Sizes"
      @subtitle="Primary, at 0, 50 and 100"
    >
      <p class="text-neutral mb-3 text-sm">
        At 0 the fill has no width, so every size shows only the empty track.
        Only the height differs.
      </p>
      <div class="flex flex-col gap-5">
        {{#each PROGRESS_BAR_SIZES as |size|}}
          <div data-bar-size={{size}}>
            <WorkbenchSpecimen @label={{size}}>
              <div class="flex flex-col gap-2">
                {{#each PROGRESS_BAR_VALUES as |value|}}
                  <ProgressBar
                    @size={{size}}
                    @color="primary"
                    @progress={{value}}
                  />
                {{/each}}
              </div>
            </WorkbenchSpecimen>
          </div>
        {{/each}}
      </div>
    </WorkbenchSection>

    <WorkbenchSection
      @id="progress-bar-colors"
      @title="Colors"
      @subtitle="Each color at 0, 50 and 100"
    >
      <p class="text-neutral mb-3 text-sm">
        At 0 every color renders the same empty track. The fill color shows at
        50 and 100.
      </p>
      <WorkbenchPanes @inverse={{true}}>
        <div class="flex flex-col gap-4">
          {{#each PROGRESS_BAR_COLORS as |color|}}
            <div data-bar-color={{color}}>
              <WorkbenchSpecimen @label={{color}}>
                <div class="flex flex-col gap-2">
                  {{#each PROGRESS_BAR_VALUES as |value|}}
                    <ProgressBar @color={{color}} @progress={{value}} />
                  {{/each}}
                </div>
              </WorkbenchSpecimen>
            </div>
          {{/each}}
        </div>
      </WorkbenchPanes>
    </WorkbenchSection>

    <WorkbenchSection
      @id="progress-bar-radius"
      @title="Radius"
      @subtitle="At 50"
    >
      <div class="flex flex-col gap-4">
        {{#each PROGRESS_BAR_RADII as |radius|}}
          <WorkbenchSpecimen @label={{radius}}>
            <ProgressBar
              @radius={{radius}}
              @color="primary"
              @progress={{50}}
              @size="lg"
            />
          </WorkbenchSpecimen>
        {{/each}}
      </div>
    </WorkbenchSection>

    <WorkbenchSection
      @id="progress-bar-labels"
      @title="Labels"
      @subtitle="Label, value label, description"
    >
      <div class="flex flex-col gap-4">
        <WorkbenchSpecimen @label="label (value label follows)">
          <ProgressBar @label="Uploading" @color="primary" @progress={{50}} />
        </WorkbenchSpecimen>
        <WorkbenchSpecimen @label="custom value label">
          <ProgressBar
            @label="Step"
            @valueLabel="2 of 4"
            @color="primary"
            @progress={{50}}
          />
        </WorkbenchSpecimen>
        <WorkbenchSpecimen @label="value label hidden">
          <ProgressBar
            @label="Quiet"
            @showValueLabel={{false}}
            @color="primary"
            @progress={{50}}
          />
        </WorkbenchSpecimen>
        <WorkbenchSpecimen @label="description">
          <ProgressBar
            @label="Syncing"
            @description="Copying 12 of 24 files"
            @color="primary"
            @progress={{50}}
          />
        </WorkbenchSpecimen>
      </div>
    </WorkbenchSection>

    <WorkbenchSection
      @id="progress-bar-indeterminate"
      @title="Indeterminate"
      @subtitle="Progress unknown"
    >
      <p class="text-neutral mb-3 text-sm">
        @progress is ignored here: the fill is always half the track and
        animates, and aria-valuenow is omitted. The value label is hidden.
      </p>
      <div class="flex flex-col gap-4">
        {{#each PROGRESS_BAR_COLORS as |color|}}
          <WorkbenchSpecimen @label={{color}}>
            <ProgressBar @color={{color}} @isIndeterminate={{true}} />
          </WorkbenchSpecimen>
        {{/each}}
      </div>
    </WorkbenchSection>
  </WorkbenchCard>
</template>
