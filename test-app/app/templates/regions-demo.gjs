// PROTOTYPE: layout regions. A throwaway demo for the regions tests.
import { LinkTo } from '@ember/routing';
import { AppLayout } from 'frontile';

<template>
  <div
    class="relative h-[36rem] transform-gpu overflow-hidden rounded-lg border border-surface-overlay-soft"
  >
    <AppLayout @scrollMode="content" class="h-full" as |layout|>
      <layout.Navbar>
        <span data-test-brand>Regions demo</span>
        <span class="ms-auto flex items-center gap-2" data-test-actions>
          <layout.Region @name="actions">
            <span data-test-fallback-actions>No actions</span>
          </layout.Region>
          <layout.AsideToggle />
        </span>
      </layout.Navbar>
      <layout.Main>
        <nav class="flex gap-3 p-4">
          <LinkTo
            @route="regions-demo.index"
            data-test-link="home"
          >Home</LinkTo>
          <LinkTo
            @route="regions-demo.orders"
            data-test-link="orders"
          >Orders</LinkTo>
        </nav>
        {{outlet}}
      </layout.Main>
      <layout.Aside @label="Details" />
    </AppLayout>
  </div>
</template>
