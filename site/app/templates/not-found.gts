import { LinkTo } from '@ember/routing';
import pageTitle from 'ember-page-title/helpers/page-title';

const NotFound = <template>
  {{pageTitle "404 - Page not found"}}

  <div
    class="flex justify-center items-center h-full w-full absolute inset-x-0 bottom-0"
  >
    <div class="flex flex-col items-center">
      <div class="text-9xl">404</div>
      <div class="text-2xl">PAGE NOT FOUND</div>
      <LinkTo
        @route="docs"
        class="w-full text-center mt-6 bg-brand px-4 py-2 text-white rounded hover:bg-brand-soft"
      >
        Home
      </LinkTo>
    </div>
  </div>
</template>;

export default NotFound;
