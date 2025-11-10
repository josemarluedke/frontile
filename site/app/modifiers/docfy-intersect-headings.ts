import Modifier, {
  type ArgsFor,
  type PositionalArgs,
  type NamedArgs,
} from 'ember-modifier';
import { action } from '@ember/object';
import { registerDestructor } from '@ember/destroyable';

interface Heading {
  id: string;
  headings: Heading[];
}

function getHeadingIds(headings: Heading[], output: string[] = []): string[] {
  if (typeof headings === 'undefined') {
    return [];
  }
  headings.forEach((heading) => {
    output.push(heading.id);
    getHeadingIds(heading.headings, output);
  });
  return output;
}

interface Signature {
  Args: {
    Named: {
      headings: Heading[];
      onIntersect: (headingId: string) => void;
    };
    Positional: unknown[];
  };
  Element: Element;
}

export default class IntersectHeadingsModifier extends Modifier<Signature> {
  handler: ((headingId: string) => void) | null = null;
  headings: string[] = [];
  observer: IntersectionObserver | null = null;
  activeIndex: number = -1;

  @action
  handleObserver(elements: IntersectionObserverEntry[]): void {
    // Based on https://taylor.callsen.me/modern-navigation-menus-with-css-position-sticky-and-intersectionobservers/

    // current index must be memoized or tracked outside of function for comparison
    let localActiveIndex: number = this.activeIndex || -1;

    // track which elements register above or below the document's current position
    const aboveIndeces: number[] = [];
    const belowIndeces: number[] = [];

    // loop through each intersection element
    //  due to the asychronous nature of observers, callbacks must be designed to handle 1 or many intersecting elements
    elements.forEach((element) => {
      // detect if intersecting element is above the browser viewport; include cross browser logic
      const boundingClientRectY =
        typeof element.boundingClientRect.y !== 'undefined'
          ? element.boundingClientRect.y
          : element.boundingClientRect.top;
      const rootBoundsY =
        typeof element.rootBounds?.y !== 'undefined'
          ? element.rootBounds.y
          : element.rootBounds?.top;
      const isAbove = boundingClientRectY < (rootBoundsY || 0);

      const id = element.target.getAttribute('id');
      const intersectingElemIdx = this.headings.findIndex((item) => item == id);

      // record index as either above or below current index
      if (isAbove) aboveIndeces.push(intersectingElemIdx);
      else belowIndeces.push(intersectingElemIdx);
    });

    // determine min and max fired indeces values (support for multiple elements firing at once)
    const minIndex = Math.min(...belowIndeces);
    const maxIndex = Math.max(...aboveIndeces);

    // determine how to adjust localActiveIndex based on scroll direction
    if (aboveIndeces.length > 0) {
      // scrolling down - set to max of fired indeces
      localActiveIndex = maxIndex;
    } else if (belowIndeces.length > 0 && minIndex <= this.activeIndex) {
      // scrolling up - set to minimum of fired indeces
      localActiveIndex = minIndex - 1 >= 0 ? minIndex - 1 : 0;
    }

    // render new index to DOM (if required)
    if (localActiveIndex != this.activeIndex) {
      this.activeIndex = localActiveIndex;

      if (typeof this.handler === 'function') {
        this.handler(this.headings[this.activeIndex] as string);
      }
    }
  }

  observe(): void {
    if ('IntersectionObserver' in window) {
      this.observer = new IntersectionObserver(this.handleObserver, {
        rootMargin: '-96px', // Distance from top to heading id
        threshold: 1.0,
      });

      this.headings.forEach((id) => {
        const el = document.getElementById(id);
        if (el) {
          this.observer?.observe(el);
        }
      });
    }
  }

  unobserve(): void {
    if (this && this.observer) {
      this.observer.disconnect();
    }
  }

  constructor(owner: unknown, args: ArgsFor<Signature>) {
    super(owner as never, args);
    this.handler = args.named.onIntersect;
    this.headings = getHeadingIds(args.named.headings);

    this.observe();

    registerDestructor(this, this.unobserve);
  }

  modify(
    element: HTMLElement,
    _: PositionalArgs<Signature>,
    args: NamedArgs<Signature>
  ): void {
    if (this.observer) {
      this.unobserve();
    }
    this.handler = args.onIntersect;
    this.headings = getHeadingIds(args.headings);

    this.observe();

    registerDestructor(this, this.unobserve);
  }
}
