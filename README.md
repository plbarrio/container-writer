# container-writer.lua / container-strip.lua / container-unwrap.lua

[![test](https://github.com/plbarrio/container-writer/actions/workflows/test.yml/badge.svg)](https://github.com/plbarrio/container-writer/actions/workflows/test.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Pandoc](https://img.shields.io/badge/pandoc-%3E%3D2.19.1-orange)](https://pandoc.org)
[![Quarto](https://img.shields.io/badge/quarto-%3E%3D1.4.0-blue)](https://quarto.org)

Three companion Pandoc Lua filters:

- `container-writer.lua` — translates generic `Div` and `Span` containers into format-native environments for LaTeX, ConTeXt, Typst, and passthrough for HTML/EPUB.
- `container-strip.lua` — removes `Div` and `Span` elements by class, content and all, for stripping editorial annotations in production builds.
- `container-unwrap.lua` — removes `Div` and `Span` container elements while preserving their content. Useful as a post-processing step after `container-writer.lua` to neutralise elements that were not in the whitelist.

Copyright 2026 Pedro Luis Barrio under GPL-3.0-or-later, see LICENSE file for details.

Maintained by [plbarrio](https://github.com/plbarrio).

## Requirements

Pandoc >= 2.19.1 · Quarto >= 1.4.0 (for Quarto usage)

## Usage

### Plain Pandoc

```sh
pandoc --lua-filter=container-writer.lua input.md -o output.pdf
```

### Quarto

Declare in `_quarto.yml`:

```yaml
filters:
  - container-writer.lua
```

## How it works

Pandoc renders `Div` and `Span` elements with CSS classes natively in
HTML/EPUB. In other formats they are invisible — content is emitted but
without any wrapping. This filter bridges that gap by wrapping whitelisted
containers in the appropriate format command.

| Element | LaTeX                         | ConTeXt                    | Typst             | HTML/EPUB |
|---------|-------------------------------|----------------------------|-------------------|-----------|
| `Div`   | `\begin{name}`...`\end{name}` | `\startname`...`\stopname` | `#block[...] <name>` | unchanged |
| `Span`  | `\name{...}`                  | `\name{...}`               | `#[...] <name>`      | unchanged |


The effective whitelist for a given format is `common` + the FORMAT-specific
list. Containers not in the whitelist are left untouched.

Both `common` and format-specific keys accept a scalar for a single entry
or a list for multiple entries:

```yaml
container-writer:
  common: epigraph

container-writer:
  common:
    - epigraph
    - note
```

Only whitelisted names are processed — unknown containers never cause errors
in the output format.

### Parent.child entries

Compound entries (`parent.child`) control how nested elements are wrapped.
When a `Div` or `Span` with class `parent` is visited, its children matching
class `child` are wrapped using the child's own class name as environment —
mirroring the AST directly:

```yaml
container-writer:
  common:
    - note
    - note.title    # Div.title inside Div.note → \begin{title}
```

In HTML/EPUB children are left as-is — rendered natively by Pandoc, styled
via CSS descendant selectors (`.note .title { ... }`).
In Typst and ConTeXt the child style can be scoped inside the parent rule.
In LaTeX `\begin{title}` is global — use the remap syntax to give it a
per-context name.

### Remap entries

A compound entry can remap the child's environment name for specific formats:

```yaml
container-writer:
  common:
    - note
    - note.title          # HTML/EPUB: uses class name 'title'
  latex:
    - note.title: notetitle   # LaTeX: uses 'notetitle' instead
  context:
    - note.title: notetitle   # ConTeXt: uses 'notetitle' instead
```

This lets CSS use `.note .title` naturally while LaTeX/ConTeXt use
`\begin{notetitle}` / `\startnotetitle` — fully per-context, no global
namespace collision.

Remap is also useful to avoid conflicts with existing LaTeX environments.
If a class name collides with an environment already defined by your document
class or a package, remap it to a different name without changing your source:

```yaml
container-writer:
  latex:
    - dedication: mydedication   # avoids collision with existing \dedication
```

Then define `mydedication` in your preamble instead of `dedication`.

If the parent is not in the whitelist but `parent.child` is, the parent
passes through unwrapped while its matching children are still processed.

Chains are supported: `note.title.icon` — each level uses its own class name.

## Markdown syntax

```markdown
::: epigraph
Content of the epigraph block.
:::

A paragraph with [an inline span]{.sidebar} inside.
```

### Per-block override

Use the `env` or `environment` attribute to override the environment name
for a specific block, provided the name is in the whitelist:

```markdown
::: {.epigraph env=myepigraph}
Content.
:::
```

## Output examples

### LaTeX

```latex
\begin{epigraph}
Content of the epigraph block.
\end{epigraph}

A paragraph with \sidebar{an inline span} inside.
```

### ConTeXt

```context
\startepigraph
Content of the epigraph block.
\stopepigraph

A paragraph with \sidebar{an inline span} inside.
```

### Typst

```typst
#block[
Content of the epigraph block.
] <epigraph>

A paragraph with #[an inline span] <sidebar> inside.
```

### HTML

```html
<div class="epigraph">
  <p>Content of the epigraph block.</p>
</div>

<p>A paragraph with <span class="sidebar">an inline span</span> inside.</p>
```

---

## Usage examples

### Editorial margin notes

A practical case for review workflows: annotations visible in draft builds,
removed entirely in production by `container-strip.lua` — no changes to
source files needed.

```markdown
[this scene needs more tension]{.marginnoteopen}
[checked against sources]{.marginnoteclosed}

::: marginnoteopenblock
Longer note spanning multiple lines.
:::
```

Review build:
```sh
pandoc --lua-filter=container-writer.lua input.md -o draft.pdf
```

Production build:
```sh
pandoc --lua-filter=container-strip.lua \
       --lua-filter=container-writer.lua \
       input.md -o final.pdf
```

```yaml
container-strip:
  - marginnoteopen
  - marginnoteclosed
  - marginnoteopenblock
  - marginnoteclosedblock
```

Style files: `notes.tex`, `notes.ctx`, `notes.typ`, `notes.css`.


### Using existing LaTeX packages without writing LaTeX

A whitelisted class name that matches an environment defined by a LaTeX package works out of the box — no `\newenvironment` needed in your preamble, no raw LaTeX in your source files.

markdown

```markdown
::: verse
Shall I compare thee to a summer's day?\
Thou art more lovely and more temperate.
:::
```

yaml

```yaml
container-writer:
  common:
    - verse
```

latex

```latex
\usepackage{verse}
```

The filter emits `\begin{verse}...\end{verse}` and the package provides the implementation. Your source stays pure Markdown across all output formats — ConTeXt, Typst and HTML use their own definitions independently.

---

## Typst templates

Labels allow `#show` rules to target the containers:

```typst
#show <epigraph>: it => block(
  inset: (left: 2em, right: 2em),
  above: 1em,
  below: 1em,
  text(style: "italic", it)
)
```

## LaTeX setup

Define the environments in your preamble or template:

```latex
\usepackage{epigraph}
% or define manually:
\newenvironment{epigraph}{\begin{quote}\itshape}{\end{quote}}
```

## ConTeXt setup

```context
\definestartstop[epigraph]
  [before={\blank\startnarrow},
   after={\stopnarrow\blank}]
```

## container-strip.lua

Removes `Div` and `Span` elements by class — content and all. Configure
with a separate YAML key. Accepts a scalar for a single class or a list:

```yaml
container-strip: marginnoteopen

container-strip:
  - marginnoteopen
  - marginnoteclosed
  - marginnoteopenblock
  - marginnoteclosedblock
```

```sh
pandoc --lua-filter=container-strip.lua \
       --lua-filter=container-writer.lua \
       input.md -o output.pdf
```

Note: `container-strip` must run **before** `container-writer` — if writer
runs first it converts spans to raw format commands that strip never sees.

---

## container-unwrap.lua

Removes `Div` and `Span` container elements while preserving their content.
Useful after `container-writer.lua` to neutralise elements not in the
whitelist that would otherwise render differently across Pandoc versions
(e.g. `#block[]` in Typst 3.9 vs nothing in 3.1).

Must run **after** `container-writer.lua` — the writer converts whitelisted
elements to raw format commands that unwrap never sees.

```sh
pandoc --lua-filter=container-writer.lua \
       --lua-filter=container-unwrap.lua \
       input.md -t typst
```

Accepts a scalar or a list. Two reserved keywords control bulk behaviour:

- `all` — unwrap every remaining `Div`/`Span` regardless of class
- `void` — unwrap elements that carry no class at all

```yaml
container-unwrap: all

container-unwrap: void

container-unwrap: sidebar

container-unwrap:
  - void
  - sidebar
  - note
```

## Known limitations

- A container name present in both `Div` and `Span` contexts uses the same
  environment name. If your format requires different names for block and
  inline, use the `env` attribute to override per block.
- `LineBlock` (`|`) inside a whitelisted `Div` is not processed by this filter.
- **Container names must be valid LaTeX/ConTeXt command names** — letters only,
  no hyphens, no leading digits. A name like `marginnote-open` produces
  `\marginnote-open{...}` in LaTeX where `-` is interpreted as subtraction,
  silently breaking the output. Use `marginnoteopen` or a short prefix like
  `mnopen` instead. CSS classes and Typst labels accept hyphens freely.
- **`container-strip` does not support compound entries** — blacklist entries
  are plain class names only. To strip `Div.title` inside `Div.note`, list
  `title` explicitly (strips all `.title` elements) or list the specific
  classes you want removed.

## Issues and contributing

Issues and PRs welcome at the [project repository](https://github.com/plbarrio/container-writer).

## License

GPL-3.0-or-later. See [LICENSE](LICENSE).

## References

- [Pandoc](https://pandoc.org) — universal document converter
- [Quarto](https://quarto.org) — open-source scientific publishing system
- [Lua](https://www.lua.org) — lightweight embeddable scripting language
- [Pandoc Lua filters](https://pandoc.org/lua-filters.html) — official documentation
- [Quarto extensions](https://quarto.org/docs/extensions/) — official documentation
