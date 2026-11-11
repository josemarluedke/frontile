import pageTitle from 'ember-page-title/helpers/page-title';
import GlobalCards from 'test-app/components/foundations/global-cards';

<template>
  {{pageTitle "Global"}}
  <h1 class="text-neutral-bolder mb-6 text-2xl font-semibold">Global</h1>

  <div class="flex flex-col gap-8">
    <GlobalCards />
  </div>
</template>
