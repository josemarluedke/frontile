import { breadcrumb, LayoutRegion, LayoutAside } from 'frontile';

<template>
  {{breadcrumb "Orders" route="regions-demo.orders"}}
  <LayoutRegion @name="actions">
    <button type="button" data-test-action="new-order">New order</button>
  </LayoutRegion>
  <LayoutAside>
    <p data-test-aside="orders">Orders filters</p>
  </LayoutAside>
  {{outlet}}
</template>
