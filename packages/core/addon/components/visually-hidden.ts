import Component from '@glimmer/component';

export interface VisuallyHiddenSignature {
  Element: HTMLDivElement;
}

export default class VisuallyHidden extends Component<VisuallyHiddenSignature> {}
