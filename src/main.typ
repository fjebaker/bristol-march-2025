#import "@preview/polylux:0.4.0": *

#let HANDOUT_MODE = false
#enable-handout-mode(HANDOUT_MODE)

// colour configurations
#let SECONDARY_COLOR = rgb("#fafafa")
#let PRIMARY_COLOR = rgb("#be2b31")
#let TEXT_COLOR = black.lighten(13%)

// document general
#let location = "Bristol Astrophysics Seminar"
#let date = datetime(year: 2025, month: 3, day: 19)
#let datefmt = "[day] [month repr:long] [year]"

// utility functions
#let black(t, ..args) = text(weight: "black", t, ..args)
#let hl(t, ..args) = black(fill: PRIMARY_COLOR, ..args, t)

#let _setgrp(img, grp, display:true) = {
  let key = "id=\"" + grp + "\""
  let pos1 = img.split(key)
  if display {
    pos1.at(1) = pos1.at(1).replace("display:none", "display:inline", count:1)
  } else {
    pos1.at(1) = pos1.at(1).replace("display:inline", "display:none", count:1)
  }
  pos1.join(key)
}

#let setgrp(img, ..grps, display: true) = {
  grps.pos().fold(img, (acc, grp) => {
    _setgrp(acc, grp, display: display)
  })
}

#let animsvg(img, display_callback, ..frames, handout: false) = {
  let _frame_wrapper(_img, hide: (), display: ()) = {
    setgrp((setgrp(_img, ..hide, display: false)), ..display, display: true)
  }
  if handout == true {
    let final_image = frames.pos().fold(img, (im, args) => _frame_wrapper(im, ..args))
    display_callback(1, final_image)
  } else {
    let output = ()
    let current_image = img
    for args in frames.pos().enumerate() {
      let (i, frame) = args
      current_image = _frame_wrapper(
        current_image, ..frame
      )
      let this = display_callback(i + 1, current_image)
      output.push(this)
    }
    output.join()
  }
}

#let only-last-handout(..blocks, fig: false, handout: false, fig-num: 1) = {
  if handout == true {
    blocks.at(-1)
  } else {
    let output = ()
    context {
      counter(figure).update(fig-num)
      for blk in blocks.pos().enumerate() {
         let (i, b) = blk
         [
           #only(i+1, b)
         ]
      }
    }
    output.join()
  }
}

// page configuration
#set par(leading: 8pt)
#set text(size: 20pt, font: "Inter", fill: TEXT_COLOR)
#show raw.where(block: true): c => block(stroke: 1pt, inset: 7pt, radius: 1pt, fill: white, text(size: 12pt, c))

#let seperator = [#h(10pt)/#h(10pt)]
#set page(paper: "presentation-4-3",
  margin: (top:0.4cm, left: 0.4cm, right: 0.4cm, bottom: 1.0cm),
  fill: SECONDARY_COLOR.darken(10%),
  footer: text(size: 12pt, [Fergus Baker #seperator CC BY-NC-SA 4.0 #seperator #location #seperator #date.display(datefmt) #h(1fr) #toolbox.slide-number])
)

// functions for drawing slides
#let _nofooter_sl(body) = [
  #set page(margin: 0.4cm, footer: none)
  #body
]

#let cline(width: 1fr) = box(baseline: -12pt, height: 7pt, width: width, fill: PRIMARY_COLOR)
#let titlefmt(t) = block(inset: 0pt, text(tracking: -2pt, weight: "bold", size: 50pt, [#cline(width: 1cm) #t #cline()]))

#let sl(body, title: none, footer: true, inset: 0.5cm) = {
  let contents = [
    #if title != none [
      #titlefmt(title)
      #v(-inset + 0.2cm)
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
        #block(inset: 0.5cm, fill: TEXT_COLOR, width: 100%, height:100%)[
          #align(bottom, image("figs/black-hole-and-its-crown.png"))
        ]
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
        #v(-0.4cm)
        #image("figs/bristol-logo.svg", height: 2cm)
        #set text(size: 16pt)
        #v(-0.2cm)
        #location #h(1fr)
        #v(-0.2cm)
        #date.display(datefmt)
      ]
  )
]

#sl(title: [A dark star])[
  #uncover("2-")[ #hl[Olaüs Roemer] (1676): speed of light known to be $~ 3 times 10^8 " m s"^(-1)$ ]
  \
  #uncover("3-")[#hl[Newtonian Gravity] (1687): escape velocity, $v_"esc" = sqrt((2 G M) \/ r).$]

  #v(1cm)
  #uncover("4-")[Reverend #hl[John Michell] (1783):
  #block(inset: (left: 1cm), text(font: "Vollkorn", size: 18pt, quote[[...] a body falling from an infinite height towards it, would have acquired at its surface a greater velocity than that of light, and consequently supposing light to be attracted by the same force in proportion to its _vis inertiae_ with other bodies, #hl[all light emitted from such a body would be made to return towards it], by its own proper gravity.]))
  ]

  #v(1cm)
  #uncover("5-")[#hl[Albert Einstein] (1915): General Theory of Relativity \ ]
  #uncover("6-")[#hl[Karl Schwarzschild] (1915): spherically symmetric vacuum solution \ ]
  #uncover("7-")[#hl[Jocelyn Bell Burnell] (1967): discovery of radio pulsars, used to prove existence of neutron stars. \
]
  #uncover("8-")[#hl[John Wheeler] (1967): coins the term "#hl[black hole]" during a lecture. \
]
  #uncover("9-")[#hl[Tom Bolton] (1972): discovers Cygnus X-1 orbits an invisible partner \
]
]

#sl(title: "A bright star")[
  #grid(columns: (55%, 1fr),
    [
      Today (for EM astronomers), generally consider #hl[two types] of black holes:
      - Active Galactic Nuclei (#hl[AGN])
      - Black hole binaries (#hl[BHB])

    #uncover("2-")[
    Except for two notable exceptions, #hl[cannot resolve the systems]
    - Characteristic scale is $r_g = (G M) / c^2$, so for 1\" at 1pc would need $10^9 M_dot.circle$
    - M87\* is $10^9 M_dot.circle$ but at $D approx$ 16 Mpc
    - Closest is Gaia BH1 at \~ 470 pc and \~ 1 $M_dot.circle$
    ]

    #v(2cm)
    #uncover("3-")[
    Today: ideas apply to #hl[any black hole] \
    #text(size: 15pt)[(not enough time to go into discriminating details)]
    - Consider mainly #hl['simple' models]
    - Looking at #hl[innermost regions] of the accretion black hole
    ]
    ],
    [
      #set align(center)
      #set text(size: 11pt)
      #move(
          image("./figs/NGC4151_Galaxy_from_the_Mount_Lemmon_SkyCenter_Schulman_Telescope_courtesy_Adam_Block.jpg", width: 160pt),
      )
      #text()[NGC4151 by #link("https://en.wikipedia.org/wiki/NGC_4151#/media/File:NGC4151_Galaxy_from_the_Mount_Lemmon_SkyCenter_Schulman_Telescope_courtesy_Adam_Block.jpg")[Adam Block/Mount Lemmon SkyCenter/\ University of Arizona], CC BY-SA 4.0],
      #move(
          image("./figs/Gaia_BH1_PanSTARRS.jpg", width: 160pt),
      )
      #text()[Gaia BH1 by #link("https://en.wikipedia.org/wiki/Gaia_BH1#/media/File:Gaia_BH1_PanSTARRS.jpg")[Meli thev], CC BY-SA 4.0]
    ]
  )
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
        #v(20pt)
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
        #v(20pt)
        #set text(top-edge: "ascender")
        1. The black hole #hl[X-ray #script(size: 28pt)[corona]]
        2. Reverberation lags & the #hl[lamppost model]
          // here talk about timescales probing different regions
        3. Triumphs & contests
          - Motivating geometrically extended models
        4. A problem of compute...
          - ... and how to #hl[solve it].
      ]
  )
]

#sl(title: "Ray-tracing")[
  #image("figs/albrecht-durer.jpg")
  #v(-0.5cm)
  #align(center, text(size: 12pt)[Woodcut of Jacob de Keyser's invention by #hl[Albrecht Dürer] (public domain)])

  #v(0.5cm)
  Ray-tracing is the technique of #hl[projecting the appearance] of geometry.
  - Today, synonymous with tracing #hl[photons] through a scene
  - Ubiquitous in #hl[computer graphics]
  - Used extensively for #hl[scientific purposes]
]

#sl(title: "Curved space")[
    #let red(c) = text(fill: PRIMARY_COLOR, c)
    #grid(
        columns: (65%, 1fr),
        [
          #hl[Curvature] is a property of #hl[space _and_ time] _generated_ by #hl[matter _and_ motion].

          #uncover("4-")[Formulated using #hl[Riemannian geometry]:
          - Trajectory of all things follow #hl[geodesics]
          - In curved space, #hl[not straight lines]
          ]
          #uncover("5-")[
          $
            (partial^2 x^mu) / (partial tau^2) &= - Gamma^mu_(nu sigma) (partial x^nu) / (partial tau) (partial x^sigma) / (partial tau), \
            #uncover("6-")[$#red[$m underbrace(#text(fill: TEXT_COLOR, $(partial^2 x^mu) / (partial tau^2)$), a)$] &= #red[$F$].$]
          $
          ]
        ],
        [
          #uncover("2-")[#align(center, image("figs/embedding.svg", width: 70%))]
          #v(-1cm)
          #uncover("3-")[#image("figs/curved-space.svg")]
        ]
    )

    #uncover("7-")[#hl[Curvature] acts as to impart a force, which we call #hl[gravity].]

    #uncover("8-")[Geodesic equation is coupled 2#super("nd") order #hl[ODEs]
    - Pick an initial #hl[position] and #hl[velocity] and integrate
    ]

    #uncover("9-")[#hl[Curvature terms], denoted $Gamma^mu_(nu sigma)$, are a function of the #hl[metric] _only_.]

    // Surface force of gravity $F \/ m = g prop M r^(-2)$, event horizon $r_s prop M$
    // - Changing $M$ will change $g prop M^(-1)$
    // - C.f. for a Newtonian star $g prop M^(1/3)$
    // - More massive black holes are friendlier

]

#sl(footer: false)[
  #v(3cm)
  The #hl[Kerr family] of black hole solutions:
  #v(-3cm)
  #text(size: 120pt)[
    $ g_(mu nu) (#hl[$M$], #hl[$a$]) $
  ]
  #v(-3cm)
  #text(font: "Vollkorn", quote[The black holes of nature are the most #hl[perfect
  macroscopic objects] in the universe [...]. And since the
  general theory of relativity provides only a single unique
  family of solutions [...], they are the #hl[simplest objects] as
  well.])
  #align(right)[
    -- S. Chandrasekhar
    #v(-0.9em)
    #text(size: 12pt)[ prologue to The Mathematical Theory of Black Holes ]
  ]
]

#sl(footer: false)[
  #set align(center)
  #v(2cm)
  #image("figs/luminet.png", width: 22cm)

  #hl[J-P. Luminet] (1978): Image of a spherical black hole with thin accretion disc
]


#sl(title: "Relativistic ray-tracing")[
  #grid(
      columns: (40%, 1fr),
      column-gutter: 0.5cm,
      [
      #uncover("2-")[
      ```julia
      using Gradus

      # 1. Flat space
      m = SphericalMetric()
      # 2. Schwarzschild
      m = KerrMetric(M = 1.0, a = 0.0)
      # 3. Kerr
      m = KerrMetric(M = 1.0, a = 1.0)

      # spherical 4-vector
      photon_origin = SVector(0, 1e4, π/2, 0)

      # impact parameter space
      α = collect(range(-10, 10, 20))
      β = fill!(similar(α), 0)

      vs = map_impact_parameters(
        m, photon_origin, α, β
      )

      geods = tracegeodesics(
        m,
        fill(photon_origin, size(vs)),
        vs,
        # maximum integration time
        2e4,
      )
      ```
      ]
      ],
      [
        #v(0.5cm)
        #align(center, animsvg(
          read("figs/gr-ray-tracing.svg"),
          (i, im) => only(i + 2)[
            #image.decode(im, width: 85%)
          ],
          (hide: ("g301",)),
          (display: ("g301",)),
          handout: HANDOUT_MODE,
        ))

        #uncover("4-")[Vertically #hl[stack slices] of different $beta$ to create an image.]
      ]
  )
]

#sl(footer: false)[
  #v(1cm)
  #align(center, image("figs/schwarzschild-shadow.png", height: 15cm))
]

#sl(title: "Shadow of a black hole")[
  #grid(
      columns: (30%, 45%, 1fr),
      column-gutter: 10pt,
      [
        ```julia
        pf = PointFunction(
          # get coordinate time
          (m, p, τ) -> p.x[1]
        )

        # utility function for
        # impact parameters
        α, β, img = rendergeodesics(
            m,
            photon_origin,
            2e4,
            image_width = 1000,
            image_height = 1000,
            pf = pf,
            αlims = (-6, 6),
            βlims = (-6, 6),
        )
        ```
      ],
      [
        #v(0.2cm)
        #image("figs/shadow.svg", width: 10cm)
        #set text(size: 14pt)
        Shadows of a #hl(fill: rgb(0, 114, 178))[Schwarzschild] and #hl(fill: rgb(204, 121, 167))[Kerr] black hole.
      ],
      [
        #set align(center)

        #v(1.5cm)
        #image("figs/eht-sgr-a.jpg", width: 5cm)
        #v(-0.3cm)
        #text(size: 11pt, [EHT image of Sgr A\*])

        #image("figs/eht-m87-image.jpg", width: 5cm)
        #v(-0.3cm)
        #text(size: 11pt, [EHT image of M87\*])
      ]

  )
  #v(-2cm)

  - Sgr A\*: $M_"BH" ~ 10^6 M_dot.circle, therefore r_"s" ~ 0.08 "AU"$
  - M87\*: $M_"BH" ~ 10^9 M_dot.circle, therefore r_"s" ~ 120 "AU"$

  #uncover("2-")[Many things are #hl[scale invariant]: $r_g = (G M) / c^2$, and use $G = c = 1$.]
]

#sl(title: "Toy accretion disc")[
    #let size = 17cm
    #align(center, image("figs/toy-accretion.svg", width: size))
    #uncover("2-")[#align(center, image("figs/toy-accretion-projected.svg", width: size))]
    #uncover("3-")[#align(center, image("figs/toy-accretion-render.png", width: size))]
]

#sl(title: "Redshift")[
  #grid(
      columns: (1fr, 50%),
      column-gutter: 0.5cm,
      [
        #uncover("4-")[#image("figs/redshift.png", width: 100%)]
        #v(-1cm)
        #uncover("5-")[#image("figs/redshift-profiles.svg", width: 90%)]
      ],
      [
        Key to relating #hl[emitted] and #hl[observed] quantities is the #hl[reciprocity theorem] (Liouville's theorem)
        $ I_"obs" (E_"obs") = g^3 I_"em" (E_"em"). $

        #uncover("2-")[Need to compute the #hl[redshift] of each geodesic
        $
          g := E_"obs" / E_"em" = (bold(u)_"obs" dot bold(k) |_"obs") / (bold(u)_"disc" dot bold(k) |_"disc").
        $
        Intuition is $E prop m v^2 = p v$.
        ]

        #v(0.5cm)
        #uncover("3-")[Sources of #hl[redshift]:
        - Doppler shift
        - Special relativistic beaming
        - Gravitational redshift
        ]
      ],
  )
]

#sl(title: "Observers")[
  The #hl[inclination] of the observer changes the #hl[redshift profile]:
  #v(1cm)
  #align(center, image("figs/redshift-observer.png", height: 12cm))
]

#sl(title: "Toy accretion models")[
  #grid(
      columns: (50%, 1fr),
      [
        A "simple" model for the #hl[radiated flux] (Page & Thorne, 1974):
        $
          F ~ angle.l q_z angle.r r^(-1) ~ r^(-3),
        $
        with Stefan-Boltzmann law,
        $
          T ~ (F / sigma_"B")^(1/4).
        $
        #uncover("4-")[#align(center, image("figs/page-and-thorne-flux.png", width: 11cm))]
      ],
      [
        #uncover("2-")[#align(center, image("figs/page-and-thorne-temperature.svg", width: 80%))]
        #v(-0.8cm)
        #uncover("3-")[#align(center, image("figs/temperature-maps.png", width: 80%))]
      ]
  )
  #set text(size: 18pt)
  #v(1fr)
  #uncover("3-")[These are the first steps to models like `kerrbb` (Li et al., 2005).]
]

#sl(footer: false)[
  #set align(center)
  #v(3cm)
  #image("figs/our-luminet.png", width: 22cm)

  #hl[After J-P. Luminet] (2025): Schwarzschild black hole with Page & Thorne temperature profile
]

#sl(title: "Broadening")[
  #grid(
      columns: (50%, 1fr),
      column-gutter: 0.8cm,
      [
        Going back to the #hl[reciprocity theorem]: $I_"obs" (E_"obs") = g^3 I_"em" (E_"em")$.
        #v(-0.2cm)
        #uncover("2-")[- Observed fluxes will be energetically #hl[broadened] or #hl[blurred],
          $
            F(E_"obs") = integral.double_(A) g^3 #text(fill: PRIMARY_COLOR)[$epsilon (r)$] I_"em" (E_"em") dif alpha dif beta,
          $
          with #hl[emissivity profile] term $epsilon (r)$. // how much flux is coming from different parts of the disc
        ]

        #uncover("3-")[#image("figs/building-line-profiles.svg", width: 15cm)]
        #v(-0.5cm)
        #uncover("5-")[Broad line can be used to measure #hl[spin] and #hl[inclination].]
      ],
      [
        #uncover("4-")[#hl[Green's functions]:
        - emission is a #hl[delta function]:
        #v(-0.5cm)
          $ epsilon I_"em" = r^(-3) delta (E - E_0) $
        #v(-1.0cm)
        ]
        #set align(center)
        #uncover("5-")[#image("figs/line-profiles.svg", width: 80%)]
      ]
  )

]

// #sl(title: "Making things fast")[
//   For #hl[spectral modelling], need to compute observed #hl[flux]
//   $
//     F(E_"obs") = integral_(r_"isco")^(r_"out") integral_0^1 g^3 I_"em" (E_"em") #text(fill: PRIMARY_COLOR)[$abs((partial (alpha, beta)) / (partial (r, g^ast)))$] dif r dif g^ast.
//   $
//   // Requires a lot of compute to solve ray tracing problems to high resolution
//   // - most of the calculations are for parts of the disc where nothing is happening
//   // - save an enormous amount of compute by recasting the problem

//   Cunningham transfer functions

//   Can then express #hl[physics of the disc] in the #hl[local frame]
// ]

#slide[
  #set page(fill: PRIMARY_COLOR)
  #v(3cm)
  #text(size: 80pt, weight: "black", fill: SECONDARY_COLOR, [\2. _The_ X-ray \ #script(fill: TEXT_COLOR, size: 290pt)[corona]])
]

#sl(title: "High energy X-rays")[
  #grid(
      columns: (46%, 1fr),
      column-gutter: 0.5cm,
      [
        #align(center, image("assets/spectral-components-zoghbi-2010.png", height: 9.5cm))
        #v(-0.5cm)
        #uncover("3-")[#align(center, image("assets/ixpe-polarimetry-measurements.png", height: 7cm))]
      ],
      [
        X-ray observations show #hl[three] principle components:
        - One is the corona: #hl[power law]
        - Two are related to the disc: #hl[blackbody], #hl[reflection] of the corona

        #uncover("2-")[#hl[Geometry] and #hl[conditions] of the corona are debated
        - Base of a jet? (Markoff et al., 2005)
        - Extended warm corona? (e.g. Paczynski 1978)
        - Composition of different models? (e.g. Wilkins et al., 2021)
        ]

        #uncover("3-")[Recent X-ray polarimetry measurements are #hl[disfavouring] compact or vertically extended models.]

        #uncover("4-")[Leading (computational) models use a #hl[compact, small source] near the BH.]
      ]
  )

  // irrespective of whether we are talking about XRB or AGN, the modelling is
  // approximately the same - one of the main differences are the expected
  // temperatures of the disc, which are hotter in XRB - peak in UV in AGN,
  // closer to soft X-ray in XRB
]

#sl(title: "The lamppost model")[
  // this is not in the chronological order of discovery, but i think in the
  // interest of pedagogy and understanding it is easier to introduce the
  // picture of the lamppost model now and to explain observation with this
  // model in mind
  // - i should be concrete: the geometry of the corona is unknown
  #grid(
      columns: (1fr, 56%),
      column-gutter: 0.5cm,
      [
        A single #hl[point-like] source on the spin-axis of the BH

        #hl[Direct] emission from the corona +
        #hl[reflected] emission from the disc

        #align(center, image("figs/lamppost-spectral.svg", width: 70%))

        #uncover("2-")[#hl[Both] are mixed and #hl[observed] in ensemble.]

        #uncover("3-")[Components can be #hl[modelled] independently.]
      ],
      [
        #v(1fr)
        #only-last-handout(fig-num: 37,
          image("figs/literal-lamppost.png", width: 95%),
          image("figs/literal-lamppost-magnifying.png", width: 95%),
          image("figs/literal-lamppost-magnifying.png", width: 95%),
          handout: HANDOUT_MODE
        )
        #align(center, text(size: 18pt)[
          A literal #hl[lamppost] model.
        ])
        #v(0.5cm)
      ],
  )
]

#sl(title: "Illuminating the disc")[
    #grid(
        columns: (70%, 1fr),
        column-gutter: 0.5cm,
        [
          #align(center, animsvg(
            read("figs/lamp-post-traces.svg"),
            (i, im) => only(i)[
              #image.decode(im, width: 80%)
            ],
            (hide: ("g572","g570","g571")),
            (display: ("g570",)),
            (display: ("g571",), hide: ("g570",)),
            (display: ("g572",), hide: ("g571",)),
            handout: HANDOUT_MODE,
          ))

          #align(center, animsvg(
            read("figs/lamp-post-emissivity-travel-time.svg"),
            (i, im) => only(i)[
              #image.decode(im, width: 100%)
            ],
            (hide: ("g389","g390","g391")),
            (display: ("g391",)),
            (display: ("g390",)),
            (display: ("g389",)),
            handout: HANDOUT_MODE,
          ))
        ],
        [
          #hl[Emissivity] is proportional to the #hl[illuminating flux]
          $
          epsilon &prop F_i, \
          &= N / (gamma tilde(A)) I,
          $
          #text(size: 16pt)[
          where
          - $N$ #hl[number] of photons,
          - $tilde(A)$ is GR corrected #hl[area],
          - $gamma$ is the Lorentz factor,
          - and $I$ is the coronal intensity $g^(1 - Gamma)$.
          ]

          #uncover("3-")[The #hl[geometry of the corona] changes the emissivity profile.]
        ]
    )
]

#sl(title: "Emissivity changes line shape")[
  #v(2.0cm)
  #align(center, image("figs/emissivity-changes-lineshape.svg", width: 21cm))

  The lineshape is a #hl[probe of geometry].

]

#sl(title: "Broad lines")[
  The #hl[reflection spectrum] is broadened by the #hl[lineprofile].

  - Includes the #hl[emissivity] from the coronal illumination.

  #grid(
      column-gutter: 1.0cm,
      columns: (57%, 1fr),
      [
        The reflection shows different line emissions and fluorescences:
        #align(left, image("figs/broad-lines.svg", width: 15.5cm))
      ],
      [
        // what's really cool about this line is it is basically a delta function
        // - can use it to see the shape of the lineprofiles directly
        Notable: #hl[Fe K$alpha$] at \~6.4 keV
        #align(center, image("figs/young-05.png", width: 8.5cm))
        #align(center, text(size: 10pt, [MCG 6-30-15 from Young et al. (2005)]))
      ]
  )

  Successfully used to #hl[measure spin] in $> 22$ AGN (Reynolds 2019).
]

#sl(title: "Reverberation lags")[
  #grid(
      columns: (50%, 1fr),
      [
        #align(center)[
          #animsvg(
            read("figs/reverberation-traces.svg"),
            (i, im) => only(i)[
              #image.decode(im, width: 100%)
            ],
            (),
            (hide: ("g75", "g49")),
            (hide: ("g1",)),
            (display: ("g5",)),
            (hide: ("g6", "g2"), display: ("g7",)),
            (display: ("g73", "g72", "g4")),
            (display: ("path63", "g3")),
            (),
            (),
            (),
            handout: HANDOUT_MODE,
          )
        ]
        #uncover("8-")[Simple #hl[reverberation] predicts #hl[soft lags], i.e. that the #hl[disc] responds #hl[after] the #hl[corona]]

        #uncover("9-")[We actually see #hl[hard] and #hl[soft] lags on different timescales.]

        #uncover("10-")[Likely different mechanism driving the different lags.]
      ],
      [
        #set align(center)
        #uncover("9-")[#image("assets/reverberation-time-scales-zoghbi-2010.png", width: 12cm)]
        #uncover("10-")[#image("assets/power-spectra-zoghbi-2011.png.png", width: 8cm)]
      ]
  )
]

#sl(title: "Transfer functions")[
  Modelling the #hl[soft lags]:
  #grid(
      columns: (50%, 1fr),
      column-gutter: 0.5cm,
      [
        #align(center, image("figs/2d-transfer-functions.png"))
        #uncover("2-")[#align(center, image("figs/2d-impulse-response.svg"))]
      ],
      [
        #v(-1.2cm)
        #uncover("3-")[#align(center, image("figs/lag-energy.svg", width: 11.5cm))]
        #v(-0.9cm)
        #uncover("4-")[#align(center, image("assets/lag-energy-cacket-2014.png", width: 9cm))
        #v(-0.6cm)
        #align(center, text(size: 12pt)[Cackett et al., 2014 for NGC 4151])
        ]
      ]
  )
]

// #sl(title: "Fourier lags")[
//   Conventional to do lag analysis in the #hl[Fourier domain] (e.g. Uttley et al., 2014)
//   #grid(
//       columns: (1fr, 9cm),
//       [
//       - Easier for describing underlying #hl[stochastic process]
//       - Interpreting complex signals through #hl[decomposition] into #hl[various time scales].
//       ],
//       [
//       ]
//   )
// ]

#sl(title: "Triumphs & contests")[
  // success in fitting the 1 Zwicky 1 (Wilkins et al. 2021)
  // De Marco et al. 2012, how lag correlates with black hole mass
  // Kara et al. 2016: same thing for iron line
  // polarisation results
  Reverberation lags can be used for #hl[mass estimation], as $t_g = G M \/ c^3$.

  #grid(
      columns: (50%, 1fr),
      [
        #set align(center)
        #image("assets/o-neill-2025-cyg-x-1-mass.png", height: 9cm)
        #v(-0.5cm)
        #text(size: 15pt)[O'Neill et al., 2025]
        #v(-0.5cm)
      ],
      [
        #set align(center)
        #image("assets/iron-k-vs-black-hole-mass-kara-et-al-2016.png", height: 9cm)
        #v(-0.5cm)
        #text(size: 15pt)[Kara et al., 2016]
        #v(-0.5cm)
      ]
  )


  #uncover("2-")[The #hl[lamppost model] is admittedly unphysical:
  - Great for #hl[computational simplicity]
  - Does not #hl[couple to the disc], struggles to reproduce subtler lag behaviour (Wilkins et al., 2016)
  - At odds with polarimetry results (Krawczynski et al., 2023)

  A need for over a decade for #hl[extended coronal models] (Uttley et al., 2014).
  ]
]

// #sl(title: "Speedy emissivities")[
//   Basic idea is to do isotropic sampling, but we can exploit symmetries here
// ]

#sl(title: "Beyond the lamppost model")[
  #align(center, image("figs/coronal-traces-inkscape.svg", width: 20cm))

  Computational challenges:
  - #hl[Cannot exploit] high degree of symmetry as with lamppost
  - Emissivity and corona-to-disc time #hl[no longer injective functions] of $r$

  #uncover("2-")[Modelling efforts to date:
  // check these dates
  - Chainakun & Young (2017), Lucchini et al. (2021): two independent on-axis lampposts
  - Wilkins et al. (2016): a Monte-Carlo approach for radially extended corona
  ]

  #uncover("3-")[#hl[Need] to go beyond a lamppost but currently breaks the #hl[forward-modelling paradigm].]

  // extended coronae is the problem i've been working on for about a year with
  // the software i've been developing over the last 4 years
  // - we can do thick discs fast enough to fit them
  // - we can do radially extended coronae fast enough too
]

#sl(title: "Decomposing the corona")[
  Assume #hl[axis-symmetry] for computational simplicity still.
  #grid(
      columns: (50%, 1fr),
      [
      Decomposition scheme:
      - Slice any volume into #hl[discs] with height $delta h$
      - Each disc is split into #hl[annuli] $x + delta x$
      - Treat each annulus as a #hl[point], and #hl[weight] contribution by volume
      ],
      [
        #align(center, image("figs/decomposition.svg", width: 90%))
      ]
  )
  E.g. for #hl[emissivity]:
  $
    epsilon (r, t) = integral_0^(x_"out") = V (x) epsilon_x (r, t) dif x,
  $
  where $V(x)$ is the volume of the annulus.

  #v(1fr)
  #align(right, text(size: 18pt)[See my talk at next week's #hl[Lunch Meeting] for how this works!\ Or see Baker & Young, in prep.])
]

#sl(title: "An extended picture")[

]

#sl(title: "Time dependent emissivity")[

]

#sl(title: "Extended coronae")[

]

#sl(title: "Advantages of slow computers")[
  // not slow programs! Computers are slow
  We can really see what the relativistic beaming effect is
  - appreciate the asymmetries of the system further

  - use this as a moment to look back on all the things we learn to appreciate by developing the algorithms and not just the parallelise-ability
]

#sl(title: "What's next?")[
  #grid(
      columns: (70%, 1fr),
      [
      Our models are #hl[sufficiently fast] for use in parameter inference:
      - Ironing out the implementation.
      - Currently takes around \~15 s to pre-compute a set of relevant tables
      - But around #hl[100 ms to evaluate] (plenty more optimisations to be done).

      #uncover("3-")[On the brink of #hl[inferring the geometry of the corona] directly from observation for the first time.]
      ],
      [
        #uncover("2-")[#image("figs/integrate-lagprofile-flamegraph.png", width: 100%)]
      ]
  )

  #uncover("4-")[We had the data, now #hl[we almost have the models].]

  #uncover("5-")[Some new questions open
  - how do we model the next most simple thing
  ]
]

#sl(title: "Gradus.jl")[
  #grid(
      columns: (46%, 1fr),
      column-gutter: 0.5cm,
      [
        #v(1cm)
        #align(center, image("figs/gradus_logo.png", height: 10cm))
        _Does what you want with geodesics_
      ],
      [
        Install with `pkg> add Gradus`
        #uncover("2-")[
        ```julia
        using Gradus

        # model components
        m = KerrMetric(1.0, 0.998
        x = SVector(0.0, 1e4, deg2rad(88), 0.0)
        c = LampPostCorona(h = 10.0)
        d = ShakuraSunyaev(m; eddington_ratio = 0.2)

        prof = emissivity_profile(m, d, c)
        # transfer function tables
        func = transferfunctions(m, x, d)
        # integrate lineprofile, reverberation lags
        # and so on...
        g = collect(range(0.01, 1.5, 200))
        f = integrate_lineprofile(prof, func, g)
        ```
        ]
        #v(-0.2cm)
        #uncover("3-")[#text(size: 14pt)[Oh, but maybe...]]
        #v(-0.3cm)
        #uncover("4-")[
        ```diff
        - m = KerrMetric(1.0, 0.998)
        + m = JohannsenMetric(M = 1.0, a = 0.4, α13 = 0.6)
        ```
      ]
      ]
  )
  #v(1fr)
  Open-source GPL 3.0 #link("https://github.com/astro-group-bristol/Gradus.jl")
  #align(right, text(size: 18pt)[Baker & Young, submitted to MNRAS.])
]

#slide()[
  #show link: l => text(fill: blue.lighten(40%), l)
  #set page(fill: PRIMARY_COLOR, footer: none)
  #set text(fill: SECONDARY_COLOR)
  #v(0.5cm)
  #par(spacing: 0pt, text(size: 105pt, weight: "bold")[Summary])

  #v(0.5cm)

  - Black holes are *real*, and, through some mechanism, they have a *corona*.
  - Studying *timing features* (reverberation lags) lets us learn about the scale of the system, and infer the *mass of the black hole*.
  - True *geometry of the corona is unknown* ... _for now_.
  - Modelling extended coronal geometry is difficult and will pose many theoretical problems, but *it needs to be done*.
  - *Gradus.jl* is a new open-source tool for doing things with geodesics in arbitrary spacetimes.

  #par(spacing: 20pt, text(size: 30pt)[*Thank you! \<3*])

  #set align(right)
  #v(1fr)
  *Contact:* #link("fergus.baker@bristol.ac.uk") \
  #link("www.cosroe.com") \
  *Source for slides and figures:* \
  #link("https://github.com/fjebaker/bristol-march-2025")
  #set text(size: 15pt)
  \
  Figures rendered using Makie.jl and GNUPlot.\
  Fonts: Empyrean, Inter, Vollkorn (OFL).\
  Slides made with Typst.
]
