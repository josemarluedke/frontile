import { LinkTo } from '@ember/routing';
import { InRegion } from 'frontile';

<template>
  {{! A parent's sources go before the outlet, so a child's stack on top. }}
  <InRegion @name="actions">
    <button type="button" data-test-action="new-order">New order</button>
  </InRegion>
  <InRegion @name="aside">
    <div data-test-aside="orders">
      <p>Orders summary</p>
      <input aria-label="Filter" data-test-orders-filter />
    </div>
  </InRegion>

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
</template>
