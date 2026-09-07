import pageTitle from 'ember-page-title/helpers/page-title';
import { TabNav } from 'frontile';

<template>
  {{pageTitle "TabNav Demo"}}
  <TabNav @label="Sections" as |nav|>
    <nav.Item @route="tab-nav-demo.index">First</nav.Item>
    <nav.Item @route="tab-nav-demo.second">Second</nav.Item>
  </TabNav>
  {{outlet}}
</template>
