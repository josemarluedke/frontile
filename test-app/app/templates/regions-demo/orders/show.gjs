import { concat } from '@ember/helper';
import { breadcrumb, LayoutRegion, LayoutAside } from 'frontile';

<template>
  {{breadcrumb (concat "Order " @model.order_id)}}
  <LayoutRegion @name="actions">
    <button type="button" data-test-action="refund">Refund</button>
  </LayoutRegion>
  <LayoutAside>
    <p data-test-aside="order">Order {{@model.order_id}} details</p>
  </LayoutAside>
  <p data-test-page="order">Order {{@model.order_id}}</p>
</template>
