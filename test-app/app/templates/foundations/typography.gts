import pageTitle from 'ember-page-title/helpers/page-title';
import TypographyCards from 'test-app/components/foundations/typography-cards';

<template>
  {{pageTitle "Typography"}}
  <h1 class="text-neutral-bolder mb-6 text-2xl font-semibold">Typography</h1>

  <div class="flex flex-col gap-8">
    <TypographyCards />
  </div>
</template>
