import Controller from '@ember/controller';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';

export default class DocsController extends Controller {
  @tracked currentHeadingId?: string;

  @action setCurrentHeadingId(id: string): void {
    this.currentHeadingId = id;
  }
}
