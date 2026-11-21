import { LinkTo } from '@ember/routing';

<template>
  <p data-test-page="orders">All orders</p>
  <LinkTo @route="regions-demo.orders.show" @model="1">Order 1</LinkTo>
</template>
