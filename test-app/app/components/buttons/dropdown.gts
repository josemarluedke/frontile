import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { array } from '@ember/helper';
import { Dropdown } from '@frontile/buttons';

export default class Example extends Component {
  @tracked selectedKeys: string[] = [];
  @tracked selectedKeys2: string[] = [];

  @action
  onChange(value: boolean): void {
    this.isSelected = value;
  }

  @action
  onAction(key: string) {
    // eslint-disable-next-line
    console.log('Click on key', key);
  }

  @action
  onSelectionChange(keys: string[]) {
    this.selectedKeys = keys;
  }

  @action
  onSelectionChange2(keys: string[]) {
    this.selectedKeys2 = keys;
  }

  <template>
    <Dropdown as |d|>
      <d.Trigger>Dropdown</d.Trigger>

      <d.Content as |Item|>
        <Item @key="profile" @description="View my profile">
          My Provile
        </Item>
        <Item @key="settings" @shortcut="⌘⇧S">Settings</Item>
        <Item @key="notifications" @shortcut="⌘⇧N" @withDivider={{true}}>
          Notifications
        </Item>
        <Item @key="reset" @intent="danger" @class="text-danger">
          Reset Settings
        </Item>
        <Item
          @key="delete"
          @shortcut="⌘⇧D"
          @intent="danger"
          @appearance="faded"
          @class="text-danger"
        >
          Delete Account
        </Item>
      </d.Content>
    </Dropdown>
  </template>
}
