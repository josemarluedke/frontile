import pageTitle from 'ember-page-title/helpers/page-title';
import { concat } from '@ember/helper';
<template>
  {{pageTitle "Frontile Home"}}
  <div
    class="grid grid-flow-col justify-center gap-4 font-mono font-bold text-xs text-center"
  >
    <div
      class="items-center justify-center text-content1-foreground bg-content1 rounded-lg shadow-lg size-40 hidden md:grid"
    >bg-content1</div>
    <div
      class="items-center justify-center text-content2-foreground bg-content2 rounded-lg shadow-lg size-40 hidden md:grid"
    >bg-content2</div>
    <div
      class="items-center justify-center text-content3-foreground bg-content3 rounded-lg shadow-lg size-40 hidden md:grid"
    >bg-content3</div>
    <div
      class="items-center justify-center text-content4-foreground bg-content4 rounded-lg shadow-lg size-40 hidden md:grid"
    >bg-content4</div>
  </div>

  <div
    class="grid grid-cols-[repeat(auto-fit,minmax(8rem,1fr))] gap-x-2 gap-y-8 sm:grid-cols-1 mt-8"
  >
    {{#each @controller.model.groups as |group|}}
      <div>
        <div
          class="text-sm font-semibold text-foreground dark:text-slate-200 2xl:col-end-1 2xl:pt-2.5"
        >
          {{group.name}}
        </div>
        <div
          class="grid mt-3 grid-cols-1 sm:grid-cols-11 gap-y-3 gap-x-2 sm:mt-2 2xl:mt-0"
        >
          {{#each-in group.colors as |key color|}}
            <div
              class="flex items-center gap-x-3 w-full sm:block sm:space-y-1.5"
            >
              <div
                class="h-10 w-10 rounded dark:ring-1 dark:ring-inset dark:ring-white/10 sm:w-full"
                style={{@controller.model.htmlSafe
                  (concat "background-color:" color)
                }}
              >
              </div>
              <div class="px-0.5">
                <div class="w-6 font-medium text-xs 2xl:w-full dark:text-white">
                  {{key}}
                </div>
                <div
                  class="text-slate-500 text-xs font-mono lowercase dark:text-slate-400 sm:text-[0.625rem] md:text-xs lg:text-[0.625rem] 2xl:text-xs"
                >
                  {{color}}
                </div>
              </div>
            </div>
          {{/each-in}}
        </div>
      </div>
    {{/each}}
  </div>
</template>
