#set text(font: ("Baskervville", "TeX Gyre Pagella", "Libertinus Serif"), size: 11pt)

#set page(
  paper: "a5",
  margin: (top: 2cm, bottom: 2cm, left: 2.5cm, right: 2.5cm)
)

#show <verse>: it => block(
  width: 100%,
  above: 1em,
  below: 1.5em,
  breakable: true,
  pad(left: 2em, right: 2em, {
    set par(leading: 0.65em, spacing: 1.2em)
    pad(left: 1.5em, it)
  })
)

#show <poemtitle>: it => {
  v(2em)
  block(
    width: 100%,
    align(center)[#text(weight: "bold", size: 1.4em)[#it]]
  )
  v(0.8em)
}

#show <poemauthor>: it => block(
  width: 100%,
  above: 0.8em,
  below: 1.5em,
  align(right)[#text(style: "italic", size: 0.95em)[#it]]
)
