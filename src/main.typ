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

#let cline(width: 1fr) = box(baseline: -12pt, height: 7pt, width: width, fill: PRIMARY_COLOR)
#let titlefmt(t) = block(inset: 0pt, text(weight: "black", size: 50pt, [#cline(width: 1cm) #t #cline()]))

#let sl(body, title: none, footer: true, inset: 0.5cm) = {
  let contents = [
    #if title != none [
      #titlefmt(title)
      #v(-inset)
    ]
    #block(inset: inset, fill: SECONDARY_COLOR,  height: 1fr, width: 100%, body)
  ]

  if footer [
    #slide(contents)
  ] else [
    #_nofooter_sl(contents)
  ]
}

#let script(t, ..kwargs) = text(font: "Empyrean", ..kwargs, t)

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
          #script(size: 95pt, fill: PRIMARY_COLOR)[crowns]
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

#sl(title: [A dark star])[
]

#sl(title: "Outline")[
  #grid(
      columns: (35%, 1fr),
      row-gutter: 1em,
      column-gutter: 2em,
      block(inset: 0.3cm)[
        #text(tracking: -2pt, size: 30pt)[
          #text(size: 40pt)[\1.]
          #text(size: 90pt, weight: "black")[Black holes]
        ]
      ],
      [
        #v(50pt)
        #set text(top-edge: "ascender")
        // maybe do this as a cold opening?
        0. #strike[A #script(size: 28pt)[dark star]] // what they are, why interesting to study
        1. #hl[General relativistic ray-tracing]
          - The basic ideas
          - Our numerical methods and techniques // auto-diff
        2. Toy accretion models // luminet's figure
        3. _Modelling_ #hl[spectral processes]
          // - What we see in nature
          // here i talk about the iron line profiles
          // but then start to introduce the time variability things
          //
      ],
      block(inset: 0.3cm)[
        #text(tracking: -2pt, size: 30pt)[
          #text(size: 40pt)[\2.]
          #script(size: 95pt, fill: PRIMARY_COLOR)[crowns]
        ]
      ],
      [
        #v(50pt)
        #set text(top-edge: "ascender")
        1. The black hole #hl[X-ray #script(size: 28pt)[corona]]
        2. Reverberation lags & the #hl[lamppost model]
          // here talk about timescales probing different regions
        3. Triumphs & contests
          // success in fitting the 1 Zwicky 1 (Wilkins et al. 2021)
          // De Marco et al. 2012, how lag correlates with black hole mass
          // Kara et al. 2016: same thing for iron line
          // polarisation results
          - A need for geometrically extended models
        4. A problem of compute...
          - ... and how to #hl[solve it].
      ]
  )
]
