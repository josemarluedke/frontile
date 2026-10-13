import Component from '@glimmer/component';
import { Dropdown } from 'frontile';

export default class Example extends Component {
  onAction = (key: string) => {
    // eslint-disable-next-line
    console.log('Click on key', key);
  };

  delete = () => {
    alert('delete');
  };

  <template>
    <Dropdown as |d|>
      <d.Trigger @color="primary" @size="sm">Dropdown</d.Trigger>

      <d.Menu @onAction={{this.onAction}} @color="primary" as |Item|>
        <Item @key="profile" @description="View my profile">
          My Profile
        </Item>
        <Item @key="settings" @shortcut="⌘⇧S">Settings</Item>
        <Item @key="notifications" @shortcut="⌘⇧N" @withDivider={{true}}>
          Notifications
        </Item>
        <Item @key="reset" @color="danger" @class="text-danger">
          Reset Settings
        </Item>
        <Item
          @key="delete"
          @shortcut="⌘⇧D"
          @color="danger"
          @class="text-danger"
          @onClick={{this.delete}}
        >
          Delete Account
        </Item>
      </d.Menu>
    </Dropdown>
  </template>
}
