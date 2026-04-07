// ============================================================
// demo.typ — Typst styles for the container-writer demo
// ============================================================

#set text(
  font: ("Baskervville", "TeX Gyre Pagella", "Libertinus Serif"),
  size: 11pt
)

#set page(
  paper: "a5",
  margin: (top: 2cm, bottom: 2cm, left: 2.5cm, right: 2.5cm)
)

// --- Existing containers ------------------------------------

#show <epigraph>: it => block(
  width: 100%,
  inset: (left: 4em, right: 4em, y: 1em),
  text(style: "italic", fill: luma(80), it)
)

#show <dedication>: it => block(
  width: 100%,
  inset: (y: 2em),
  align(center, text(style: "italic", it))
)

#show <abstract>: it => block(
  width: 100%,
  inset: (left: 1em, y: 0.5em),
  stroke: (left: 2pt + luma(180)),
  text(size: 0.95em, it)
)

// --- Alerts -------------------------------------------------

#let alert-colors = (
  note: rgb("#0969da")
)
#let alert-labels = (
  note: "Note"
)

#let make-alert(kind) = it => {
  show <title>: _ => []
  let color = alert-colors.at(kind)
  let label = alert-labels.at(kind)

  block(
    width: 100%,
    radius: 4pt,
    stroke: 0.5pt + color,
    clip: true,
  )[
    #grid(
      columns: (3pt, 1fr),
    )[
      // Barra izquierda
      #block(fill: color, height: auto, width: 3pt)[]
    ][
      // Contenido
      #block(inset: (left: 8pt, right: 8pt, top: 8pt, bottom: 8pt))[
        #text(weight: "bold", fill: color, size: 0.85em)[
          #box(
            stroke: 0.5pt + color,
            radius: 50%,
            inset: (x: 3pt, y: 1pt),
          )[#text(size: 0.75em)[i]]
          #h(0.4em)
          #label
        ]
        #v(0.3em)
        #it
      ]
    ]
  ]
}

#show <note>: make-alert("note")
// --- Editorial margin notes ---------------------------------

#show <marginnoteopen>: it => place(
  right,
  text(size: 0.8em, fill: rgb("#e06c00"), [✎ ] + it)
)

#show <marginnoteclosed>: it => place(
  right,
  text(size: 0.8em, fill: luma(160), [✓ ] + it)
)

#show <marginnoteopenblock>: it => place(
  right,
  text(size: 0.8em, fill: rgb("#e06c00"), [✎ ] + it)
)

#show <marginnoteclosedblock>: it => place(
  right,
  text(size: 0.8em, fill: luma(160), [✓ ] + it)
)
