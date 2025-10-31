import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { Button, CloseButton } from 'frontile';
import {
  Avatar,
  Collapsible,
  Divider,
  Spinner,
  VisuallyHidden
} from 'frontile';
import type { TOC } from '@ember/component/template-only';

class CollapsibleDemo extends Component {
  @tracked isOpen = false;

  toggle = () => {
    this.isOpen = !this.isOpen;
  };

  <template>
    <div class="max-w-md">
      <Button @type="button" {{on "click" this.toggle}}>
        Collapse
      </Button>

      <Collapsible @isOpen={{this.isOpen}}>
        <div class="p-8 mt-4 text-white bg-primary-800 rounded">
          Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse
          malesuada lacus ex, sit amet blandit leo lobortis eget. Lorem ipsum
          dolor sit amet, consectetur adipiscing elit. Suspendisse malesuada
          lacus ex, sit amet blandit leo lobortis eget.
        </div>
      </Collapsible>
      <button type="button" class="mt-4">
        Hey
      </button>
    </div>
  </template>
}

const Title: TOC<{
  Element: HTMLHeadingElement;
  Blocks: {
    default: [];
  };
}> = <template>
  <h1
    class="inline-block mb-6 text-2xl font-bold border-b-4 border-primary"
    ...attributes
  >
    {{yield}}
  </h1>
</template>;

export default class UtilitiesDemo extends Component {
  <template>
    <div class="container p-4 mx-auto">

      <div class="mt-4">
        <VisuallyHidden>This should not be shown</VisuallyHidden>

        <Title>Avatar</Title>
        <div class="flex items-center space-x-4 py-2">
          <Avatar @size="xs" @name="Josemar Luedke" />
          <Avatar @size="sm" @name="Josemar Luedke" />
          <Avatar @size="md" @name="Josemar Luedke" />
          <Avatar @size="lg" @name="Josemar Luedke" />
          <Avatar @size="xl" @firstName="Josemar" @lastName="Luedke" />
        </div>

        <div class="flex items-center space-x-4 py-2">
          <Avatar @size="xs" @src="https://i.pravatar.cc/150?img=1" />
          <Avatar @size="sm" @src="https://i.pravatar.cc/150?img=2" />
          <Avatar @size="md" @src="https://i.pravatar.cc/150?img=3" />
          <Avatar @size="lg" @src="https://i.pravatar.cc/150?img=4" />
          <Avatar @size="xl" @src="https://i.pravatar.cc/150?img=5" />
        </div>

        <div class="flex items-center space-x-4 py-2">
          <Avatar
            @size="xs"
            @src="https://i.pravatar.cc/150?img=1"
            @shape="square"
          />
          <Avatar
            @size="sm"
            @src="https://i.pravatar.cc/150?img=2"
            @shape="square"
          />
          <Avatar
            @size="md"
            @src="https://i.pravatar.cc/150?img=3"
            @shape="square"
          />
          <Avatar
            @size="lg"
            @src="https://i.pravatar.cc/150?img=4"
            @shape="square"
          />
          <Avatar
            @size="xl"
            @src="https://i.pravatar.cc/150?img=5"
            @shape="square"
          />
        </div>

        <Divider />

        <Title>CloseButton</Title>
        <div class="flex items-center space-x-2">
          <CloseButton @size="xs" />
          <CloseButton @size="sm" />
          <CloseButton @size="md" />
          <CloseButton @size="lg" />
          <CloseButton @size="xl" />
        </div>

        <Divider />

        <Title>Spinner</Title>
        <div class="flex items-center space-x-2">
          <Spinner @size="xs" />
          <Spinner @size="sm" />
          <Spinner @size="md" />
          <Spinner @size="lg" />
          <Spinner @size="xl" />
        </div>

        <div class="flex items-center my-4 space-x-2">
          <Spinner @intent="default" />
          <Spinner @intent="primary" />
          <Spinner @intent="success" />
          <Spinner @intent="warning" />
          <Spinner @intent="danger" />
        </div>

        <Divider />

        <Title>Collapsible</Title>

        <CollapsibleDemo />

        {{outlet}}
      </div>
    </div>
  </template>
}
