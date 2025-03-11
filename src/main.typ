#import "@preview/polylux:0.4.0": *

#let HANDOUT_MODE = false
#enable-handout-mode(HANDOUT_MODE)

// colour configurations
#let SECONDARY_COLOR = rgb("#fafafa")
#let PRIMARY_COLOR = rgb("#be2b31")
#let TEXT_COLOR = black.lighten(13%)

// document general
#let location = "University of Bristol Seminar"
#let date = datetime(year: 2025, month: 3, day: 19)
#let datefmt = "[day] [month repr:long] [year]"

// utility functions
#let black(t, ..args) = text(weight: "black", t, ..args)
#let hl(t, ..args) = black(fill: PRIMARY_COLOR, ..args, t)

// page configuration
#set par(leading: 8pt)
#set text(size: 20pt, font: "Inter", fill: TEXT_COLOR)

#let seperator = [#h(10pt)/#h(10pt)]
#set page(paper: "presentation-4-3",
  margin: (top:0.4cm, left: 0.4cm, right: 0.4cm, bottom: 1.0cm),
  fill: SECONDARY_COLOR.darken(10%),
  footer: text(size: 12pt, [Fergus Baker #seperator CC BY-NC-SA 4.0 #seperator #date.display(datefmt) #h(1fr) #toolbox.slide-number])
)

// functions for drawing slides
#let _nofooter_sl(body) = [
  #set page(margin: 0.4cm, footer: none)
  #body
]

#let sl(body, title: none, footer: true, inset: 0.5cm) = {
  let contents = [
    #block(inset: inset, fill: SECONDARY_COLOR,  height: 100%, width: 100%, [
      #if title != none [
        #block(black(fill: PRIMARY_COLOR, size: 30pt, title))
      ]
      #body
    ])
  ]

  if footer [
    #slide(contents)
  ] else [
    #_nofooter_sl(contents)
  ]
}

// main body

#sl(footer: false, inset: 0.2cm)[
  #grid(
      columns: (65%, 1fr),
      column-gutter: 0.2cm,
      [
        #rect(fill: TEXT_COLOR, width: 100%, height:100%)
      ],
      block(inset: 0.3cm)[
        #text(tracking: -2pt, size: 30pt)[
          #set par(spacing: 0pt)
          #text(size: 90pt, weight: "black")[Black holes]\
          #v(10pt)
          #text(tracking: 0pt)[_and their_]
          #v(0pt)
          #text(size: 95pt, font: "Empyrean", fill: PRIMARY_COLOR)[crowns]
        ]

        #v(1fr)
        #text(fill: PRIMARY_COLOR)[*Fergus Baker*\ Andy Young]
        #set text(size: 16pt)
        #v(-0.2cm)
        Bristol Astrophysics Seminar #h(1fr)
        #v(-0.2cm)
        #date.display(datefmt)
      ]
  )

]
