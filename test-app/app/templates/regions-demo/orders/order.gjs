import { InRegion } from 'frontile';

<template>
  <InRegion @name="actions">
    <button type="button" data-test-action="refund">Refund order
      {{@model.order_id}}</button>
  </InRegion>
  <InRegion @name="aside">
    <div data-test-aside="order">Order {{@model.order_id}} details</div>
  </InRegion>
  <p data-test-page="order">Order {{@model.order_id}}</p>
</template>
