import type Button from './components/button';
import type Chip from './components/chip';

export default interface Registry {
  Button: typeof Button;
  Chip: typeof Chip;
}
