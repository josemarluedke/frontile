---
order: 1
manualDemoInsertion: true
---

# Close Button
If you pass the `@onClose` argument, the close button will be visible.
  
```hbs template
<Chip @appearance="faded" @onClose={{this.onClose}}>My Chip</Chip>
<Chip @appearance="faded" @intent="primary" @onClose={{this.onClose}}>My Chip</Chip>
<Chip @appearance="faded" @intent="success" @onClose={{this.onClose}}>My Chip</Chip>
<Chip @appearance="faded" @intent="warning" @onClose={{this.onClose}}>My Chip</Chip>
<Chip @appearance="faded" @intent="danger" @onClose={{this.onClose}}>My Chip</Chip>
```

```js component
import Component from '@glimmer/component';
import { action } from '@ember/object';

export default class DemoComponent extends Component {

  @action onClose() {
    console.log('closed')
  }
}
```
