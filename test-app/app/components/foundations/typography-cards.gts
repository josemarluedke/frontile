import { array, concat, hash } from '@ember/helper';
import { htmlSafe, type SafeString } from '@ember/template';
import WorkbenchCard from 'test-app/components/workbench/card';
import WorkbenchSection from 'test-app/components/workbench/section';
import WorkbenchSpecimen from 'test-app/components/workbench/specimen';
import TokenValue from './token-value';

/*
 * Tailwind generates only literal class names, so every type class is written
 * out in full below. Do not build `text-{role}-{size}` from parts.
 */

const DESC = {
  marquee: 'Display serif for hero and page titles.',
  header: 'Section and card headings.',
  strong: 'Emphasised UI text at heading sizes.',
  body: 'Running text and descriptions.',
  label: 'Form labels and compact UI text.',
  code: 'Monospace for code and values.',
  caption: 'Small supporting text.'
};

const SAMPLE = 'The quick brown fox jumps over the lazy dog';

const ROLES = [
  {
    id: 'marquee',
    title: 'Marquee',
    description: DESC.marquee,
    font: 'font-marquee',
    sizes: [
      { size: '5xs', class: 'text-marquee-5xs' },
      { size: '4xs', class: 'text-marquee-4xs' },
      { size: '3xs', class: 'text-marquee-3xs' },
      { size: '2xs', class: 'text-marquee-2xs' },
      { size: 'xs', class: 'text-marquee-xs' },
      { size: 'sm', class: 'text-marquee-sm' },
      { size: 'md', class: 'text-marquee-md' },
      { size: 'lg', class: 'text-marquee-lg' },
      { size: 'xl', class: 'text-marquee-xl' },
      { size: '2xl', class: 'text-marquee-2xl' },
      { size: '3xl', class: 'text-marquee-3xl' }
    ]
  },
  {
    id: 'header',
    title: 'Header',
    description: DESC.header,
    font: 'font-header',
    sizes: [
      { size: '4xs', class: 'text-header-4xs' },
      { size: '3xs', class: 'text-header-3xs' },
      { size: '2xs', class: 'text-header-2xs' },
      { size: 'xs', class: 'text-header-xs' },
      { size: 'sm', class: 'text-header-sm' },
      { size: 'md', class: 'text-header-md' },
      { size: 'lg', class: 'text-header-lg' },
      { size: 'xl', class: 'text-header-xl' },
      { size: '2xl', class: 'text-header-2xl' },
      { size: '3xl', class: 'text-header-3xl' }
    ]
  },
  {
    id: 'strong',
    title: 'Strong',
    description: DESC.strong,
    font: 'font-header',
    sizes: [
      { size: '4xs', class: 'text-strong-4xs' },
      { size: '3xs', class: 'text-strong-3xs' },
      { size: '2xs', class: 'text-strong-2xs' },
      { size: 'xs', class: 'text-strong-xs' },
      { size: 'sm', class: 'text-strong-sm' },
      { size: 'md', class: 'text-strong-md' },
      { size: 'lg', class: 'text-strong-lg' },
      { size: 'xl', class: 'text-strong-xl' },
      { size: '2xl', class: 'text-strong-2xl' },
      { size: '3xl', class: 'text-strong-3xl' }
    ]
  },
  {
    id: 'body',
    title: 'Body',
    description: DESC.body,
    font: 'font-body',
    sizes: [
      { size: '5xs', class: 'text-body-5xs' },
      { size: '4xs', class: 'text-body-4xs' },
      { size: '3xs', class: 'text-body-3xs' },
      { size: '2xs', class: 'text-body-2xs' },
      { size: 'xs', class: 'text-body-xs' },
      { size: 'sm', class: 'text-body-sm' },
      { size: 'md', class: 'text-body-md' },
      { size: 'lg', class: 'text-body-lg' },
      { size: 'xl', class: 'text-body-xl' },
      { size: '2xl', class: 'text-body-2xl' },
      { size: '3xl', class: 'text-body-3xl' }
    ]
  },
  {
    id: 'label',
    title: 'Label',
    description: DESC.label,
    font: 'font-label',
    sizes: [
      { size: 'nano', class: 'text-label-nano' },
      { size: 'micro', class: 'text-label-micro' },
      { size: '2xs', class: 'text-label-2xs' },
      { size: 'xs', class: 'text-label-xs' },
      { size: 'sm', class: 'text-label-sm' },
      { size: 'md', class: 'text-label-md' },
      { size: 'lg', class: 'text-label-lg' },
      { size: 'xl', class: 'text-label-xl' },
      { size: '2xl', class: 'text-label-2xl' },
      { size: '3xl', class: 'text-label-3xl' }
    ]
  },
  {
    id: 'code',
    title: 'Code',
    description: DESC.code,
    font: 'font-code',
    sizes: [
      { size: 'sm', class: 'text-code-sm' },
      { size: 'md', class: 'text-code-md' }
    ]
  },
  {
    id: 'caption',
    title: 'Caption',
    description: DESC.caption,
    font: 'font-caption',
    sizes: [
      { size: 'sm', class: 'text-caption-sm' },
      { size: 'md', class: 'text-caption-md' }
    ]
  }
];

const STEPS = Array.from({ length: 35 }, (_, i) => ({
  index: i,
  token: `--font-size-${i}`
}));

/** Style values come from the constant token list above, never user input. */
function style(css: string): SafeString {
  return htmlSafe(css);
}

<template>
  {{#each ROLES as |role|}}
    <WorkbenchCard
      @id="type-{{role.id}}"
      @title={{role.title}}
      @description={{role.description}}
      @sections={{array (hash id="sizes" label="Sizes")}}
    >
      <WorkbenchSection @id="type-{{role.id}}-sizes" @title="Sizes">
        <div class="flex flex-col gap-4">
          {{#each role.sizes as |s|}}
            <WorkbenchSpecimen
              @label="{{role.id}}-{{s.size}}"
              @measure={{true}}
            >
              <p
                class="{{role.font}} {{s.class}} text-neutral-strong"
              >{{SAMPLE}}</p>
            </WorkbenchSpecimen>
          {{/each}}
        </div>
      </WorkbenchSection>
    </WorkbenchCard>
  {{/each}}

  <WorkbenchCard
    @id="type-scale"
    @title="Scale"
    @description="Every role sits on one modular scale. Steps multiply or divide by the ratio around a 1rem base at step 12."
    @sections={{array
      (hash id="ratio" label="Ratio")
      (hash id="steps" label="Steps")
    }}
  >
    <WorkbenchSection @id="type-scale-ratio" @title="Ratio">
      <div class="flex items-center gap-3">
        <span class="text-sm font-medium">--typescale-ratio</span>
        <TokenValue @name="--typescale-ratio" />
      </div>
    </WorkbenchSection>
    <WorkbenchSection @id="type-scale-steps" @title="Steps">
      <div class="flex flex-col gap-2">
        {{#each STEPS as |step|}}
          <div
            data-scale-step={{step.index}}
            data-token-item
            class="flex items-baseline gap-4"
          >
            <span
              class="w-24 shrink-0 text-xs font-medium"
            >{{step.token}}</span>
            <TokenValue
              @name={{step.token}}
              @property="font-size"
              class="w-16 shrink-0"
            />
            {{! template-lint-disable no-inline-styles }}
            <span class="text-neutral-strong truncate">
              <span
                data-token-shape
                style={{style (concat "font-size: var(" step.token ")")}}
              >Aa</span>
            </span>
          </div>
        {{/each}}
      </div>
    </WorkbenchSection>
  </WorkbenchCard>
</template>
