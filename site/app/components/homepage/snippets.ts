// GENERATED FILE — do not edit by hand.
// Produced by site/lib/generate-homepage-snippets.mjs; run
// `pnpm generate-homepage-snippets` after changing a snippet or a ramp.
//
// Every string below is Shiki output from the same preset the docs pages use
// (`@docfy/plugin-shiki`), carrying `--shiki-light`/`--shiki-dark` custom
// properties rather than baked colours, so the homepage panels follow the
// theme without re-highlighting.

/** One step of a primary ramp, by the step names the theme plugin expects. */
export interface Level {
  name: string;
  value: string;
}

export interface ThemePreset {
  key: string;
  label: string;
  /** The family's 600 step, used for the picker's swatch. */
  swatch: string;
  light: Level[];
  dark: Level[];
  /** Pre-highlighted `<code>` for the configuration this ramp produces. */
  configHtml: string;
}

export const themePresets: ThemePreset[] = [
  {
    key: 'teal',
    label: 'Teal',
    swatch: '#076873',
    light: [
      {
        name: 'subtle',
        value: '#f1fdfc',
      },
      {
        name: 'muted',
        value: '#c6f5f4',
      },
      {
        name: 'soft',
        value: '#0768731a',
      },
      {
        name: 'mild',
        value: '#26a0aa',
      },
      {
        name: 'DEFAULT',
        value: '#076873',
      },
      {
        name: 'firm',
        value: '#01525c',
      },
      {
        name: 'strong',
        value: '#003138',
      },
      {
        name: 'bolder',
        value: '#00262c',
      },
    ],
    dark: [
      {
        name: 'subtle',
        value: '#003138',
      },
      {
        name: 'muted',
        value: '#01525c',
      },
      {
        name: 'soft',
        value: '#47c1c740',
      },
      {
        name: 'mild',
        value: '#12828e',
      },
      {
        name: 'DEFAULT',
        value: '#47c1c7',
      },
      {
        name: 'firm',
        value: '#7ce0e1',
      },
      {
        name: 'strong',
        value: '#c6f5f4',
      },
      {
        name: 'bolder',
        value: '#f1fdfc',
      },
    ],
    configHtml:
      '<code class="shiki" data-language="javascript"><span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D">// frontile.js</span></span>\n<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583">const</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8"> { </span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF">frontile</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8"> } </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583">=</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0"> require</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">(</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'@frontile/theme/plugin\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">);</span></span>\n<span class="line"></span>\n<span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF">module</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF">exports</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583"> =</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0"> frontile</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">({</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">  themes: {</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">    light: {</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">      colors: {</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">        primary: {</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          subtle: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#f1fdfc\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          muted: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#c6f5f4\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          soft: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#0768731a\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          mild: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#26a0aa\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          DEFAULT: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#076873\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          firm: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#01525c\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          strong: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#003138\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          bolder: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#00262c\'</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">        }</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">      }</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">    },</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">    dark: {</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">      colors: {</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">        primary: {</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          subtle: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#003138\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          muted: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#01525c\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          soft: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#47c1c740\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          mild: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#12828e\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          DEFAULT: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#47c1c7\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          firm: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#7ce0e1\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          strong: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#c6f5f4\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          bolder: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#f1fdfc\'</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">        }</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">      }</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">    }</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">  }</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">});</span></span></code>',
  },
  {
    key: 'blue',
    label: 'Blue',
    swatch: '#053273',
    light: [
      {
        name: 'subtle',
        value: '#f9fcff',
      },
      {
        name: 'muted',
        value: '#f1f7ff',
      },
      {
        name: 'soft',
        value: '#0532731a',
      },
      {
        name: 'mild',
        value: '#4a8ee7',
      },
      {
        name: 'DEFAULT',
        value: '#053273',
      },
      {
        name: 'firm',
        value: '#001b4e',
      },
      {
        name: 'strong',
        value: '#00072d',
      },
      {
        name: 'bolder',
        value: '#020825',
      },
    ],
    dark: [
      {
        name: 'subtle',
        value: '#00072d',
      },
      {
        name: 'muted',
        value: '#001b4e',
      },
      {
        name: 'soft',
        value: '#95c4ff40',
      },
      {
        name: 'mild',
        value: '#2259a6',
      },
      {
        name: 'DEFAULT',
        value: '#95c4ff',
      },
      {
        name: 'firm',
        value: '#d2e6ff',
      },
      {
        name: 'strong',
        value: '#f1f7ff',
      },
      {
        name: 'bolder',
        value: '#f9fcff',
      },
    ],
    configHtml:
      '<code class="shiki" data-language="javascript"><span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D">// frontile.js</span></span>\n<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583">const</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8"> { </span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF">frontile</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8"> } </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583">=</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0"> require</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">(</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'@frontile/theme/plugin\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">);</span></span>\n<span class="line"></span>\n<span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF">module</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF">exports</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583"> =</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0"> frontile</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">({</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">  themes: {</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">    light: {</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">      colors: {</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">        primary: {</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          subtle: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#f9fcff\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          muted: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#f1f7ff\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          soft: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#0532731a\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          mild: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#4a8ee7\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          DEFAULT: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#053273\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          firm: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#001b4e\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          strong: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#00072d\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          bolder: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#020825\'</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">        }</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">      }</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">    },</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">    dark: {</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">      colors: {</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">        primary: {</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          subtle: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#00072d\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          muted: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#001b4e\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          soft: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#95c4ff40\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          mild: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#2259a6\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          DEFAULT: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#95c4ff\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          firm: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#d2e6ff\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          strong: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#f1f7ff\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          bolder: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#f9fcff\'</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">        }</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">      }</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">    }</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">  }</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">});</span></span></code>',
  },
  {
    key: 'pink',
    label: 'Pink',
    swatch: '#c10566',
    light: [
      {
        name: 'subtle',
        value: '#fefafc',
      },
      {
        name: 'muted',
        value: '#ffebf4',
      },
      {
        name: 'soft',
        value: '#c105661a',
      },
      {
        name: 'mild',
        value: '#f17bad',
      },
      {
        name: 'DEFAULT',
        value: '#c10566',
      },
      {
        name: 'firm',
        value: '#920147',
      },
      {
        name: 'strong',
        value: '#4a011c',
      },
      {
        name: 'bolder',
        value: '#390011',
      },
    ],
    dark: [
      {
        name: 'subtle',
        value: '#4a011c',
      },
      {
        name: 'muted',
        value: '#920147',
      },
      {
        name: 'soft',
        value: '#fca8cc40',
      },
      {
        name: 'mild',
        value: '#e1458a',
      },
      {
        name: 'DEFAULT',
        value: '#fca8cc',
      },
      {
        name: 'firm',
        value: '#ffcee4',
      },
      {
        name: 'strong',
        value: '#ffebf4',
      },
      {
        name: 'bolder',
        value: '#fefafc',
      },
    ],
    configHtml:
      '<code class="shiki" data-language="javascript"><span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D">// frontile.js</span></span>\n<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583">const</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8"> { </span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF">frontile</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8"> } </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583">=</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0"> require</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">(</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'@frontile/theme/plugin\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">);</span></span>\n<span class="line"></span>\n<span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF">module</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF">exports</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583"> =</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0"> frontile</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">({</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">  themes: {</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">    light: {</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">      colors: {</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">        primary: {</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          subtle: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#fefafc\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          muted: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#ffebf4\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          soft: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#c105661a\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          mild: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#f17bad\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          DEFAULT: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#c10566\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          firm: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#920147\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          strong: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#4a011c\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          bolder: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#390011\'</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">        }</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">      }</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">    },</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">    dark: {</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">      colors: {</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">        primary: {</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          subtle: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#4a011c\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          muted: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#920147\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          soft: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#fca8cc40\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          mild: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#e1458a\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          DEFAULT: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#fca8cc\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          firm: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#ffcee4\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          strong: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#ffebf4\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          bolder: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#fefafc\'</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">        }</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">      }</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">    }</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">  }</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">});</span></span></code>',
  },
  {
    key: 'green',
    label: 'Green',
    swatch: '#2fc511',
    light: [
      {
        name: 'subtle',
        value: '#f7ffeb',
      },
      {
        name: 'muted',
        value: '#e6ffbc',
      },
      {
        name: 'soft',
        value: '#2fc5111a',
      },
      {
        name: 'mild',
        value: '#a3fa3a',
      },
      {
        name: 'DEFAULT',
        value: '#2fc511',
      },
      {
        name: 'firm',
        value: '#07a20a',
      },
      {
        name: 'strong',
        value: '#005321',
      },
      {
        name: 'bolder',
        value: '#002e1b',
      },
    ],
    dark: [
      {
        name: 'subtle',
        value: '#005321',
      },
      {
        name: 'muted',
        value: '#07a20a',
      },
      {
        name: 'soft',
        value: '#bbff6040',
      },
      {
        name: 'mild',
        value: '#66e221',
      },
      {
        name: 'DEFAULT',
        value: '#bbff60',
      },
      {
        name: 'firm',
        value: '#d1ff8c',
      },
      {
        name: 'strong',
        value: '#e6ffbc',
      },
      {
        name: 'bolder',
        value: '#f7ffeb',
      },
    ],
    configHtml:
      '<code class="shiki" data-language="javascript"><span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D">// frontile.js</span></span>\n<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583">const</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8"> { </span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF">frontile</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8"> } </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583">=</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0"> require</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">(</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'@frontile/theme/plugin\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">);</span></span>\n<span class="line"></span>\n<span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF">module</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF">exports</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583"> =</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0"> frontile</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">({</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">  themes: {</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">    light: {</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">      colors: {</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">        primary: {</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          subtle: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#f7ffeb\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          muted: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#e6ffbc\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          soft: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#2fc5111a\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          mild: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#a3fa3a\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          DEFAULT: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#2fc511\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          firm: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#07a20a\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          strong: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#005321\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          bolder: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#002e1b\'</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">        }</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">      }</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">    },</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">    dark: {</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">      colors: {</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">        primary: {</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          subtle: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#005321\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          muted: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#07a20a\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          soft: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#bbff6040\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          mild: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#66e221\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          DEFAULT: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#bbff60\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          firm: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#d1ff8c\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          strong: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#e6ffbc\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">,</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">          bolder: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'#f7ffeb\'</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">        }</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">      }</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">    }</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">  }</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">});</span></span></code>',
  },
];

export const signatureSnippetHtml =
  '<code class="shiki" data-language="ts"><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583">import</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8"> { Table, </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583">type</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8"> ColumnConfig } </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583">from</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF"> \'frontile\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">;</span></span>\n<span class="line"></span>\n<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583">interface</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0"> Member</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8"> { </span><span style="--shiki-light:#E36209;--shiki-dark:#FFAB70">id</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583">:</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF"> string</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">; </span><span style="--shiki-light:#E36209;--shiki-dark:#FFAB70">name</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583">:</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF"> string</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">; </span><span style="--shiki-light:#E36209;--shiki-dark:#FFAB70">role</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583">:</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF"> string</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8"> }</span></span>\n<span class="line"></span>\n<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583">const</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF"> columns</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583"> =</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8"> [</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">  { key: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'name\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">, name: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'Member\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8"> },</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">  { key: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'role\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">, name: </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF">\'Role\'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8"> }</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">] </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583">as</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0"> const</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583"> satisfies</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0"> ColumnConfig</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">&#x3C;</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0">Member</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">>[];</span></span></code>';

export const templateSnippetHtml =
  '<code class="shiki" data-language="handlebars"><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">&#x3C;</span><span style="--shiki-light:#22863A;--shiki-dark:#85E89D">Table</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8"> @</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0">columns=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF">{{</span><span style="--shiki-light:#E36209;--shiki-dark:#FFAB70">columns</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF">}}</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8"> @</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0">items=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF">{{</span><span style="--shiki-light:#E36209;--shiki-dark:#FFAB70">members</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF">}}</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8"> /></span></span>\n<span class="line"></span>\n<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D">{{! Glint checks this against ColumnConfig&#x3C;Member>: }}</span></span>\n<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8">&#x3C;</span><span style="--shiki-light:#22863A;--shiki-dark:#85E89D">Table</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8"> @</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0">columns=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF">{{</span><span style="--shiki-light:#E36209;--shiki-dark:#FFAB70">columns</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF">}}</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8"> @</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0">items=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF">{{</span><span style="--shiki-light:#E36209;--shiki-dark:#FFAB70">projects</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF">}}</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8"> /></span></span>\n<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D">{{! ^ Type \'Project[]\' is not assignable to \'Member[]\' }}</span></span></code>';
