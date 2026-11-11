import pageTitle from 'ember-page-title/helpers/page-title';
import AlertCard from 'test-app/components/component-pages/status/alert-card';
import ProgressBarCard from 'test-app/components/component-pages/status/progress-bar-card';

<template>
  {{pageTitle "Status"}}
  <h1 class="text-neutral-bolder mb-6 text-2xl font-semibold">Status</h1>

  <div class="flex flex-col gap-8">
    <AlertCard />
    <ProgressBarCard />
  </div>
</template>
