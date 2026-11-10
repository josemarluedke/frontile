import pageTitle from 'ember-page-title/helpers/page-title';
import PlatformShell from 'test-app/components/platform-shell';

<template>
  {{pageTitle "Platform Demo"}}
  <div
    class="relative h-[40rem] transform-gpu overflow-hidden rounded-lg border border-surface-overlay-soft"
  >
    <PlatformShell />
  </div>
</template>
