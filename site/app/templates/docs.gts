import { service } from '@ember/service';
import Component from '@glimmer/component';
import DocfyPage from '../components/docfy/docfy-page';

class Docs extends Component {
  @service declare router: any;

  get scope() {
    const url = this.router.currentURL;
    const segments = url.split('/').filter(Boolean);
    // Get first two segments: e.g., "docs/theming" from "docs/theming/colors"
    return segments.slice(0, 2).join('/');
  }

  <template>
    <DocfyPage @scope={{this.scope}} @showSectionNav={{true}}>
      {{outlet}}
    </DocfyPage>
  </template>
}

export default Docs;
