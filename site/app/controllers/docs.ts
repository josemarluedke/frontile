import Controller from '@ember/controller';
import { tracked } from '@glimmer/tracking';

export default class DocsController extends Controller {
  @tracked currentHeadingId?: string;

  setCurrentHeadingId = (id: string): void => {
    this.currentHeadingId = id;
  };
}
