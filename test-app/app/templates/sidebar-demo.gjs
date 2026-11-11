import pageTitle from 'ember-page-title/helpers/page-title';
import { AppLayout } from 'frontile';

<template>
  {{pageTitle "Sidebar Demo"}}
  <div
    class="relative h-[36rem] transform-gpu overflow-hidden rounded-lg border border-surface-overlay-soft"
  >
    <AppLayout @scrollMode="content" class="h-full" as |layout|>
      <layout.Sidebar @label="Sidebar demo" as |sidebar|>
        <sidebar.Body>
          <sidebar.Item @route="sidebar-demo.index">First</sidebar.Item>
          <sidebar.Item @route="sidebar-demo.second">Second</sidebar.Item>
        </sidebar.Body>
      </layout.Sidebar>
      <layout.Main>{{outlet}}</layout.Main>
    </AppLayout>
  </div>
</template>
