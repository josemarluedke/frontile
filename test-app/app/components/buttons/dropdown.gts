import Component from '@glimmer/component';
import { action } from '@ember/object';
import { Dropdown } from '@frontile/collections';

export default class Example extends Component {
  @action
  onAction(key: string) {
    // eslint-disable-next-line
    console.log('Click on key', key);
  }

  @action
  delete() {
    alert('delete');
  }

  <template>
    <Dropdown as |d|>
      <d.Trigger @intent="primary" @size="sm">Dropdown</d.Trigger>

      <d.Menu @onAction={{this.onAction}} @intent="primary" as |Item|>
        <Item @key="profile" @description="View my profile">
          My Profile
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
          @class="text-danger"
          @onClick={{this.delete}}
        >
          Delete Account
        </Item>
      </d.Menu>
    </Dropdown>
  </template>
}
