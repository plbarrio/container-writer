#set text(font: ("Baskervville", "TeX Gyre Pagella", "Libertinus Serif"), size: 11pt)

#set page(
  paper: "a5",
  margin: (top: 2cm, bottom: 2cm, left: 2.5cm, right: 2.5cm)
)

#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  v(2cm)
  it
}

#show <verse>: it => block(
  width: 100%,
  inset: (left: 2em, y: 1em), // Margen tipo LaTeX
  breakable: true,           // Fundamental para poemas largos
  {
    set par(hanging-indent: 1.5em, // El toque maestro del 'verse'
            spacing: 0.35em       ) // ← versos pegados
    it
  }
)


#show <poemtitle>: it => block(
  width: 100%,
  above: 1.5em,
  below: 1em,
  align(center)[#text(weight: "bold", size: 1.3em)[#it]]
)

#show <poemauthor>: it => block(
  width: 100%,
  above: 0.5em,
  align(right)[#emph(it)]
)

