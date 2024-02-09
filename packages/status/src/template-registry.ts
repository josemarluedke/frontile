import type { ProgressBar } from './index';

export default interface Registry {
  ProgressBar: typeof ProgressBar;
}
