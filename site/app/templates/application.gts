import Logo from '../components/logo';
import pageTitle from 'ember-page-title/helpers/page-title';
import DocfyHeader from '../components/docfy/docfy-header';
import DocfyJumpTo from '../components/docfy/docfy-jump-to';
import VersionDropdown from '../components/version-dropdown';
import { VisuallyHidden } from 'frontile';
import { PortalTarget } from 'frontile';
import { DocfyLink } from '@docfy/ember';

<template>
  {{pageTitle "Frontile"}}
  <DocfyHeader
    @githubUrl="https://github.com/josemarluedke/frontile"
    class="overflow-x-scroll sm:overflow-x-auto"
  >
    <:title>
      <VisuallyHidden>Frontile</VisuallyHidden>
      <Logo class="h-7" @color="#076873" />
    </:title>
    <:left>
      <DocfyJumpTo />
    </:left>

    <:right as |linkClass linkClassActive|>
      <DocfyLink
        @to="/docs/get-started"
        class="{{linkClass}} hidden sm:block"
        @activeClass={{linkClassActive}}
      >
        Docs
      </DocfyLink>

      <VersionDropdown class="hidden sm:block" />
    </:right>
  </DocfyHeader>

  {{outlet}}

  <div
    class="mb-20 sm:mb-0 border-t border-gray-300 dark:border-gray-700 p-4 text-center font-body text-body-2xs text-gray-700 dark:text-gray-300"
  >
    Released under MIT License - Created by
    <a
      href="https://github.com/josemarluedke"
      target="_blank"
      rel="noopener noreferrer"
      class="whitespace-nowrap"
    >
      Josemar Luedke
    </a>
  </div>
  <PortalTarget class="relative z-20" />

  {{! The deprecated forms-legacy components are built on ember-power-select,
      which renders its dropdown into this element. Without it, BasicDropdown
      has no destination and the dropdown never renders — see issue #330. }}
  <div id="ember-basic-dropdown-wormhole"></div>
</template>
