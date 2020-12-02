import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Changeset } from 'ember-changeset';
import { BufferedChangeset, ValidatorMap } from 'ember-changeset/types';
import { action } from '@ember/object';
import { assert } from '@ember/debug';
import lookupValidator from 'ember-changeset-validations';

interface ChangesetFormArgs {
  model?: { [key: string]: unknown };
  changeset?: BufferedChangeset;
  validations?: ValidatorMap;

  runExecuteInsteadOfSave?: boolean;

  onSubmit?: (data: unknown, event: Event) => void;
  onReset?: (data: unknown, event: Event) => void;
}

export default class ChangesetForm extends Component<ChangesetFormArgs> {
  @tracked changeset!: BufferedChangeset;

  @tracked hasSubmitted = false;

  @action
  setup() {
    if (typeof this.args.changeset === 'undefined') {
      assert(
        '@model must be defined on <ChangesetForm> component if you do not provide a @changeset argument',
        typeof this.args.model !== 'undefined'
      );

      if (typeof this.args.validations !== 'undefined') {
        this.changeset = Changeset(
          this.args.model || {},
          lookupValidator(this.args.validations || {}),
          this.args.validations
        );
      } else {
        this.changeset = Changeset(this.args.model || {});
      }
    } else {
      this.changeset = this.args.changeset;
    }
  }

  @action
  async handleSubmit(event: Event): Promise<void> {
    event.preventDefault();
    await this.changeset.validate();

    this.hasSubmitted = true;

    if (this.changeset.isInvalid) {
      return;
    }

    let result;
    if (this.args.runExecuteInsteadOfSave) {
      result = this.changeset.execute();
    } else {
      result = await this.changeset.save({});
    }

    if (typeof this.args.onSubmit === 'function') {
      this.args.onSubmit(result.data, event);
    }
  }

  @action
  handleReset(event: Event): void {
    event.preventDefault();
    this.hasSubmitted = false;

    const { data } = this.changeset.rollback();
    if (typeof this.args.onReset === 'function') {
      this.args.onReset(data, event);
    }
  }
}
