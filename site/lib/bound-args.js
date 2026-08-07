/**
 * Glint's `WithBoundArgs<T, 'a' | 'b'>` is a conditional type that only resolves
 * when `T` is `Invokable`. In the plain `tsc` program that `glimmer-docgen-typescript`
 * builds from the emitted `.d.ts` files there is no Glint environment registered, so
 * Glimmer component classes never get the `[Invoke]` brand and the conditional falls
 * through to `never`. Even where it does resolve (`ComponentLike<…>` based signatures)
 * the resulting `Invokable<(named?: PrebindArgs<…>) => ComponentReturn<…>>` blob is
 * unreadable in the docs.
 *
 * Rather than fight the checker, this module reads the same `.d.ts` files
 * syntactically and renders every `WithBoundArgs` arg and block param as
 * `ComponentName (arg1, arg2 bound)`.
 */
const fs = require('fs');
const path = require('path');
const ts = require('typescript');

/** Type helpers that take `[target, boundArgNames]` and pre-bind named args. */
const BOUND_ARG_HELPERS = new Set([
  'WithBoundArgs',
  'WithBoundArgsForSignature',
]);

const MAX_DEPTH = 24;

function stripSuffix(name, suffix) {
  if (name.length > suffix.length && name.endsWith(suffix)) {
    return name.slice(0, -suffix.length);
  }
  return name;
}

/**
 * Turn the first type argument of `WithBoundArgs` into something a reader
 * recognizes: `typeof FooComponent` -> `Foo`, `ComponentLike<FooSignature>` -> `Foo`.
 */
function friendlyComponentName(typeNode) {
  let text;

  if (ts.isTypeQueryNode(typeNode)) {
    // `typeof Foo` / `typeof Foo<T>`
    text = typeNode.getText().replace(/^typeof\s+/, '');
  } else if (
    ts.isTypeReferenceNode(typeNode) &&
    typeNode.typeArguments &&
    typeNode.typeArguments.length === 1 &&
    typeNode.typeName.getText() === 'ComponentLike'
  ) {
    text = typeNode.typeArguments[0].getText();
  } else {
    text = typeNode.getText();
  }

  text = text.replace(/\s+/g, ' ').trim();

  // Strip the conventional suffix from the name itself, leaving type args alone.
  const generics = text.indexOf('<');
  const base = generics === -1 ? text : text.slice(0, generics);
  const rest = generics === -1 ? '' : text.slice(generics);
  const cleaned = stripSuffix(stripSuffix(base, 'Signature'), 'Component');

  return `${cleaned}${rest}` || text;
}

/** `'a' | 'b'` -> `['a', 'b']` */
function boundArgNames(typeNode) {
  const names = [];
  const collect = (node) => {
    if (ts.isUnionTypeNode(node)) {
      node.types.forEach(collect);
    } else if (ts.isLiteralTypeNode(node) && ts.isStringLiteral(node.literal)) {
      names.push(node.literal.text);
    } else {
      names.push(node.getText().replace(/\s+/g, ' ').trim());
    }
  };
  collect(typeNode);
  return names;
}

function formatBound(bound) {
  return bound.args.length
    ? `${bound.target} (${bound.args.join(', ')} bound)`
    : bound.target;
}

function normalizeTypeText(text) {
  return text
    .replace(/\/\*[\s\S]*?\*\//g, ' ')
    .replace(/\/\/[^\n]*/g, ' ')
    .replace(/\s+/g, ' ')
    .replace(/\s*;\s*/g, '; ')
    .replace(/([[{])\s+/g, '$1 ')
    .replace(/\[\s+/g, '[')
    .replace(/\s+\]/g, ']')
    .trim();
}

/**
 * Print `node`'s source text with the given absolute ranges swapped out, so a
 * block's tuple keeps its authored shape while the `WithBoundArgs` references
 * become readable.
 */
function printWithReplacements(node, replacements) {
  const source = node.getSourceFile().text;
  const end = node.getEnd();
  let cursor = node.getStart();
  let out = '';

  for (const replacement of [...replacements].sort(
    (a, b) => a.start - b.start
  )) {
    out += source.slice(cursor, replacement.start) + replacement.text;
    cursor = replacement.end;
  }

  return normalizeTypeText(out + source.slice(cursor, end));
}

function propertyName(member) {
  if (!member.name) {
    return undefined;
  }
  return ts.isIdentifier(member.name)
    ? member.name.text
    : member.name.getText();
}

/**
 * Reads `.d.ts` files on demand and resolves the type references within them.
 * Only relative imports are followed — everything else stays opaque, which is
 * fine because component signatures live next to their components.
 */
class Declarations {
  constructor() {
    this.files = new Map();
  }

  /** @returns {{sourceFile, aliases, interfaces, imports}|undefined} */
  read(filePath) {
    if (this.files.has(filePath)) {
      return this.files.get(filePath);
    }

    let index;
    try {
      const sourceFile = ts.createSourceFile(
        filePath,
        fs.readFileSync(filePath, 'utf8'),
        ts.ScriptTarget.Latest,
        /* setParentNodes */ true
      );

      index = {
        filePath,
        sourceFile,
        aliases: new Map(),
        interfaces: new Map(),
        imports: new Map(),
        reexports: [],
      };

      sourceFile.forEachChild((stmt) => {
        if (ts.isTypeAliasDeclaration(stmt)) {
          index.aliases.set(stmt.name.text, stmt);
        } else if (ts.isInterfaceDeclaration(stmt)) {
          index.interfaces.set(stmt.name.text, stmt);
        } else if (
          ts.isImportDeclaration(stmt) &&
          ts.isStringLiteral(stmt.moduleSpecifier)
        ) {
          const specifier = stmt.moduleSpecifier.text;
          const { importClause } = stmt;
          if (importClause?.name) {
            index.imports.set(importClause.name.text, specifier);
          }
          const named = importClause?.namedBindings;
          if (named && ts.isNamedImports(named)) {
            for (const element of named.elements) {
              index.imports.set(element.name.text, specifier);
            }
          }
        } else if (
          ts.isExportDeclaration(stmt) &&
          stmt.moduleSpecifier &&
          ts.isStringLiteral(stmt.moduleSpecifier)
        ) {
          const specifier = stmt.moduleSpecifier.text;
          const names =
            stmt.exportClause && ts.isNamedExports(stmt.exportClause)
              ? new Map(
                  stmt.exportClause.elements.map((element) => [
                    element.name.text,
                    (element.propertyName || element.name).text,
                  ])
                )
              : undefined;
          index.reexports.push({ specifier, names });
        }
      });
    } catch {
      index = undefined;
    }

    this.files.set(filePath, index);
    return index;
  }

  /** Resolve a relative module specifier to the `.d.ts` file it points at. */
  resolveSpecifier(index, specifier) {
    if (!specifier || !specifier.startsWith('.')) {
      return undefined;
    }

    const base = path.resolve(path.dirname(index.filePath), specifier);
    for (const candidate of [
      `${base}.d.ts`,
      path.join(base, 'index.d.ts'),
      base,
    ]) {
      if (fs.existsSync(candidate) && fs.statSync(candidate).isFile()) {
        return this.read(candidate);
      }
    }
    return undefined;
  }

  /**
   * Find the declaration `name` refers to, following relative imports and the
   * `export * from './x'` barrels the emitted declarations use.
   */
  lookup(index, name, seen = new Set()) {
    if (!index || seen.has(index.filePath)) {
      return undefined;
    }
    seen.add(index.filePath);

    if (index.interfaces.has(name)) {
      return { index, declaration: index.interfaces.get(name) };
    }
    if (index.aliases.has(name)) {
      return { index, declaration: index.aliases.get(name) };
    }

    const imported = this.resolveSpecifier(index, index.imports.get(name));
    const found = imported && this.lookup(imported, name, seen);
    if (found) {
      return found;
    }

    for (const reexport of index.reexports) {
      const source = reexport.names ? reexport.names.get(name) : name;
      if (!source) {
        continue;
      }
      const target = this.resolveSpecifier(index, reexport.specifier);
      const viaBarrel = target && this.lookup(target, source, seen);
      if (viaBarrel) {
        return viaBarrel;
      }
    }

    return undefined;
  }

  /**
   * Resolve a type node to `{ target, args }` when it (or an alias/intersection
   * of aliases) is a bound-args type, otherwise undefined.
   */
  boundArgsOf(typeNode, index, depth = 0) {
    if (!typeNode || depth > MAX_DEPTH) {
      return undefined;
    }

    // `WithBoundArgs<C, 'a'> & WithBoundArgs<C, 'b'>` — the same component with
    // its bound args declared one at a time.
    if (ts.isIntersectionTypeNode(typeNode)) {
      const parts = typeNode.types.map((t) =>
        this.boundArgsOf(t, index, depth + 1)
      );
      if (parts.some((part) => !part)) {
        return undefined;
      }
      const [first] = parts;
      const args = [];
      for (const part of parts) {
        if (part.target !== first.target) {
          return undefined;
        }
        for (const arg of part.args) {
          if (!args.includes(arg)) {
            args.push(arg);
          }
        }
      }
      return { target: first.target, args };
    }

    // `PopoverSignature['Blocks']['default'][0]['Content']`
    if (ts.isIndexedAccessTypeNode(typeNode)) {
      const resolved = this.resolveIndexedAccess(typeNode, index, depth + 1);
      return resolved
        ? this.boundArgsOf(resolved.node, resolved.index, depth + 1)
        : undefined;
    }

    if (!ts.isTypeReferenceNode(typeNode)) {
      return undefined;
    }

    const name = typeNode.typeName.getText();

    if (BOUND_ARG_HELPERS.has(name) && typeNode.typeArguments?.length) {
      return {
        target: friendlyComponentName(typeNode.typeArguments[0]),
        args: typeNode.typeArguments[1]
          ? boundArgNames(typeNode.typeArguments[1])
          : [],
      };
    }

    const found = this.lookup(index, name);
    if (found && ts.isTypeAliasDeclaration(found.declaration)) {
      return this.boundArgsOf(found.declaration.type, found.index, depth + 1);
    }

    return undefined;
  }

  /** Unwrap type references and aliases down to the node they name. */
  resolveNode(typeNode, index, depth = 0) {
    if (!typeNode || depth > MAX_DEPTH) {
      return undefined;
    }
    if (ts.isIndexedAccessTypeNode(typeNode)) {
      return this.resolveIndexedAccess(typeNode, index, depth + 1);
    }
    if (ts.isTypeReferenceNode(typeNode)) {
      const found = this.lookup(index, typeNode.typeName.getText());
      if (found && ts.isTypeAliasDeclaration(found.declaration)) {
        return this.resolveNode(found.declaration.type, found.index, depth + 1);
      }
      if (found) {
        return { node: found.declaration, index: found.index };
      }
    }
    return { node: typeNode, index };
  }

  /** Resolve `Foo['bar']` / `Foo[0]` to the type node it selects. */
  resolveIndexedAccess(typeNode, index, depth = 0) {
    if (depth > MAX_DEPTH) {
      return undefined;
    }

    const owner = this.resolveNode(typeNode.objectType, index, depth + 1);
    if (!owner) {
      return undefined;
    }

    const key = typeNode.indexType;
    if (!ts.isLiteralTypeNode(key)) {
      return undefined;
    }

    if (ts.isNumericLiteral(key.literal)) {
      if (!ts.isTupleTypeNode(owner.node)) {
        return undefined;
      }
      const element = owner.node.elements[Number(key.literal.text)];
      if (!element) {
        return undefined;
      }
      const elementType = ts.isNamedTupleMember(element)
        ? element.type
        : element;
      return { node: elementType, index: owner.index };
    }

    if (!ts.isStringLiteral(key.literal)) {
      return undefined;
    }

    const match = this.membersOf(owner.node, owner.index, depth + 1).find(
      (entry) => propertyName(entry.member) === key.literal.text
    );
    return match?.member.type
      ? this.resolveNode(match.member.type, match.index, depth + 1)
      : undefined;
  }

  /**
   * Resolve a type node to the property members it describes, following
   * interfaces, aliases, intersections and indexed access (`Sig['Blocks']`).
   *
   * @returns {Array<{member, index}>}
   */
  membersOf(typeNode, index, depth = 0) {
    if (!typeNode || depth > MAX_DEPTH) {
      return [];
    }

    if (ts.isTypeLiteralNode(typeNode) || ts.isInterfaceDeclaration(typeNode)) {
      return typeNode.members.map((member) => ({ member, index }));
    }

    if (ts.isIntersectionTypeNode(typeNode)) {
      return typeNode.types.flatMap((t) => this.membersOf(t, index, depth + 1));
    }

    if (ts.isIndexedAccessTypeNode(typeNode)) {
      const key =
        ts.isLiteralTypeNode(typeNode.indexType) &&
        ts.isStringLiteral(typeNode.indexType.literal)
          ? typeNode.indexType.literal.text
          : undefined;
      if (!key) {
        return [];
      }
      const owner = this.membersOf(typeNode.objectType, index, depth + 1);
      const match = owner.find((entry) => propertyName(entry.member) === key);
      return match
        ? this.membersOf(match.member.type, match.index, depth + 1)
        : [];
    }

    if (ts.isTypeReferenceNode(typeNode)) {
      const found = this.lookup(index, typeNode.typeName.getText());
      if (!found) {
        return [];
      }
      if (ts.isInterfaceDeclaration(found.declaration)) {
        return found.declaration.members.map((member) => ({
          member,
          index: found.index,
        }));
      }
      return this.membersOf(found.declaration.type, found.index, depth + 1);
    }

    return [];
  }
}

/**
 * @returns block name -> { raw, params, positional } for every block that yields
 * at least one bound component.
 */
function collectBlocks(blockMembers, declarations) {
  const blocks = new Map();

  for (const { member: blockMember, index } of blockMembers) {
    const blockName = propertyName(blockMember);
    const tuple = blockMember.type;

    if (!blockName || !tuple || !ts.isTupleTypeNode(tuple)) {
      continue;
    }

    const params = {};
    const positional = {};
    const replacements = [];
    let found = false;

    // A block param declared in another file (a named interface rather than an
    // inline literal) can't be spliced into the tuple's own source text.
    const inTuple = (node) =>
      node.getSourceFile() === tuple.getSourceFile() &&
      node.getStart() >= tuple.getStart() &&
      node.getEnd() <= tuple.getEnd();

    tuple.elements.forEach((element, position) => {
      const elementType = ts.isNamedTupleMember(element)
        ? element.type
        : element;

      const asBound = declarations.boundArgsOf(elementType, index);
      if (asBound) {
        found = true;
        positional[position] = formatBound(asBound);
        if (inTuple(elementType)) {
          replacements.push({
            start: elementType.getStart(),
            end: elementType.getEnd(),
            text: positional[position],
          });
        }
        return;
      }

      for (const entry of declarations.membersOf(elementType, index)) {
        const name = propertyName(entry.member);
        const bound =
          entry.member.type &&
          declarations.boundArgsOf(entry.member.type, entry.index);
        if (!name || !bound) {
          continue;
        }
        found = true;
        params[name] = formatBound(bound);
        if (inTuple(entry.member.type)) {
          replacements.push({
            start: entry.member.type.getStart(),
            end: entry.member.type.getEnd(),
            text: params[name],
          });
        }
      }
    });

    if (found) {
      blocks.set(blockName, {
        raw: replacements.length
          ? printWithReplacements(tuple, replacements)
          : undefined,
        params,
        positional,
      });
    }
  }

  return blocks;
}

/** @returns arg name -> rendered bound-args type, for args that have one. */
function collectArgs(argMembers, declarations) {
  const args = new Map();

  for (const { member, index } of argMembers) {
    const name = propertyName(member);
    const bound = member.type && declarations.boundArgsOf(member.type, index);
    if (name && bound) {
      args.set(name, formatBound(bound));
    }
  }

  return args;
}

/** Find the `Signature` type node for a component declared at the top level. */
function componentSignatureNode(stmt) {
  if (ts.isClassDeclaration(stmt) && stmt.name) {
    const signature = stmt.heritageClauses?.[0]?.types?.[0]?.typeArguments?.[0];
    return signature ? { name: stmt.name.text, signature } : undefined;
  }

  if (ts.isVariableStatement(stmt)) {
    for (const declaration of stmt.declarationList.declarations) {
      const { type } = declaration;
      if (
        type &&
        ts.isTypeReferenceNode(type) &&
        type.typeName.getText() === 'TOC' &&
        type.typeArguments?.length &&
        ts.isIdentifier(declaration.name)
      ) {
        return {
          name: declaration.name.text,
          signature: type.typeArguments[0],
        };
      }
    }
  }

  return undefined;
}

/**
 * Build a `relative file name -> component name -> block name` lookup of the
 * bound-args block params declared in `filePaths`.
 */
function collectBoundArgs(filePaths, root) {
  const declarations = new Declarations();
  const byFile = new Map();

  for (const filePath of filePaths) {
    const index = declarations.read(filePath);
    if (!index) {
      continue;
    }

    const components = new Map();

    index.sourceFile.forEachChild((stmt) => {
      const found = componentSignatureNode(stmt);
      if (!found) {
        return;
      }

      const signatureMembers = declarations.membersOf(found.signature, index);
      const memberNamed = (name) => {
        const entry = signatureMembers.find(
          (candidate) => propertyName(candidate.member) === name
        );
        return entry?.member.type
          ? declarations.membersOf(entry.member.type, entry.index)
          : [];
      };

      const blocks = collectBlocks(memberNamed('Blocks'), declarations);
      const args = collectArgs(memberNamed('Args'), declarations);

      if (blocks.size > 0 || args.size > 0) {
        components.set(found.name, { blocks, args });
      }
    });

    if (components.size > 0) {
      byFile.set(path.relative(root, filePath), components);
    }
  }

  return byFile;
}

/** Escape a property name for use in a regular expression. */
function escapeRegExp(text) {
  return text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

/** Rewrite a parsed component's Args and Blocks in place using the collected lookup. */
function applyBoundArgs(component, byFile) {
  const entry = byFile.get(component.fileName)?.get(component.name);
  if (!entry) {
    return;
  }

  const { blocks, args } = entry;

  for (const arg of component.Args) {
    const rendered = args.get(arg.identifier);
    if (rendered) {
      arg.type = { type: rendered };
    }
  }

  for (const block of component.Blocks) {
    const info = blocks.get(block.identifier);
    if (!info) {
      continue;
    }

    if (info.raw) {
      block.type.raw = info.raw;
    } else if (block.type.raw) {
      // Params resolved from another file: patch the checker's rendering instead.
      for (const [name, rendered] of Object.entries(info.params)) {
        block.type.raw = block.type.raw.replace(
          new RegExp(`\\b${escapeRegExp(name)}: never\\b`, 'g'),
          `${name}: ${rendered}`
        );
      }
    }

    (block.type.items || []).forEach((item, position) => {
      if (info.positional[position]) {
        item.type = { type: info.positional[position] };
        return;
      }

      (item.type.items || []).forEach((param) => {
        const rendered = info.params[param.identifier];
        if (rendered) {
          param.type = { type: rendered };
        }
      });
    });
  }
}

module.exports = { collectBoundArgs, applyBoundArgs };
