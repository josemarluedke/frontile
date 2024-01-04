import Service from '@ember/service';
import * as components from '../components';

export default class ThemeManagerService extends Service {
  get components() {
    return components;
  }
}

// DO NOT DELETE: this is how TypeScript knows how to look up your services.
declare module '@ember/service' {
  interface Registry {
    themeManager: ThemeManagerService;
  }
}
