#import "@preview/touying:0.7.4": *
#import themes.metropolis: *
#import "@preview/numbly:0.1.0": numbly

// ============================================================
//  Metropolis theme colors (for themed blocks)
// ============================================================
#let m-dark-teal = rgb("#23373b")
#let m-light-brown = rgb("#eb811b") // accent
#let m-lighter-brown = rgb("#d6c6b7")

// ------------------------------------------------------------
//  Themed "theorem-style" blocks.
//  Lightweight + counter-free so they survive Touying's
//  per-slide rendering. Usage:
//    #theorem("Online Newton Step")[ statement ... ]
//    #proof[ argument ... ]
// ------------------------------------------------------------
#let _admonition(kind, accent, name, body) = block(
  width: 100%,
  inset: (left: 0.9em, rest: 0.7em),
  radius: 2pt,
  fill: accent.lighten(90%),
  stroke: (left: 2.5pt + accent),
  {
    text(weight: "bold", fill: accent, kind)
    if name != none [ #text(weight: "bold", fill: accent)[ (#name)] ]
    parbreak()
    body
  },
)

#let proof(body) = block(
  width: 100%,
  inset: (left: 0.9em, rest: 0.5em),
  {
    text(style: "italic", fill: m-dark-teal)[Proof.]
    body
    h(1fr)
    sym.square.stroked
  },
)

// allow `#theorem("Name")[...]` as well as `#theorem(name: "Name")[...]`
#let theorem(..args) = {
  let pos = args.pos()
  let body = pos.last()
  let name = if pos.len() > 1 { pos.first() } else { args.named().at("name", default: none) }
  _admonition("Theorem", m-light-brown, name, body)
}
#let lemma(..args) = {
  let pos = args.pos()
  let body = pos.last()
  let name = if pos.len() > 1 { pos.first() } else { args.named().at("name", default: none) }
  _admonition("Lemma", m-light-brown, name, body)
}
#let definition(..args) = {
  let pos = args.pos()
  let body = pos.last()
  let name = if pos.len() > 1 { pos.first() } else { args.named().at("name", default: none) }
  _admonition("Definition", m-dark-teal, name, body)
}

// ============================================================
//  Theme setup
// ============================================================
#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  footer: [],
  config-info(
    title: [Introduction to Online Convex Optimization],
    subtitle: [Reading Seminar — Sections 5.5–5.8],
    author: [Rintaro Okahara],
    date: datetime(year: 2026, month: 6, day: 16),
  ),
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

// Inline *emphasis* should not be tinted with the accent color — keep it
// the normal body color (bold weight is retained).
#show strong: it => text(fill: m-dark-teal, weight: "bold", it.body)

// ============================================================
//  Title
// ============================================================
#title-slide()

// ============================================================
//  Outline
// ============================================================
= Outline <touying:hidden>

#outline(title: none, indent: 1em, depth: 1)

// ============================================================
//  HOW TO EDIT THIS DECK
//  - A new SECTION (appears in the outline): start a line with `= Title`
//  - A new SLIDE inside a section:            start a line with `== Title`
//  - A slide with no title:                   put `---` on its own line
//  - Reorder / add / delete by moving these blocks around — pages are flexible.
//  - Reusable snippets (theorem/proof, 2-column, focus, pause) live in the
//    hidden Appendix at the bottom; copy from there.
//  Section titles below are inferred from Hazan's OCO Ch.5 (Regularization).
//  Edit any `=` heading if your edition differs.
// ============================================================

// ------------------------------------------------------------
//  5.5 — Randomized Regularization
// ------------------------------------------------------------
= Randomized Regularization

== Follow-the-Perturbed-Leader

#block(width: 100%, breakable: false, {
  set text(size: 0.78em)
  let kw(t) = text(weight: "bold")[#t]
  line(length: 100%, stroke: 1pt)
  v(0.12em)
  text(weight: "bold", fill: m-light-brown)[Algorithm 16]
  [ — Follow-the-perturbed-leader for convex losses]
  v(0.12em)
  line(length: 100%, stroke: 0.5pt)
  v(0.35em)
  grid(
    columns: (1.4em, 1fr),
    column-gutter: 0.45em,
    row-gutter: 0.42em,
    align: (right + top, left + top),
    [1:], [Input: $eta > 0$, distribution $cal(D)$ over $RR^n$, decision set $cal(K) subset.eq RR^n$.],
    [2:], [Let $x_1 = bb(E)_(n tilde cal(D)) [arg min_(x in cal(K)) {n^top x}]$.],
    [3:], [#kw("for") $t = 1$ to $T$ #kw("do")],
    [4:], [#h(1.2em) Predict $x_t$.],
    [5:], [#h(1.2em) Observe $f_t$, suffer $f_t (x_t)$, and set $nabla_t = nabla f_t (x_t)$.],
    [6:], [#h(1.2em) Update
      $ x_(t+1) = bb(E)_(n tilde cal(D)) [arg min_(x in cal(K)) { eta sum_(s=1)^t nabla_s^top x + n^top x }] quad (5.4) $],
    [7:], [#kw("end for")],
  )
  v(0.12em)
  line(length: 100%, stroke: 1pt)
})

#v(0.45em)

#[
  #set text(size: 0.95em)
  - Resembles a *special case of FTRL* (Follow-the-Regularized-Leader).
  - *Key difference:* the regularizer is *randomized* — noise $n tilde cal(D)$ is
    injected into the objective in place of a fixed regularizer.
]

// ------------------------------------------------------------
//  5.5.1 — Regret bound (Theorem 5.8) + stability condition
// ------------------------------------------------------------
== Regret Bound for FPL

#[
  #set text(size: 0.72em)

  #theorem("5.8")[
    Let $cal(D)$ be $(sigma, L)$-stable with respect to the norm $norm(dot)_a$.
    Then FPL (Algorithm 16) attains
    $ "Regret"_T <= eta D (G^*)^2 L T + 1/eta sigma D, $
    and, optimizing over $eta$,
    $ "Regret"_T <= 2 L D G^* sqrt(sigma T) . $
  ]

  #v(0.3em)

  #definition([$(sigma, L)$-stability])[
    For $sigma, L in RR$, a distribution $cal(D)$ is $(sigma, L)$-stable with
    respect to $norm(dot)_a$ if
    $ bb(E)_(n tilde cal(D)) [norm(n)_a^*] = sigma
      quad "and" quad
      forall u : integral_n abs(cal(D)(n) - cal(D)(n - u)) dif n <= L norm(u)_a^* . $
  ]
]

#v(0.45em)

#[
  #set text(size: 0.95em)
  // TODO: ~2 lines of notes / remarks here.
  - …
  - …
]

// ------------------------------------------------------------
//  5.5.2 — FPL for linear losses (Algorithm 17)
// ------------------------------------------------------------
== FPL for Linear Losses

#block(width: 100%, breakable: false, {
  set text(size: 0.78em)
  let kw(t) = text(weight: "bold")[#t]
  line(length: 100%, stroke: 1pt)
  v(0.12em)
  text(weight: "bold", fill: m-light-brown)[Algorithm 17]
  [ — FPL for linear losses]
  v(0.12em)
  line(length: 100%, stroke: 0.5pt)
  v(0.35em)
  grid(
    columns: (1.4em, 1fr),
    column-gutter: 0.45em,
    row-gutter: 0.42em,
    align: (right + top, left + top),
    [1:], [Input: $eta > 0$, distribution $cal(D)$ over $RR^n$, decision set $cal(K) subset.eq RR^n$.],
    [2:], [Sample $n_0 tilde cal(D)$. Let $hat(x)_1 in arg min_(x in cal(K)) {-n_0^top x}$.],
    [3:], [#kw("for") $t = 1$ to $T$ #kw("do")],
    [4:], [#h(1.2em) Predict $hat(x)_t$.],
    [5:], [#h(1.2em) Observe the linear loss function, suffer loss $g_t^top x_t$.],
    [6:], [#h(1.2em) Update
      $ hat(x)_t = arg min_(x in cal(K)) { eta sum_(s=1)^(t-1) g_s^top x + n_0^top x } $],
    [7:], [#kw("end for")],
  )
  v(0.12em)
  line(length: 100%, stroke: 1pt)
})

#v(0.45em)

#[
  #set text(size: 0.95em)
  // TODO: add ~2 takeaway bullets here (same as Algorithm 16).
  - …
  - …
]

// ------------------------------------------------------------
//  5.5.3 — FPL for prediction from expert advice (Algorithm 18)
// ------------------------------------------------------------
== FPL for Prediction from Expert Advice

#block(width: 100%, breakable: false, {
  set text(size: 0.78em)
  let kw(t) = text(weight: "bold")[#t]
  line(length: 100%, stroke: 1pt)
  v(0.12em)
  text(weight: "bold", fill: m-light-brown)[Algorithm 18]
  [ — FPL for prediction from expert advice]
  v(0.1em)
  line(length: 100%, stroke: 0.5pt)
  v(0.25em)
  grid(
    columns: (1.4em, 1fr),
    column-gutter: 0.45em,
    row-gutter: 0.32em,
    align: (right + top, left + top),
    [1:], [Input: $eta > 0$.],
    [2:], [Draw $n$ exponentially distributed variables $n(i) tilde e^(-eta x)$.],
    [3:], [Let $x_1 = arg min_(e_i in Delta_n) {-e_i^top n}$.],
    [4:], [#kw("for") $t = 1$ to $T$ #kw("do")],
    [5:], [#h(1.2em) Predict using expert $i_t$ such that $hat(x)_t = e_(i_t)$.],
    [6:], [#h(1.2em) Observe the loss vector, suffer loss $g_t^top hat(x)_t = g_t (i_t)$.],
    [7:], [#h(1.2em) Update (w.l.o.g. choose $hat(x)_(t+1)$ to be a vertex)
      $ hat(x)_(t+1) = arg min_(x in Delta_n) { sum_(s=1)^t g_s^top x - n^top x } $],
    [8:], [#kw("end for")],
  )
  v(0.1em)
  line(length: 100%, stroke: 1pt)
})

#v(0.3em)

#[
  #set text(size: 0.8em)
  - Special case of Algorithm 17: the simplex $Delta_n$, costs in $[0, 1]$, and
    one-sided exponential noise $n(i) tilde e^(-eta x)$ — the first use of
    perturbation in decision making (Hannan [1957]).
  - The generic FPL bound (Corollary 5.9) is loose here, so Theorem 5.10 gives a
    dedicated analysis, tight up to constants.
]

// ------------------------------------------------------------
//  5.5.3 — Regret bound (Theorem 5.10) + order comparison
// ------------------------------------------------------------
== Regret Bound for Expert-Advice FPL

#[
  #set text(size: 0.78em)

  #theorem("5.10")[
    Algorithm 18 outputs predictions $hat(x)_1, ..., hat(x)_T in Delta_n$ with
    $ (1 - eta) bb(E) [ sum_t g_t^top hat(x)_t ]
        <= min_(x^star in Delta_n) sum_t g_t^top x^star + (4 log n) / eta . $
  ]

  #v(0.4em)

  *Optimizing $eta$.* Choosing $eta = sqrt((log n) \/ T)$ gives
  $ "Regret"_T = O(sqrt(T log n)) , $
  matching the *Hedge* guarantee (Theorem 1.5) up to constants.
]

#v(0.4em)

#[
  #set text(size: 0.82em)
  *Why a separate analysis? — the order gap.*
  - *Generic FPL (Cor. 5.9)* on $Delta_n$: the uniform-noise instance has
    $sigma <= n^(1\/4)$, $L <= 1$, giving $"Regret"_T = O(D G n^(1\/4) sqrt(T))$
    — a factor $n^(1\/4)$ *worse* than the $O(sqrt(T))$ of OGD (Theorem 3.1).
  - *Expert-advice FPL (Thm 5.10)*, with exponential noise, removes that
    polynomial-in-$n$ penalty: only a $sqrt(log n)$ dependence remains.
  - Hence FPL on the simplex is *order-optimal*, on par with the standard
    multiplicative-weights / Hedge bound $O(sqrt(T log n))$.
]

// ------------------------------------------------------------
//  5.5.3 — Proof of Theorem 5.10 (part 1/2)
// ------------------------------------------------------------
== Proof of Theorem 5.10 (1/2)

#[
  #set text(size: 0.78em)

  #text(style: "italic", fill: m-dark-teal)[Proof.]
  Set $g_0 = -n$. Applying *Lemma 5.4* (FTL-BTL) to $f_t (x) = g_t^top x$,
  $ bb(E) [ sum_(t=0)^T g_t^top u ] >= bb(E) [ sum_(t=0)^T g_t^top hat(x)_(t+1) ] . $

  #v(0.3em)

  Therefore, telescoping and isolating the $t = 0$ term,
  $
    bb(E) [ sum_(t=1)^T g_t^top (hat(x)_t - x^star) ]
      &<= bb(E) [ sum_(t=1)^T g_t^top (hat(x)_t - hat(x)_(t+1)) ]
         + bb(E) [ g_0^top (x^star - x_1) ] \
      &<= bb(E) [ sum_(t=1)^T g_t^top (hat(x)_t - hat(x)_(t+1)) ]
         + bb(E) [ norm(n)_oo norm(x^star - x_1)_1 ] \
      &<= sum_(t=1)^T bb(E) [ g_t^top (hat(x)_t - hat(x)_(t+1)) | hat(x)_t ]
         + 4 / eta log n . quad (5.6)
  $

  #v(0.25em)

  The 2nd line uses the *generalized Cauchy–Schwarz* inequality; the 3rd uses
  $ bb(E)_(n tilde cal(D)) [ norm(n)_oo ] <= (2 log n) / eta quad ("exercise"), quad
    norm(x^star - x_1)_1 <= 2 . $
]

// ------------------------------------------------------------
//  5.5.3 — Proof of Theorem 5.10 (part 2/2)
// ------------------------------------------------------------
== Proof of Theorem 5.10 (2/2)

#[
  #set text(size: 0.78em)

  *Per-step term.* Bounding by the probability that the leader changes, times
  $norm(g_t)_oo <= 1$ (losses bounded by one):
  $ bb(E) [ g_t^top (hat(x)_t - hat(x)_(t+1)) | hat(x)_t ]
      <= norm(g_t)_oo dot Pr[ hat(x)_t != hat(x)_(t+1) | hat(x)_t ]
      <= Pr[ hat(x)_t != hat(x)_(t+1) | hat(x)_t ] . $

  #v(0.25em)

  $hat(x)_t = e_(i_t)$ leads iff $-n(i_t) > v$ for some $v$ fixed by the history;
  it *stays* the leader iff $-n(i_t) > v + g_t (i_t)$. By the *memorylessness* of
  the exponential distribution,
  $
    Pr[ hat(x)_t != hat(x)_(t+1) | hat(x)_t ]
      &= 1 - Pr[ -n(i_t) > v + g_t (i_t) | -n(i_t) > v ] \
      &= 1 - (integral_(v + g_t (i_t))^oo eta e^(-eta x) dif x)
              / (integral_v^oo eta e^(-eta x) dif x)
       = 1 - e^(-eta g_t (i_t))
       <= eta g_t (i_t) = eta g_t^top hat(x)_t .
  $

  #v(0.25em)

  Substituting into (5.6),
  $ bb(E) [ sum_(t=1)^T g_t^top (hat(x)_t - x^star) ]
      <= eta sum_t bb(E)_t [ g_t^top hat(x)_t ] + (4 log n) / eta , $
  which rearranges to the theorem.
  #h(1fr) #sym.square.stroked
]

// ------------------------------------------------------------
//  5.6 — Adaptive Gradient Descent (AdaGrad)
// ------------------------------------------------------------
= Adaptive Gradient Descent (AdaGrad)

== Learning the Regularizer Online

#[
#set text(size: 0.78em)

*Motivation.* RFTL's regret bound (5.7) depends on the regularizer $R$; the
optimal $R$ depends on both $cal(K)$ and the cost sequence. So we learn it online
— AdaGrad optimizes the regularization (line 5) to shrink the dominant
gradient-norm term in (5.7).

#v(0.25em)

#block(width: 100%, breakable: false, {
  let kw(t) = text(weight: "bold")[#t]
  line(length: 100%, stroke: 1pt)
  v(0.08em)
  text(weight: "bold", fill: m-light-brown)[Algorithm 19]
  [ — AdaGrad]
  v(0.08em)
  line(length: 100%, stroke: 0.5pt)
  v(0.25em)
  grid(
    columns: (1.4em, 1fr),
    column-gutter: 0.45em,
    row-gutter: 0.42em,
    align: (right + top, left + top),
    [1:], [Input: parameters $eta$, $x_1 in cal(K)$.],
    [2:], [Initialize: $G_0 = 0$.],
    [3:], [#kw("for") $t = 1$ to $T$ #kw("do")],
    [4:], [#h(1.2em) Predict $x_t$, suffer loss $f_t (x_t)$.],
    [5:], [#h(1.2em) Update $G_t = G_(t-1) + nabla_t nabla_t^top$ and define
      $ "(diagonal)" quad & H_t = arg min_(H succ.eq 0, space H = "diag"(H)) {G_t dot H^(-1) + "Tr"(H)} = "diag"(G_t^(1/2)) \
        "(full matrix)" quad & H_t = arg min_(H succ.eq 0) {G_t dot H^(-1) + "Tr"(H)} = G_t^(1/2) $],
    [6:], [#h(1.2em) Update $y_(t+1) = x_t - eta H_t^(-1) nabla_t$, #h(0.8em)
      $x_(t+1) = arg min_(x in cal(K)) norm(y_(t+1) - x)_(H_t)^2$.],
    [7:], [#kw("end for")],
  )
  v(0.1em)
  line(length: 100%, stroke: 1pt)
})
]

// ------------------------------------------------------------
//  5.7 — Bibliographic Remarks
// ------------------------------------------------------------
= Bibliographic Remarks

== Notes & References

#v(1fr)

#block(width: 100%, {
  set text(size: 0.86em)
  set par(leading: 0.6em)
  show list: set block(spacing: 0.9em)
  [
- *Origins.* Regularization for online learning: Grove et al. [2001];
  Kivinen & Warmuth [2001].

- *Follow-the-(Perturbed-)Leader.* Kalai & Vempala [2005] coined
  _follow-the-leader_ and analyzed random perturbation as a regularizer (FPL),
  reviving an idea of Hannan [1957].

- *Follow-the-Regularized-Leader.* _FTRL_ coined by Shalev-Shwartz & Singer
  [2007]; identical _RFTL_ by Abernethy et al. [2008]. Hazan & Kale [2008]:
  RFTL #sym.equiv Online Mirror Descent.

- *AdaGrad.* Duchi et al. [2010, 2011]; diagonal version in parallel by
  McMahan & Streeter [2010]. Analysis here follows Gupta et al. [2017].

- *Adaptive regularization in deep learning.* AdaGrad, RMSprop [Tieleman &
  Hinton 2012], Adam [Kingma & Ba 2014]; survey: Goodfellow et al. [2016].

- *Randomization #sym.arrow.l.r regularization.* In special cases, adding
  randomization #sym.approx deterministic strongly convex regularization
  [Abernethy et al. 2014, 2016].
  ]
})

#v(1fr)

// ------------------------------------------------------------
//  5.8 — Exercises
// ------------------------------------------------------------
= Exercises

== Exercise 1(b): Generalized Cauchy–Schwarz

#[
#set text(size: 0.9em)

*Claim.* For any norm $norm(dot)$ with dual norm
$norm(y)_* := sup_(norm(z) <= 1) z^top y$,
$ x^top y <= norm(x) dot norm(y)_* . $

#proof[
  If $x = 0$ (or $y = 0$), both sides equal $0$ and the inequality holds. So
  assume $x != 0$ from here on.

  Since $x != 0$, the unit vector $u = x \/ norm(x)$ satisfies $norm(u) = 1$,
  hence it is admissible in the supremum defining the dual norm. Therefore
  $ norm(y)_* = sup_(norm(z) <= 1) z^top y >= u^top y
    = (x^top y) / norm(x) . $

  Multiplying both sides by $norm(x) > 0$ yields
  $ x^top y <= norm(x) dot norm(y)_* . $
]
]

// ============================================================
//  APPENDIX — reusable templates (hidden from the outline).
//  Copy these patterns into the sections above as needed.
// ============================================================
#show: appendix

= Templates <touying:hidden>

== Theorem / Proof blocks

#theorem("Name of result")[
  State the claim here, with math like $R_T = O(sqrt(T))$.
]

#proof[
  Sketch the argument; the QED square is added automatically.
]

== Definition / Lemma blocks

#definition("Term")[
  $f$ is $alpha$-strongly convex if
  $ f(y) >= f(x) + nabla f(x)^top (y - x) + alpha / 2 norm(y - x)^2 . $
]

#lemma[Use #lemma the same way as #theorem.]

== Two columns

#grid(
  columns: (1fr, 1fr),
  gutter: 1.5em,
  [
    *Idea.* Text on the left, matching math on the right.

    - Bullet one
    - Bullet two
  ],
  [
    $
      x_(t+1) &= Pi_cal(K) (x_t - eta nabla f_t (x_t)) \
      Pi_cal(K) (y) &= arg min_(x in cal(K)) norm(x - y)
    $
  ],
)

== Incremental reveal

State the assumption. #pause

Then #pause introduce the algorithm. #pause

Finally, conclude.

#focus-slide[
  A big, centered takeaway statement.
]

== Bibliography

Drop a `refs.bib` beside this file, then uncomment:

// #bibliography("refs.bib", title: "References")
// Inline citation: @hazan2016.
