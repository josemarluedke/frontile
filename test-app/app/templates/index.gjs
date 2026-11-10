import pageTitle from 'ember-page-title/helpers/page-title';
import { array } from '@ember/helper';
import WorkbenchCard from '../components/workbench/card';

<template>
  {{pageTitle "Frontile Workbench"}}
  <h1 class="sr-only">Frontile workbench</h1>
  <WorkbenchCard
    @id="home"
    @title="Frontile workbench"
    @description="A working surface for checking every component, color and theme state in light, dark and inverse. Pages are numbered in the sidebar; each card has a Copy link button for deep links."
    @sections={{array}}
  >
    <ul class="grid gap-2 text-sm sm:grid-cols-2" data-home-links>
      <li><a class="text-primary underline" href="/foundations/global">1 Global</a>
        &ndash; page-level tokens and surfaces</li>
      <li><a class="text-primary underline" href="/foundations/palette">2
          Palette</a>
        &ndash; semantic color categories and levels</li>
      <li><a class="text-primary underline" href="/foundations/theme">3 Theme</a>
        &ndash; theme configuration and overrides</li>
      <li><a class="text-primary underline" href="/foundations/typography">4
          Typography</a>
        &ndash; type scale and text styles</li>
      <li><a class="text-primary underline" href="/components/buttons">5
          Components</a>
        &ndash; buttons, form controls, status</li>
      <li><a class="text-primary underline" href="/overlays">6 Live demos</a>
        &ndash; overlays and notifications</li>
      <li><a class="text-primary underline" href="/forms-legacy">7 Legacy
          packages</a>
        &ndash; forms (legacy), changeset form</li>
      <li><a class="text-primary underline" href="/sidebar-demo">8 Fixtures</a>
        &ndash; pages that acceptance tests visit</li>
    </ul>
  </WorkbenchCard>
</template>
