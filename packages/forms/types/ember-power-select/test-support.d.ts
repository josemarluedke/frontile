declare module 'ember-power-select/test-support' {
  export function selectChoose(
    cssPath: string,
    optionTextOrOptionSelector: string,
    index?: number
  ): Promise<void>;
  export function selectSearch(
    cssPath: string,
    searchText: string
  ): Promise<void>;
  export function removeMultipleOption(
    cssPath: string,
    optionText: string
  ): Promise<void>;
  export function clearSelected(
    cssPath: string,
    optionText: string
  ): Promise<void>;
}

declare module 'ember-power-select/test-support/helpers' {
  export function clickTrigger(scope?: string): Promise<void>;
  export function typeInSearch(text: string): Promise<void>;
  export function selectChoose(text: string): Promise<void>;
}
