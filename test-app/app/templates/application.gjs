import ThemeSwitcher from '../components/theme-switcher';
import { Button } from 'frontile/buttons';
import Navigation from '../components/navigation';
<template>
  <div class="container p-4 mx-auto">
    <div class="flex flex-wrap items-center justify-between mb-4">
      <h2 class="inline-block text-3xl font-bold text-brand">
        Frontile playground
      </h2>
      <div class="flex">
        <ThemeSwitcher class="mr-4" />
        <Button @isRenderless={{true}} as |btn|>
          <a href="/tests?hidepassed" class={{btn.classNames}}>
            Go to Tests
          </a>
        </Button>
      </div>
    </div>
    <Navigation />
    {{outlet}}
  </div>
</template>
