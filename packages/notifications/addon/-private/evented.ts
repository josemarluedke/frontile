import EmberObject from '@ember/object';
import EmberEvented from '@ember/object/evented';

/**
 * Partial wrapper for Ember's Evented Mixin, enabling
 * a pure class-based derivation
 * @private
 */

export default class Evented {
  eventManager = EmberObject.extend(EmberEvented).create();

  on(name: string, target: object, method?: string | Function): this {
    //@ts-ignore
    this.eventManager.on(name, target, method);
    return this;
  }

  off(name: string, target: object, method?: string | Function): this {
    //@ts-ignore
    this.eventManager.off(name, target, method);
    return this;
  }

  one(name: string, target: object, method?: string | Function): this {
    //@ts-ignore
    this.eventManager.one(name, target, method);
    return this;
  }

  has(name: string): boolean {
    return this.eventManager.has(name);
  }

  trigger(name: string, ...args: any[]): void {
    this.eventManager.trigger(name, ...args);
  }
}
