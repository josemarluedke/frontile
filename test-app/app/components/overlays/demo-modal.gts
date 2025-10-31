import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Button } from 'frontile';
import { Modal } from 'frontile';
import { action } from '@ember/object';
import { later } from '@ember/runloop';
import { on } from '@ember/modifier';
import { RadioGroup } from 'frontile';
import type { ModalSignature } from '@frontile/overlays/components/modal';

interface DemoModalArgs {}

export default class DemoModal extends Component<DemoModalArgs> {
  @tracked isOpen = false;
  @tracked isInPlaceOpen = false;
  @tracked isLoading = false;
  @tracked size: ModalSignature['Args']['size'] = 'lg';

  @action toggleModal(): void {
    this.isOpen = !this.isOpen;
  }

  @action setSize(size: string): void {
    this.size = size as ModalSignature['Args']['size'];
  }

  @action toggleInPlaceModal(): void {
    this.isInPlaceOpen = !this.isInPlaceOpen;
  }

  @action save(): void {
    this.isLoading = true;

    later(
      this,
      () => {
        this.isLoading = false;
        this.isOpen = false;
      },
      1000
    );
  }

  <template>
    <div class="mt-6">
      <Button {{on "click" this.toggleModal}}>
        Open Modal
      </Button>

      <Button {{on "click" this.toggleInPlaceModal}}>
        Open In Place Modal
      </Button>
    </div>

    <RadioGroup
      @orientation="horizontal"
      @label="Size"
      @value={{this.size}}
      @onChange={{this.setSize}}
      as |Radio|
    >
      <Radio @value="xs" @label="xs" />
      <Radio @value="sm" @label="sm" />
      <Radio @value="md" @label="md" />
      <Radio @value="lg" @label="lg" />
      <Radio @value="xl" @label="xl" />
      <Radio @value="full" @label="full" />
    </RadioGroup>

    <Modal
      @isOpen={{this.isOpen}}
      @onClose={{this.toggleModal}}
      @renderInPlace={{false}}
      @size={{this.size}}
      as |m|
    >
      <m.Header>Title</m.Header>
      <m.Body>
        <p>Some contents...</p>
        <p>Some contents...</p>
        <p>Some contents...</p>
        <p>
          Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam
          nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat,
          sed diam voluptua. At vero eos et accusam et justo duo dolores et ea
          rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem
          ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur
          sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et
          dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam
          et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea
          takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit
          amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor
          invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
          At vero eos et accusam et justo duo dolores et ea rebum. Stet clita
          kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit
          amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed
          diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam
          erat, sed diam voluptua. At vero eos et accusam et justo duo dolores
          et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est
          Lorem ipsum dolor sit amet.
        </p>
      </m.Body>
      <m.Footer>
        <Button
          @appearance="minimal"
          class="mr-4"
          {{on "click" this.toggleModal}}
        >
          Cancel
        </Button>
        <Button
          @intent="primary"
          disabled={{this.isLoading}}
          {{on "click" this.save}}
        >
          {{if this.isLoading "Loading..." "Save"}}
        </Button>
      </m.Footer>
    </Modal>

    <div
      class="relative h-64 mt-4 border border-default-200 bg-content1 rounded w-3xl"
    >
      <Modal
        @isOpen={{this.isInPlaceOpen}}
        @onClose={{this.toggleInPlaceModal}}
        @renderInPlace={{true}}
        @disableFocusTrap={{true}}
        @size={{this.size}}
        as |m|
      >
        <m.Header>Title</m.Header>
        <m.Body>
          <p>Some contents...</p>
          <p>Some contents...</p>
          <p>Some contents...</p>
        </m.Body>
        <m.Footer>
          <Button @intent="primary" {{on "click" this.toggleModal}}>
            Save
          </Button>
        </m.Footer>
      </Modal>
    </div>
  </template>
}
