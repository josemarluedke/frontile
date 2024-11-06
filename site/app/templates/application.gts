import { LinkTo } from '@ember/routing';
import RouteTemplate from 'ember-route-template';
import Logo from '../components/logo';
import pageTitle from 'ember-page-title/helpers/page-title';
import DocfyHeader from '../components/docfy/docfy-header';
import DocfyJumpTo from '../components/docfy/docfy-jump-to';
import { VisuallyHidden } from '@frontile/utilities';
import { PortalTarget } from '@frontile/overlays';

const application = <template>
  {{pageTitle "Frontile"}}
  <DocfyHeader
    @githubUrl="https://github.com/josemarluedke/frontile"
    class="overflow-x-scroll sm:overflow-x-auto"
  >
    <:title>
      <VisuallyHidden>Frontile</VisuallyHidden>
      <Logo class="h-7" />
    </:title>
    <:left>
      <DocfyJumpTo />
    </:left>

    <:right as |linkClass linkClassActive|>
      <LinkTo
        @route="docs"
        class="{{linkClass}} hidden sm:block"
        @activeClass={{linkClassActive}}
      >
        Docs
      </LinkTo>
    </:right>
  </DocfyHeader>

  {{outlet}}

  <div
    class="mb-20 sm:mb-0 border-t border-gray-300 dark:border-gray-700 p-4 text-center text-sm text-gray-700 dark:text-gray-300"
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
</template>;

export default RouteTemplate(application);
