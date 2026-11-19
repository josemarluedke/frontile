import { LinkTo } from '@ember/routing';
import { InRegion } from 'frontile';

<template>
  <div class="p-4">
    <p data-test-page="orders">Orders</p>
    <LinkTo
      @route="regions-demo.orders.order"
      @model="1"
      data-test-link="order-1"
    >Order 1</LinkTo>
    <LinkTo
      @route="regions-demo.orders.order"
      @model="2"
      data-test-link="order-2"
    >Order 2</LinkTo>
    {{outlet}}
  </div>

  {{! A parent's sources go after the outlet: the first source in the template
       wins, so a child's covers them. }}
  <InRegion @name="actions">
    <button type="button" data-test-action="new-order">New order</button>
  </InRegion>
  <InRegion @name="aside">
    <div data-test-aside="orders">
      <p>Orders summary</p>
      <input aria-label="Filter" data-test-orders-filter />
    </div>
  </InRegion>
</template>
