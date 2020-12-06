import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { BufferedChangeset } from 'ember-changeset/types';
import { action } from '@ember/object';
import { assert } from '@ember/debug';

interface ChangesetFormArgs {
  changeset: BufferedChangeset;

  runExecuteInsteadOfSave?: boolean;

  onSubmit?: (data: unknown, event: Event) => void;
  onReset?: (data: unknown, event: Event) => void;
}

export default class ChangesetForm extends Component<ChangesetFormArgs> {
  @tracked hasSubmitted = false;

  constructor(owner: unknown, args: ChangesetFormArgs) {
    super(owner, args);
    assert('@changeset must be defined on <ChangesetForm> component', this.args.changeset);
  }

  @action
  async handleSubmit(
    changeset: BufferedChangeset,
    event: Event
  ): Promise<void> {
    event.preventDefault();
    await changeset.validate();

    this.hasSubmitted = true;

    if (changeset.isInvalid) {
      return;
    }

    let result;
    if (this.args.runExecuteInsteadOfSave) {
      result = changeset.execute();
    } else {
      result = await changeset.save({});
    }

    if (typeof this.args.onSubmit === 'function') {
      this.args.onSubmit(result.data, event);
    }
  }

  @action
  handleReset(changeset: BufferedChangeset, event: Event): void {
    event.preventDefault();
    this.hasSubmitted = false;

    const { data } = changeset.rollback();
    if (typeof this.args.onReset === 'function') {
      this.args.onReset(data, event);
    }
  }
}
