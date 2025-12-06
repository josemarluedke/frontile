import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { later } from '@ember/runloop';
import { Button } from 'frontile';
import { on } from '@ember/modifier';
import { RadioGroup } from 'frontile';
import { Drawer } from 'frontile';
import Popover from './popover';
import DemoModal from './demo-modal';
import FormExample from '../forms/form-example';
import type { DrawerSignature } from '@frontile/overlays/components/drawer';

export default class DemoDrawer extends Component {
  @tracked isOpen = false;
  @tracked isLoading = false;
  @tracked isInPlaceOpen = false;
  @tracked placement: DrawerSignature['Args']['placement'] = 'right';
  @tracked size: DrawerSignature['Args']['size'] = 'md';

  @action toggleIsOpen(): void {
    this.isOpen = !this.isOpen;
  }

  @action toggleIsInPlaceOpen(): void {
    this.isInPlaceOpen = !this.isInPlaceOpen;
  }

  @action setPlacement(placement: string, _: Event): void {
    this.placement = placement as DrawerSignature['Args']['placement'];
  }

  @action setSize(size: string): void {
    this.size = size as DrawerSignature['Args']['size'];
  }

  @action save(): void {
    this.isLoading = true;

    later(
      this,
      () => {
        this.isLoading = false;
        this.isOpen = false;
        this.isInPlaceOpen = false;
      },
      1000
    );
  }

  <template>
    <div class="mt-10">
      <div>
        <Button {{on "click" this.toggleIsOpen}}>
          Open Drawer
        </Button>

        <Button {{on "click" this.toggleIsInPlaceOpen}}>
          Open In Place Drawer
        </Button>
      </div>

      <div class="mt-4 flex flex-col gap-y-2">
        <RadioGroup
          @orientation="horizontal"
          @label="Placement"
          @value={{this.placement}}
          @onChange={{this.setPlacement}}
          as |Radio|
        >
          <Radio @value="top" @label="top" />
          <Radio @value="right" @label="right" />
          <Radio @value="bottom" @label="bottom" />
          <Radio @value="left" @label="left" />
        </RadioGroup>

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
      </div>

      <Drawer
        @isOpen={{this.isOpen}}
        @onClose={{this.toggleIsOpen}}
        @size={{this.size}}
        @placement={{this.placement}}
        @backdrop="blur"
        as |d|
      >
        <d.Header>Header</d.Header>
        <d.Body>
          <FormExample />

          <DemoModal />
          <p class="pt-4">
            Body Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed
            diam nonumy eirmod tempor invidunt ut labore et dolore magna
            aliquyam erat, sed diam voluptua. At vero eos et accusam et justo
            duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata
            sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet,
            consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt
            ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero
            eos et accusam et justo duo dolores et ea rebum. Stet clita kasd
            gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.
            Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam
            nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam
            erat, sed diam voluptua. At vero eos et accusam et justo duo dolores
            et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est
            Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur
            sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore
            et dolore magna aliquyam erat, sed diam voluptua. At vero eos et
            accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren,
            no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum
            dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod
            tempor invidunt ut labore et dolore magna aliquyam erat, sed diam
            voluptua. At vero eos et accusam et justo duo dolores et ea rebum.
            Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum
            dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing
            elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore
            magna aliquyam erat, sed diam voluptua. At vero eos et accusam et
            justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea
            takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor
            sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor
            invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
            At vero eos et accusam et justo duo dolores et ea rebum. Stet clita
            kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit
            amet.
          </p>

        </d.Body>
        <d.Footer>
          <Button
            @appearance="minimal"
            class="mr-4"
            {{on "click" this.toggleIsOpen}}
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
        </d.Footer>
      </Drawer>

      <div
        class="relative h-64 mt-4 border border-neutral-subtle bg-surface-solid-1 rounded w-3xl"
      >
        <Drawer
          @isOpen={{this.isInPlaceOpen}}
          @onClose={{this.toggleIsInPlaceOpen}}
          @renderInPlace={{true}}
          @size={{this.size}}
          @placement={{this.placement}}
          @disableFocusTrap={{true}}
          @allowCloseButton={{false}}
          as |d|
        >
          <d.Header>
            Header

            <d.CloseButton
              @size="lg"
              @class="relative inset-auto ml-6 text-blue-500 bg-gray-200 rounded-md hover:bg-gray-500"
            />
          </d.Header>
          <d.Body>
            In Place
            <Popover />
          </d.Body>
          <d.Footer>
            <Button
              @appearance="minimal"
              @class="mr-4"
              {{on "click" this.toggleIsInPlaceOpen}}
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
          </d.Footer>
        </Drawer>
      </div>
    </div>
  </template>
}
