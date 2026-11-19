import { InLayoutRegion } from 'frontile';

// The sources come before the outlet, so a child route's sources render
// later and are the ones shown.
<template>
  <InLayoutRegion @name="actions">
    <button type="button" data-test-action="new-order">New order</button>
  </InLayoutRegion>
  <InLayoutRegion @name="aside">
    <p data-test-aside="orders">Orders filters</p>
  </InLayoutRegion>
  {{outlet}}
</template>
