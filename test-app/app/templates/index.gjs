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
    @description="A working surface for checking every component, color and theme state in light, dark and inverse. Each card has a Copy link button for deep links."
    @sections={{array}}
  >
    <div class="grid gap-6 text-sm sm:grid-cols-2" data-home-links>
      <section data-home-section="foundations">
        <h3 class="mb-2 font-semibold">Foundations</h3>
        <ul class="grid gap-2">
          <li><LinkTo
              @route="foundations.theme"
              class="text-primary underline"
            >Theme</LinkTo>
            &ndash; the semantic roles at each level, surfaces, overlays &amp;
            lifts, utility colors</li>
          <li><LinkTo
              @route="foundations.palette"
              class="text-primary underline"
            >Palette</LinkTo>
            &ndash; the raw color ramps from the theme source, theme-independent</li>
          <li><LinkTo
              @route="foundations.typography"
              class="text-primary underline"
            >Typography</LinkTo>
            &ndash; type scale and text styles</li>
          <li><LinkTo
              @route="foundations.global"
              class="text-primary underline"
            >Global</LinkTo>
            &ndash; radius, elevation, icon sizes, disabled opacity, breakpoints</li>
        </ul>
      </section>
      <section data-home-section="components">
        <h3 class="mb-2 font-semibold">Components</h3>
        <ul class="grid gap-2">
          <li><LinkTo
              @route="component-pages.buttons"
              class="text-primary underline"
            >Buttons</LinkTo>
            &ndash; buttons, groups, toggles, chips, close buttons, segmented
            control</li>
          <li><LinkTo
              @route="component-pages.form-controls"
              class="text-primary underline"
            >Form controls</LinkTo>
            &ndash; inputs, selects, textareas, checkboxes, radios, switches</li>
          <li><LinkTo
              @route="component-pages.status"
              class="text-primary underline"
            >Status</LinkTo>
            &ndash; alerts and progress bars</li>
        </ul>
      </section>
      <section data-home-section="demos">
        <h3 class="mb-2 font-semibold">Demos</h3>
        <ul class="grid gap-2">
          <li><LinkTo
              @route="overlays"
              class="text-primary underline"
            >Overlays</LinkTo>
            &ndash; modals, drawers, popovers</li>
          <li><LinkTo
              @route="notifications"
              class="text-primary underline"
            >Notifications</LinkTo>
            &ndash; live notification stack and placements</li>
        </ul>
      </section>
      <section data-home-section="fixtures">
        <h3 class="mb-2 font-semibold">Fixtures</h3>
        <p class="mb-2 text-neutral-firm">Pages that acceptance tests visit.</p>
        <ul class="grid gap-2">
          <li><LinkTo
              @route="sidebar-demo"
              class="text-primary underline"
            >Sidebar</LinkTo></li>
          <li><LinkTo
              @route="platform-demo"
              class="text-primary underline"
            >Platform shell</LinkTo></li>
          <li><LinkTo
              @route="breadcrumbs-demo"
              class="text-primary underline"
            >Breadcrumbs</LinkTo></li>
          <li><LinkTo @route="tab-nav-demo" class="text-primary underline">Tab
              nav</LinkTo></li>
        </ul>
      </section>
    </div>
  </WorkbenchCard>
</template>
