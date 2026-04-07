---
title: "container-writer — demo"
container-writer:
  common:
    - epigraph
    - dedication
    - sidebar
    - note
    - note.title
    - marginnoteopen
    - marginnoteclosed
    - marginnoteopenblock
    - marginnoteclosedblock
  latex:
    - abstract
    - note.title: notetitle
  typst:
    - abstract
  context:
    - abstract
container-strip:
  - marginnoteopen
  - marginnoteclosed
  - marginnoteopenblock
  - marginnoteclosedblock
---

# Block containers (Div)

## Epigraph

::: epigraph
*The world is a book, and those who do not travel read only one page.*

— Saint Augustine
:::

## Dedication

::: dedication
For all who write in the margins.
:::

## Abstract

::: abstract
This document demonstrates the container-writer filter, which translates
generic Div and Span elements into format-native environments for LaTeX,
ConTeXt, Typst and HTML.
:::

---

# Inline containers (Span)

A paragraph with a [marginal note]{.sidebar} inserted inline.

Another paragraph with a [second note]{.sidebar} further along.

---

# Per-block override

The **env=** attribute overrides the environment name for a specific block:

::: {.epigraph env=myepigraph}
This block uses a custom environment name via `env=`.
:::

---

# Nested styles (parent.child)

A container can have a titled child — both whitelisted independently.
The `note.title` entry wraps the title in its own environment:

::: note
::: title
Note
:::
The title above is wrapped in its own environment via the `note.title`
whitelist entry — useful for applying distinct formatting to the label.
:::

---

# Remapping (LaTeX only)

The `note.title: notetitle` entry in the `latex:` whitelist remaps the
`note.title` class to a different environment name in LaTeX output only.
Other formats use the default `title` name:

::: note
::: title
Note
:::
In LaTeX this title renders as `\begin{notetitle}` instead of
`\begin{title}` — useful when your preamble defines format-specific
environment names.
:::

---

# Whitelist — unknown containers pass through

This block is **not** in the whitelist and passes through unchanged:

::: unknown
This div has no matching whitelist entry.
:::

---

# Editorial margin notes

Margin notes are inline annotations for authors and editors. They are
visible in review builds and stripped in production by removing the classes
from the whitelist — no changes to the source files are needed.

## Inline (Span)

A short open note sits [this argument needs a citation]{.marginnoteopen}
right next to the text it refers to.

A resolved note looks [checked against sources — ok]{.marginnoteclosed}
different so you can see at a glance what still needs attention.

## Block (Div)

For longer annotations a fenced Div works better:

::: marginnoteopenblock
This section feels rushed. Consider splitting into two paragraphs and adding a transitional sentence.
:::

::: marginnoteclosedblock
Reviewed by Joan on 2026-03-15. Pacing addressed in rev2.
:::
