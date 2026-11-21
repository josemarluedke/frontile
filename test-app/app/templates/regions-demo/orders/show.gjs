import { InLayoutRegion } from 'frontile';

<template>
  <InLayoutRegion @name="actions">
    <button type="button" data-test-action="refund">Refund</button>
  </InLayoutRegion>
  <InLayoutRegion @name="aside">
    <p data-test-aside="order">Order {{@model.order_id}} details</p>
  </InLayoutRegion>
  <p data-test-page="order">Order {{@model.order_id}}</p>
</template>
