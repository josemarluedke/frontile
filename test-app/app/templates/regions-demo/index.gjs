import { LinkTo } from '@ember/routing';

<template>
  <p data-test-page="home">Regions home: nothing fills the navbar or aside.</p>
  <LinkTo @route="regions-demo.orders">Orders</LinkTo>
</template>
