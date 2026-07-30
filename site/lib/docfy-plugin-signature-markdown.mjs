const SIGNATURE_TAG_PATTERN = /<Signature\s+([^>]*?)\/>/g;
const ATTR_PATTERN = /@(component|package|module)="([^"]*)"/g;

export function parseSignatureTag(attrsString) {
  const tag = {};
  let match;

  ATTR_PATTERN.lastIndex = 0;
  while ((match = ATTR_PATTERN.exec(attrsString)) !== null) {
    tag[match[1]] = match[2];
  }

  return tag;
}

export function findComponent(signatureData, tag) {
  return signatureData.find((entry) => {
    return (
      entry.name === tag.component &&
      (!tag.package || entry.package === tag.package) &&
      (!tag.module || entry.module === tag.module)
    );
  });
}

function shouldIgnoreArg(tags) {
  return Boolean(tags && Object.keys(tags).includes('ignore'));
}

function escapeCell(text) {
  return String(text).replace(/\|/g, '\\|').replace(/\s*\n\s*/g, ' ').trim();
}

function formatType(type) {
  if (!type) {
    return '';
  }

  const value = type.raw || type.type;

  return value ? `\`${escapeCell(value)}\`` : '';
}

function formatDescription(item) {
  const description = item.description ? escapeCell(item.description) : '';

  return item.isInternal ? `${description} _(internal)_`.trim() : description;
}

function buildPropertiesTable(items) {
  const rows = (items || []).filter((item) => !shouldIgnoreArg(item.tags));

  if (rows.length === 0) {
    return '';
  }

  const lines = ['| Name | Type | Default | Description |', '| --- | --- | --- | --- |'];

  rows.forEach((item) => {
    const name = item.isRequired
      ? `${item.identifier} *`
      : item.identifier;
    const type = formatType(item.type);
    const defaultValue = item.defaultValue
      ? `\`${escapeCell(item.defaultValue)}\``
      : '-';
    const description = formatDescription(item);

    lines.push(`| \`${escapeCell(name)}\` | ${type} | ${defaultValue} | ${description} |`);
  });

  return lines.join('\n');
}

export function buildSignatureMarkdown(entry) {
  const lines = [`### ${entry.name}`, ''];

  if (entry.description) {
    lines.push(entry.description, '');
  }

  if (entry.Element && entry.Element.type && entry.Element.type.type) {
    lines.push(`**Element:** \`${entry.Element.type.type}\``, '');
  }

  lines.push('**Arguments**', '');
  lines.push(buildPropertiesTable(entry.Args) || '_No arguments._', '');

  if (entry.Blocks && entry.Blocks.length > 0) {
    const blocksTable = buildPropertiesTable(entry.Blocks);

    if (blocksTable) {
      lines.push('**Blocks**', '', blocksTable, '');
    }
  }

  return lines.join('\n').trimEnd();
}

function describeTag(tag) {
  const parts = [`@component="${tag.component}"`];

  if (tag.package) {
    parts.push(`@package="${tag.package}"`);
  }

  if (tag.module) {
    parts.push(`@module="${tag.module}"`);
  }

  return `<Signature ${parts.join(' ')} />`;
}

export function resolveSignatureTags(markdown, signatureData, pageUrl) {
  return markdown.replace(SIGNATURE_TAG_PATTERN, (match, attrsString) => {
    const tag = parseSignatureTag(attrsString);

    if (!tag.component) {
      return match;
    }

    const entry = findComponent(signatureData, tag);

    if (!entry) {
      console.warn(
        `[docfy-plugin-signature-markdown] No component found for ${describeTag(tag)} on page ${pageUrl}`
      );

      return match;
    }

    return buildSignatureMarkdown(entry);
  });
}

export function docfyPluginSignatureMarkdown(signatureData) {
  return {
    runAfter(ctx) {
      ctx.pages.forEach((page) => {
        const resolved = resolveSignatureTags(
          page.markdown,
          signatureData,
          page.meta.url
        );

        if (resolved !== page.markdown) {
          page.pluginData.staticMarkdown = resolved;
        }
      });
    },
  };
}

export default docfyPluginSignatureMarkdown;
