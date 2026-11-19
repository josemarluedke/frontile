import { InRegion } from 'frontile';

<template>
  <InRegion @name="aside">
    <div data-test-aside="customers">Customers summary</div>
  </InRegion>
  <p class="p-4" data-test-page="customers">Customers</p>
</template>
