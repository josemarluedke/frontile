import Component from '@glimmer/component';
import data from './args-data';

interface ArgsTableArgs {
  /**
   * The component name
   */
  of: string;
}

export default class ArgsTable extends Component<ArgsTableArgs> {
  get component(): unknown {
    return data.filter((component) => {
      return component.name == this.args.of;
    })[0];
  }
}
