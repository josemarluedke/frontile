import pageTitle from 'ember-page-title/helpers/page-title';
import { LinkTo } from '@ember/routing';
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
      <li><LinkTo @route="foundations.global" class="text-primary underline">1
          Global</LinkTo>
        &ndash; page-level tokens and surfaces</li>
      <li><LinkTo @route="foundations.palette" class="text-primary underline">2
          Palette</LinkTo>
        &ndash; semantic color categories and levels</li>
      <li><LinkTo @route="foundations.theme" class="text-primary underline">3
          Theme</LinkTo>
        &ndash; theme configuration and overrides</li>
      <li><LinkTo
          @route="foundations.typography"
          class="text-primary underline"
        >4 Typography</LinkTo>
        &ndash; type scale and text styles</li>
      <li><LinkTo
          @route="component-pages.buttons"
          class="text-primary underline"
        >5 Components</LinkTo>
        &ndash; buttons, form controls, status</li>
      <li><LinkTo @route="overlays" class="text-primary underline">6 Live demos</LinkTo>
        &ndash; overlays and notifications</li>
      <li><LinkTo @route="forms-legacy" class="text-primary underline">7 Legacy
          packages</LinkTo>
        &ndash; forms (legacy), changeset form</li>
      <li><LinkTo @route="sidebar-demo" class="text-primary underline">8
          Fixtures</LinkTo>
        &ndash; pages that acceptance tests visit</li>
    </ul>
  </WorkbenchCard>
</template>
