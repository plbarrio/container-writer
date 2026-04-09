 # Roadmap

## Planned

### Wrapping mode per whitelist entry

Allow choosing between environment and command form per entry, for all formats,
with separate control for Div and Span elements:

| Mode      | Applies to | LaTeX                         | ConTeXt                    | Typst          |
|-----------|------------|-------------------------------|----------------------------|----------------|
| `\divenv` | Div        | `\begin{env}...\end{env}`     | `\startenv...\stopenv`     | `#block[...] <env>` |
| `\divcmd` | Div        | `\env{...}`                   | `\env{...}`                | `#env[...]`    |
| `\spanenv`| Span       | `\begin{env}...\end{env}`     | `\startenv...\stopenv`     | `#env[...]`    |
| `\spancmd`| Span       | `\env{...}`                   | `\env{...}`                | `#env[...]`    |

Current defaults: Div → `\divenv`, Span → `\spancmd`.

```yaml
container-writer:
  common:
    - epigraph: \divenv   # explicit default
    - marginnote: \spancmd
  latex:
    - dedication: \divcmd # \dedication{...} instead of \begin{dedication}
```

`\divenv`, `\divcmd`, `\spanenv`, `\spancmd` are reserved values and cannot
be used as remap targets.

### Refactor `wrap_element` as a format/mode dispatch table

Replace the current `if FORMAT == 'latex' ... elseif FORMAT == 'context'`
chain with a template table, making the code easier to extend and reason about:

```lua
local templates = {
  latex   = { env = {'\\begin{%s}', '\\end{%s}'}, cmd = {'\\%s{',   '}'   } },
  context = { env = {'\\start%s',   '\\stop%s' }, cmd = {'\\%s{',   '}'   } },
  typst   = { env = {'#block[',     '] <%s>'   }, cmd = {'#%s[',    ']'   } },
}
```

This is a prerequisite for clean support of new output formats.
