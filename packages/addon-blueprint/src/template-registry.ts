import type { MyComponent } from './index';

export default interface Registry {
  MyComponent: typeof MyComponent;
}
