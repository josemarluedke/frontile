import DocfyPage from '../components/docfy/docfy-page';

const docs = <template>
  <DocfyPage @scope="docs">
    {{outlet}}
  </DocfyPage>
</template>;

export default docs;
