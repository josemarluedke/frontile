import type MyComponent from './components/my-component';

export default interface Registry {
  MyComponent: typeof MyComponent;
}
