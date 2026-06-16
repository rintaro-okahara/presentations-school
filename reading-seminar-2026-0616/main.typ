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

== Stability of the Perturbation Distribution

#[
  #set text(size: 0.78em)

  We call a perturbation distribution $(sigma, L)$-*stable* when it is small
  enough to keep the fake loss controlled, and smooth enough that shifting the
  noise does not change the leader too much.

  #v(0.35em)

  #definition([$(sigma, L)$-stable distribution])[
    With respect to the norm $norm(dot)_a$, a distribution $cal(D)$ over
    $RR^n$ is $(sigma, L)$-stable if
    $
      bb(E)_(n tilde cal(D)) [ norm(n)_a^* ] = sigma
      quad "and" quad
      forall u in RR^n :
      integral_n abs(cal(D)(n) - cal(D)(n - u)) dif n
        <= L norm(u)_a^* .
    $
  ]

  #v(0.45em)

  The two constants play different roles in the regret bound:
  $
    "Regret"_T <= eta D (G^*)^2 L T + 1 / eta sigma D .
  $
]

== Exercise 5.8.6: Uniform Noise Check

#[
  #set text(size: 0.78em)

  The exercise asks us to prove, for $cal(D) = "Unif"([0, 1]^n)$ and the
  Euclidean norm,
  $
    sigma_2 < sqrt(n), quad L_2 <= 1 .
  $

  #v(0.35em)

  #text(fill: red, weight: "bold")[
    My reading: the $sigma$ bound is fine, but the $L_2 <= 1$ claim seems too
    strong for the stability definition above.
  ]

  #v(0.35em)

  Already in one dimension, with $cal(D)(x) = 1_[0, 1](x)$ and
  $0 < u < 1$,
  $
    integral_RR abs(cal(D)(x) - cal(D)(x - u)) dif x
      &= |[0, 1] Delta [u, 1 + u]| \
      &= 2 u
      > u = norm(u)_2 .
  $

  Thus $L_2 <= 1$ would require $2u <= u$, impossible for $u > 0$.
]

== Uniform Noise: A Safer Stability Bound

#[
  #set text(size: 0.74em)

  Let $N tilde "Unif"([0, 1]^n)$. The size term is fine:
  $
    sigma_2
      = bb(E) [ norm(N)_2 ]
      <= sqrt( bb(E) [ norm(N)_2^2 ] )
      = sqrt( sum_(i=1)^n bb(E) [ N_i^2 ] )
      = sqrt(n / 3)
      < sqrt(n).
  $

  #v(0.3em)

  For the density-shift term,
  $
    integral abs(cal(D)(x) - cal(D)(x - u)) dif x
      &= |[0, 1]^n Delta ([0, 1]^n + u)| \
      &<= 2 sum_(i=1)^n min(abs(u_i), 1) \
      &<= 2 norm(u)_1
      <= 2 sqrt(n) norm(u)_2 .
  $

  #v(0.25em)

  Therefore the usable bounds are $sigma_2 < sqrt(n)$ and
  $L_2 <= 2 sqrt(n)$. The factor $2 sqrt(n)$ is sharp: take
  $u = epsilon (1, ..., 1)$ and let $epsilon -> 0^+$.
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
    $ "Regret"_T <= 2 D G^* sqrt(sigma L T) . $
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

#grid(
  columns: (1fr, 1fr),
  gutter: 1.1em,
  [
    #set text(size: 0.82em)
    *Stability cost.* The first term controls how far consecutive expected
    leaders can move.
  ],
  [
    #set text(size: 0.82em)
    *Perturbation cost.* The second term pays for comparing the fake initial
    leader with $x^star$.
  ],
)

== Tool: FTL-BTL Lemma

#[
  #set text(size: 0.78em)

  The proof repeatedly uses the FTL-BTL lemma from Section 5.2.

  #v(0.25em)

  #lemma("5.4")[
    If $x_(t+1) in arg min_(x in cal(K)) sum_(s=0)^t g_s (x)$, then for every
    $u in cal(K)$,
    $ sum_(t=0)^T g_t (u) >= sum_(t=0)^T g_t (x_(t+1)) . $
  ]

  #v(0.4em)

  In FPL, the perturbation is treated as a *fake initial loss*
  $ g_0^n (x) = 1 / eta n^top x $
  This makes perturbed-leader analysis look
  exactly like the FTRL proof.
]

== Proof of Theorem 5.8: Random Leaders

#[
  #set text(size: 0.76em)

  For fixed perturbation $n$, define the random leader and fake loss:
  $
    x_t^n
      &= arg min_(x in cal(K)) { eta sum_(s=1)^(t-1) nabla_s^top x + n^top x },
      \
    g_0^n (x) &:= 1 / eta n^top x,
    quad
    g_t (x) := nabla_t^top x .
  $

  #v(0.35em)

  Applying Lemma 5.4 to $g_0^n, g_1, ..., g_T$:
  $
    bb(E)_n [ sum_(t=0)^T g_t (u) ]
      &>= bb(E)_n [ g_0^n (x_1^n) + sum_(t=1)^T g_t (x_(t+1)^n) ] \
      &>= bb(E)_n [ g_0^n (x_1^n) ] + sum_(t=1)^T g_t (bb(E)_n [x_(t+1)^n]) \
      &= bb(E)_n [ g_0^n (x_1^n) ] + sum_(t=1)^T g_t (x_(t+1)).
  $
]

== Proof of Theorem 5.8: Regret Decomposition

#[
  #set text(size: 0.74em)

  Taking $u = x^star$ in the previous slide,
  $
    sum_(t=1)^T nabla_t^top (x_t - x^star)
      &<= sum_(t=1)^T g_t (x_t) - sum_(t=1)^T g_t (x_(t+1))
        + bb(E)_n [g_0^n (x^star) - g_0^n (x_1^n)] \
      &<= sum_(t=1)^T nabla_t^top (x_t - x_(t+1))
        + 1 / eta bb(E)_n [ norm(n)^* norm(x^star - x_1^n) ] \
      &<= sum_(t=1)^T nabla_t^top (x_t - x_(t+1))
        + 1 / eta sigma D .
  $

  #v(0.35em)

  Convexity of $f_t$ and Cauchy-Schwarz give
  $
    sum_t f_t (x_t) - sum_t f_t (x^star)
      <= G^* sum_(t=1)^T norm(x_t - x_(t+1)) + 1 / eta sigma D . quad (5.5)
  $
]

== Proof of Theorem 5.8: Density Shift

#[
  #set text(size: 0.76em)

  It remains to show that consecutive expected leaders are close. Define
  $
    h_t (n) = arg min_(x in cal(K))
      { eta sum_(s=1)^(t-1) nabla_s^top x + n^top x } .
  $

  #v(0.3em)

  Then $x_t = bb(E)_n[h_t (n)]$. The next leader can be written using the same
  $h_t$ but with a shifted perturbation:
  $
    x_t
      &= integral_n h_t (n) cal(D)(n) dif n, \
    x_(t+1)
      &= integral_n h_t (n + eta nabla_t) cal(D)(n) dif n \
      &= integral_n h_t (n) cal(D)(n - eta nabla_t) dif n .
  $

  #v(0.25em)

  Thus stability of decisions reduces to sensitivity of the density $cal(D)$.
]

== Proof of Theorem 5.8: Bounding the Shift

#[
  #set text(size: 0.72em)

  Using the density-shift expression,
  $
    norm(x_t - x_(t+1))
      &= norm( integral_n h_t (n) dot (cal(D)(n) - cal(D)(n - eta nabla_t)) dif n ) \
      &= norm( integral_n (h_t (n) - h_t (0))
            dot (cal(D)(n) - cal(D)(n - eta nabla_t)) dif n ) \
      &<= integral_n norm(h_t (n) - h_t (0))
            abs(cal(D)(n) - cal(D)(n - eta nabla_t)) dif n \
      &<= D integral_n abs(cal(D)(n) - cal(D)(n - eta nabla_t)) dif n \
      &<= D L eta norm(nabla_t)^*
      <= eta D L G^* .
  $

  #v(0.25em)

  The only real input here is $(sigma, L)$-stability with $u = eta nabla_t$.
]

== Proof of Theorem 5.8: Final Bound

#[
  #set text(size: 0.78em)

  Substitute the shift bound into (5.5):
  $
    "Regret"_T
      &<= G^* sum_(t=1)^T norm(x_t - x_(t+1)) + 1 / eta sigma D \
      &<= G^* sum_(t=1)^T eta D L G^* + 1 / eta sigma D \
      &= eta D L (G^*)^2 T + 1 / eta sigma D .
  $

  #v(0.35em)

  Optimizing at $eta = sqrt(sigma / (L (G^*)^2 T))$ gives the stated theorem
  bound:
  $ "Regret"_T <= 2 D G^* sqrt(sigma L T) . $

  #v(0.3em)

  With the corrected uniform-cube bound $L <= 2 sqrt(n)$ and
  $sigma <= sqrt(n)$, this gives a loose
  $O(D G sqrt(n T))$ bound.
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
    [5:], [#h(1.2em) Observe the linear loss function, suffer loss $g_t^top hat(x)_t$.],
    [6:], [#h(1.2em) Update
      $ hat(x)_(t+1) = arg min_(x in cal(K)) { eta sum_(s=1)^t g_s^top x + n_0^top x } $],
    [7:], [#kw("end for")],
  )
  v(0.12em)
  line(length: 100%, stroke: 1pt)
})

#v(0.45em)

#grid(
  columns: (1fr, 1fr),
  gutter: 1.1em,
  [
    #set text(size: 0.82em)
    *Linear loss.* The exact expectation in Algorithm 16 can be replaced by one
    perturbation sample.
  ],
  [
    #set text(size: 0.82em)
    *Expected regret.* The guarantee is taken over the sampled perturbation.
  ],
)

== Why One Sample is Enough for Linear Losses

#[
  #set text(size: 0.78em)

  Let
  $ w_t (n) = arg min_(x in cal(K))
      { eta sum_(s=1)^t g_s^top x + n^top x } . $
  Algorithm 16 predicts $x_t = bb(E)_n [w_(t-1)(n)]$.

  #v(0.35em)

  For a linear loss $f_t (x) = g_t^top x$,
  $
    f_t (x_t)
      = f_t (bb(E)_n [w_(t-1) (n)])
      = bb(E)_n [ f_t (w_(t-1) (n)) ] .
  $

  #v(0.35em)

  Therefore sampling one $n_0 tilde cal(D)$ and playing
  $hat(x)_t = w_(t-1)(n_0)$ has the same expected loss as the exact
  expectation-based prediction.
]

== Corollary 5.9: Expected Regret for Linear FPL

#[
  #set text(size: 0.78em)

  #theorem("Corollary 5.9")[
    For Algorithm 17,
    $
      bb(E)_(n_0 tilde cal(D)) [
        sum_(t=1)^T f_t (hat(x)_t) - sum_(t=1)^T f_t (x^star)
      ]
      <= eta L D (G^*)^2 T + 1 / eta sigma D .
    $
  ]

  #v(0.4em)

  *Computational point.* Algorithm 17 only needs a linear optimization oracle
  over $cal(K)$; the set need not even be convex for the oracle call itself.
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

== Exponential Noise for Expert Advice

#[
  #set text(size: 0.8em)

  For expert advice, the perturbation is one-sided exponential noise:
  $
    Pr[n(i) <= x] = 1 - e^(-eta x)
    quad (x >= 0).
  $

  #v(0.35em)

  The update chooses the expert with smallest cumulative loss after subtracting
  its random bonus:
  $
    hat(x)_(t+1)
      = arg min_(x in Delta_n)
          { sum_(s=1)^t g_s^top x - n^top x } .
  $

  #v(0.35em)

  Corollary 5.9 is too loose for this simplex/exponential-noise case, so
  Theorem 5.10 uses a direct leader-change analysis.
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
  - *Generic FPL (Cor. 5.9)* on $Delta_n$: the corrected uniform-cube bound has
    $sigma <= sqrt(n)$, $L <= 2 sqrt(n)$, giving
    $"Regret"_T = O(D G sqrt(n T))$ — a polynomial-in-$n$ loss versus
    the $O(sqrt(T))$ of OGD (Theorem 3.1).
  - *Expert-advice FPL (Thm 5.10)*, with exponential noise, removes that
    polynomial-in-$n$ penalty: only a $sqrt(log n)$ dependence remains, on par
    with the standard multiplicative-weights / Hedge bound $O(sqrt(T log n))$.
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

== Exercise Bound for $norm(n)_oo$: A Careful Version

#[
  #set text(size: 0.68em)

  Let $N_i tilde "Exp"(eta)$ independently and
  $M = norm(N)_oo = max_i N_i$.

  #v(0.15em)

  #text(fill: red, weight: "bold")[
    My reading: the exercise bound
    $bb(E) [M] <= (2 log n) / eta$ needs a small qualification as stated.
  ]

  #v(0.25em)

  #grid(
    columns: (1fr, 1.08fr),
    gutter: 1.1em,
    [
      *Why a qualification is needed: $n = 2$.*
      $
        bb(E) [M]
          &= integral_0^oo Pr[M >= t] dif t \
          &= integral_0^oo (1 - (1 - e^(-eta t))^2) dif t \
          &= 3 / (2 eta)
          > (2 log 2) / eta .
      $
    ],
    [
      *One safe upper bound.* By Boole / union bound,
      $
        Pr[M >= t]
          &<= sum_(i=1)^n Pr[N_i >= t] \
          &= n e^(-eta t).
      $
      Also $Pr[M >= t] <= 1$. With $a = (log n) / eta$,
      $
        bb(E) [M]
          &<= a + integral_a^oo n e^(-eta t) dif t \
          &= (1 + log n) / eta .
      $
    ],
  )

  #v(0.25em)

  Thus we can use $bb(E) [norm(N)_oo] <= (1 + log n) / eta$.
  For $n >= 3$ this implies the stated $(2 log n) / eta$ bound.
]

// ------------------------------------------------------------
//  5.5.3 — Proof of Theorem 5.10 (part 2/2)
// ------------------------------------------------------------
== Proof of Theorem 5.10 (2/2)

#[
  #set text(size: 0.76em)

  *Per-step term.* Bounding by the probability that the leader changes, times
  $norm(g_t)_oo <= 1$ (losses bounded by one):
  $ bb(E) [ g_t^top (hat(x)_t - hat(x)_(t+1)) | hat(x)_t ]
      <= norm(g_t)_oo dot Pr[ hat(x)_t != hat(x)_(t+1) | hat(x)_t ]
      <= Pr[ hat(x)_t != hat(x)_(t+1) | hat(x)_t ] . $

  #v(0.25em)

  $hat(x)_t = e_(i_t)$ leads iff $n(i_t) > v$ for some $v$ fixed by the history;
  it *stays* the leader iff $n(i_t) > v + g_t (i_t)$. By the *memorylessness* of
  the exponential distribution,
  $
    Pr[ hat(x)_t != hat(x)_(t+1) | hat(x)_t ]
      & #alternatives($=$, math.class("relation", text(fill: red)[$lt.eq$]))
        1 - Pr[ n(i_t) > v + g_t (i_t) | n(i_t) > v ] \
      &= 1 - (integral_(v + g_t (i_t))^oo eta e^(-eta x) dif x)
              / (integral_v^oo eta e^(-eta x) dif x)
       = 1 - e^(-eta g_t (i_t))
       <= eta g_t (i_t) = eta g_t^top hat(x)_t .
  $

  #only("2-")[
    #v(0.1em)
    #text(fill: red, weight: "bold")[
      My reading: I use "$lt.eq$" for this step; the next slide explains why.
    ]
  ]

  #v(0.15em)

  Substituting into (5.6),
  $ bb(E) [ sum_(t=1)^T g_t^top (hat(x)_t - x^star) ]
      <= eta sum_t bb(E)_t [ g_t^top hat(x)_t ] + (4 log n) / eta , $
  which rearranges to the theorem.
  #h(1fr) #sym.square.stroked
]

// ------------------------------------------------------------
//  5.5.3 — Remark: the marked step is only "<=" (N = 2 counterexample)
// ------------------------------------------------------------
== The Marked Equality is Only "$<=$": an $N = 2$ Check

#[
  #set text(size: 0.86em)

  The proof's event is a *sufficient* condition for staying leader, not a
  necessary one: it ignores that competitors also pay losses.

  #v(0.45em)

  #align(center)[
    #table(
      columns: (1.05fr, 1.35fr, 1.55fr),
      align: (center + horizon, center + horizon, center + horizon),
      inset: (x: 0.65em, y: 0.48em),
      stroke: 0.6pt + m-lighter-brown,
      table.header(
        [Expert],
        [Before $g_t$],
        [After $g_t(1) = g_t(2) = 1$],
      ),
      table.cell(fill: m-light-brown.lighten(86%))[1 = leader],
      table.cell(fill: m-light-brown.lighten(92%))[$S_1$],
      table.cell(fill: m-light-brown.lighten(92%))[$S_1 + 1$],
      [2],
      [$S_2 > S_1$],
      [$S_2 + 1 > S_1 + 1$],
    )
  ]

  #v(0.55em)

  Equal losses shift both scores by the same amount, so the $arg min$ cannot
  change:
  $ Pr[ hat(x)_t != hat(x)_(t+1) | hat(x)_t = e_1 ] = 0 . $

  But the displayed equality would give
  $ 1 - e^(-eta g_t(1)) = 1 - e^(-eta) > 0 . $

  #v(0.25em)

  Thus the marked step should be "$lt.eq$", not "$=$". The direction is still
  enough for the regret bound, so Theorem 5.10 is unaffected.
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
      $ "(diagonal)" quad & H_t = arg min_(H succ.eq 0, space H = "diag"(H)) {G_t dot H^(-1) + "Tr"(H)} = ("diag"(G_t))^(1/2) \
        "(full matrix)" quad & H_t = arg min_(H succ.eq 0) {G_t dot H^(-1) + "Tr"(H)} = G_t^(1/2) $],
    [6:], [#h(1.2em) Update $y_(t+1) = x_t - eta H_t^(-1) nabla_t$, #h(0.8em)
      $x_(t+1) = arg min_(x in cal(K)) norm(y_(t+1) - x)_(H_t)^2$.],
    [7:], [#kw("end for")],
  )
  v(0.1em)
  line(length: 100%, stroke: 1pt)
})
]

== What Line 5 is Optimizing

#[
  #set text(size: 0.8em)

  AdaGrad chooses the matrix $H_t$ that would have made the *observed*
  gradients small, with a trace penalty to keep the metric from blowing up:
  $ H_t = arg min_H { G_t dot H^(-1) + "Tr"(H) },
    quad G_t = sum_(s=1)^t nabla_s nabla_s^top . $

  #v(0.35em)

  #definition([Two comparator classes])[
    $ cal(H)_1 = { H : H = "diag"(H), H succ.eq 0, "Tr"(H) <= 1 },
      quad
      cal(H)_2 = { H : H succ.eq 0, "Tr"(H) <= 1 }. $
  ]

  #v(0.35em)

  #lemma("5.11")[
    For $i in {1, 2}$, with the corresponding final AdaGrad matrix $H_T$,
    $ sqrt( min_(H in cal(H)_i) sum_(t=1)^T norm(nabla_t)_(H)^(* 2) )
        = "Tr"(H_T) . $
  ]
]

== Regret Bound: Compete with the Best Fixed Metric

#[
  #set text(size: 0.76em)

  #theorem("5.12")[
    Let $x_t$ be generated by Algorithm 19. With $eta = D_oo / sqrt(2)$ for the
    diagonal version and $eta = D / sqrt(2)$ for the full-matrix version, for any
    $x^star in cal(K)$,
    $
      "Regret"_T("AdaGrad-diag")
        &<= sqrt(2) D_oo sqrt( min_(H in cal(H)_1)
              sum_t norm(nabla_t)_(H)^(* 2) ), \
      "Regret"_T("AdaGrad-full")
        &<= sqrt(2) D sqrt( min_(H in cal(H)_2)
              sum_t norm(nabla_t)_(H)^(* 2) ).
    $
  ]

  #v(0.35em)

  *Reading.* AdaGrad is nearly as good as the best fixed quadratic regularizer
  in hindsight, chosen from the diagonal or full PSD trace ball.

  #v(0.35em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1.2em,
    [
      *Why the theorem follows from Lemma 5.11.*

      The adaptive choice makes $"Tr"(H_T)$ exactly encode the best hindsight
      gradient norm over $cal(H)_i$.
    ],
    [
      *Why there is still a price.*

      The regularizer changes over time, so the proof needs one extra drift
      term involving $H_t - H_(t-1)$.
    ],
  )
]

== When AdaGrad Beats OGD: Upper Bounds

#[
  #set text(size: 0.62em)

  #grid(
    columns: (0.95fr, 1.05fr),
    gutter: 1.1em,
    [
      *Decision set.*
      $
        cal(K) = [0, 1]^d .
      $

      #v(0.2em)

      *Diameters.*
      $
        D_oo &= sup_(x,y in cal(K)) norm(x - y)_oo = 1, \
        D &= sup_(x,y in cal(K)) norm(x - y)_2 = sqrt(d),
        quad
        norm(x - y)_2^2
          = sum_(i=1)^d (x_i - y_i)^2 <= d .
      $

      $D_oo$ is tight at $x = (0, ..., 0)$, $y = (1, 0, ..., 0)$;
      $D$ is tight at $x = (0, ..., 0)$, $y = (1, ..., 1)$.

      #v(0.2em)

      *Coordinate energy.*
      $
        a_i := sum_(t=1)^T g_(t,i)^2,
        quad
        "diag"(G_T) = "diag"(a_1, ..., a_d).
      $
    ],
    [
      #theorem("Unit cube upper bounds")[
        $
          "Regret"_T("AdaGrad-diag")
            &<= sqrt(2) D_oo "Tr"(("diag"(G_T))^(1/2)) \
            &= sqrt(2) sum_(i=1)^d sqrt(a_i), \
          "Regret"_T("OGD")
            &<= D sqrt(2 sum_(t=1)^T norm(g_t)_2^2) \
            &= sqrt(2 d sum_(i=1)^d a_i).
        $
      ]

      #v(0.25em)

      *Takeaway.* AdaGrad sees $sum_i sqrt(a_i)$, while OGD sees
      $sqrt(d sum_i a_i)$. Thus AdaGrad gains when the gradient energy $a_i$
      is concentrated on few coordinates.
    ],
  )
]

== Example: Sparse Gradients

#[
  #set text(size: 0.72em)

  #grid(
    columns: (0.82fr, 1.18fr),
    gutter: 1.1em,
    [
      *Definition.*
      $
        g_t = (1, 0, ..., 0).
      $
      Then
      $
        a_1 = T,
        quad
        a_2 = ... = a_d = 0.
      $
    ],
    [
      #theorem("Substitute into the bounds")[
        $
          "Regret"_T("AdaGrad-diag")
            &<= sqrt(2) sum_(i=1)^d sqrt(a_i)
             = sqrt(2 T), \
          "Regret"_T("OGD")
            &<= sqrt(2 d sum_(i=1)^d a_i)
             = sqrt(2 d T).
        $
      ]
    ],
  )

  #v(0.25em)

  Therefore
  $
    ("OGD bound") / ("AdaGrad bound")
      = sqrt(2 d T) / sqrt(2 T)
      = sqrt(d).
  $

  #v(0.25em)

  *Takeaway.* If the gradients concentrate on one coordinate, the AdaGrad
  upper bound is a factor $sqrt(d)$ better than the OGD upper bound.
]

== Example: Dense Gradients

#[
  #set text(size: 0.72em)

  #grid(
    columns: (0.82fr, 1.18fr),
    gutter: 1.1em,
    [
      *Definition.*
      $
        g_t = (1, 1, ..., 1).
      $
      Then all coordinates have the same energy:
      $
        a_1 = ... = a_d = T.
      $
    ],
    [
      #theorem("Substitute into the bounds")[
        $
          "Regret"_T("AdaGrad-diag")
            &<= sqrt(2) sum_(i=1)^d sqrt(a_i)
             = sqrt(2) d sqrt(T), \
          "Regret"_T("OGD")
            &<= sqrt(2 d sum_(i=1)^d a_i)
             = sqrt(2 d dot d T)
             = sqrt(2) d sqrt(T).
        $
      ]
    ],
  )

  #v(0.25em)

  Thus $"Regret"_T("AdaGrad-diag")$ and $"Regret"_T("OGD")$ have the same
  order on dense gradients.

  #v(0.25em)

  *Takeaway.* AdaGrad is not always better than OGD. It is strong when the
  gradient sequence is coordinate-sparse; in dense cases, the two bounds have
  the same order.
]

== Analysis Roadmap for Theorem 5.12

#[
  #set text(size: 0.82em)

  The proof splits AdaGrad regret into two terms, then controls each by the same
  final quantity $"Tr"(H_T)$.

  #v(0.35em)

  #lemma("5.13")[
    $
      "Regret"_T
        <= eta / 2 (G_T dot H_T^(-1) + "Tr"(H_T))
          + 1 / (2 eta) sum_(t=0)^T
              norm(x_t - x^star)_(H_t - H_(t-1))^2 .
    $
  ]

  #v(0.45em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1.2em,
    [
      *Lemma 5.14.* Gradient term:
      $ G_T dot H_T^(-1) <= "Tr"(H_T). $
    ],
    [
      *Lemma 5.15.* Drift term:
      $ sum_t norm(x_t - x^star)_(H_t - H_(t-1))^2
          <= D_*^2 "Tr"(H_T). $
    ],
  )

  #v(0.35em)

  Choosing $eta$ balances the two terms and recovers Theorem 5.12.
]

== Lemma 5.13: Proof Details

#[
  #set text(size: 0.48em)
  #set par(leading: 0.44em)

  By convexity, it suffices to bound the linearized regret:
  $
    "Regret"_T <= sum_(t=1)^T nabla_t^top (x_t - x^star).
  $

  #v(-0.15em)

  #grid(
    columns: (1.05fr, 1fr),
    gutter: 0.65em,
    [
      *One-step inequality.* With $y_(t+1)=x_t-eta H_t^(-1)nabla_t$
      and $x_(t+1)=Pi_K^(H_t)(y_(t+1))$,
      $
        norm(y_(t+1)-x^star)_(H_t)^2
          &= norm(x_t-x^star)_(H_t)^2
             -2 eta nabla_t^top (x_t-x^star)
             +eta^2 nabla_t^top H_t^(-1)nabla_t, \
        norm(x_(t+1)-x^star)_(H_t)^2
          &<= norm(y_(t+1)-x^star)_(H_t)^2,
      $
      hence
      $
        nabla_t^top (x_t-x^star)
          <= eta/2 nabla_t^top H_t^(-1)nabla_t
          + 1/(2 eta)(
              norm(x_t-x^star)_(H_t)^2
              - norm(x_(t+1)-x^star)_(H_t)^2
            ). quad (*)
      $

      #v(-0.1em)

      *Sum $(*).$*
      $
        sum_(t=1)^T nabla_t^top (x_t-x^star)
          &<= eta/2 sum_(t=1)^T
                nabla_t^top H_t^(-1)nabla_t
             + 1/(2 eta) S .
      $
    ],
    [
      *Changing metrics telescope.* For
      $
        S = sum_(t=1)^T (
          norm(x_t-x^star)_(H_t)^2
          - norm(x_(t+1)-x^star)_(H_t)^2).
      $
      $
        S
          &= norm(x_1-x^star)_(H_0)^2
             - norm(x_(T+1)-x^star)_(H_T)^2 \
          &quad + sum_(t=1)^T
             norm(x_t-x^star)_(H_t-H_(t-1))^2 .
      $
      Dropping the final non-positive term gives the drift term.

      #v(-0.1em)

      *BTL for the gradient term.* Define
      $
        Psi_t(H)=nabla_t nabla_t^top dot H^(-1),
        quad Psi_0(H)="Tr"(H).
      $
      Since $H_t$ minimizes $sum_(i=0)^t Psi_i(H)$,
      $
        sum_(t=1)^T nabla_t^top H_t^(-1)nabla_t
          &= sum_(t=1)^T Psi_t(H_t)
           <= sum_(t=1)^T Psi_t(H_T)+Psi_0(H_T)-Psi_0(H_0) \
          &= G_T dot H_T^(-1)+"Tr"(H_T).
      $
    ],
  )

  #v(-0.3em)

  Therefore
  $
    "Regret"_T
      <= eta/2 (G_T dot H_T^(-1)+"Tr"(H_T))
        + 1/(2 eta) sum_(t=0)^T
            norm(x_t-x^star)_(H_t-H_(t-1))^2 .
  $
]

== Proposition 5.16: Two Matrix Optimizations

#[
  #set text(size: 0.76em)

  The optimizer in AdaGrad line 5 comes from the second problem below. For
  $A succ.eq 0$,
  $
    (P_1) quad
    &min_(X succ 0, "Tr"(X) <= 1) A dot X^(-1), \
    (P_2) quad
    &min_(X succ 0) { A dot X^(-1) + "Tr"(X) } .
  $

  #v(0.25em)

  *Exercise 11.* The trace-ball problem $(P_1)$ is exactly the exercise:
  prove its minimizer and minimum value.

  #v(0.35em)

  Proposition 5.16 says
  $
    X_1^* = A^(1/2) / "Tr"(A^(1/2)),
    quad
    min(P_1) = "Tr"(A^(1/2))^2,
    \
    X_2^* = A^(1/2),
    quad
    min(P_2) = 2 "Tr"(A^(1/2)).
  $

  #v(0.35em)

  The diagonal case is the same proof after replacing $A$ by $"diag"(A)$.
  I sketch both facts before using them in Lemma 5.14.
]

== Proposition 5.16: Trace-Ball Problem (Exercise 11)

#[
  #set text(size: 0.72em)

  Let $S = "Tr"(A^(1/2))$. For any $X succ 0$, Frobenius Cauchy-Schwarz gives
  $
    S
      &= "Tr"(A^(1/2))
       = "Tr"(A^(1/2) X^(-1/2) X^(1/2)) \
      &<= sqrt("Tr"(A^(1/2) X^(-1) A^(1/2)))
          sqrt("Tr"(X)) \
      &= sqrt(A dot X^(-1)) sqrt("Tr"(X)).
  $

  #v(0.35em)

  Therefore, if $"Tr"(X) <= 1$,
  $
    A dot X^(-1) >= S^2 = "Tr"(A^(1/2))^2.
  $

  #v(0.35em)

  Equality in Cauchy-Schwarz requires
  $X^(-1/2) A^(1/2) = c X^(1/2)$, hence $A^(1/2) = c X$.
  The trace constraint is tight, so
  $
    X = A^(1/2) / "Tr"(A^(1/2)).
  $
]

== Proposition 5.16: Penalized Problem

#[
  #set text(size: 0.76em)

  Use the same inequality, now without the trace constraint. Put
  $t = "Tr"(X) > 0$ and $S = "Tr"(A^(1/2))$. Then
  $
    A dot X^(-1) >= S^2 / t.
  $

  #v(0.35em)

  So the objective is bounded by a one-variable problem:
  $
    A dot X^(-1) + "Tr"(X)
      &>= S^2 / t + t \
      &= ((t - S)^2) / t + 2 S
      >= 2 S .
  $

  #v(0.35em)

  The lower bound is attained at $t = S$ and equality in the Frobenius
  Cauchy-Schwarz step, which together give
  $
    X = A^(1/2).
  $
]

== Proposition 5.16: Diagonal Case

#[
  #set text(size: 0.76em)

  If $X$ is diagonal, only the diagonal of $A$ is visible:
  $
    A dot X^(-1) = "diag"(A) dot X^(-1).
  $

  #v(0.35em)

  Thus the same proof applies with $B = "diag"(A)$:
  $
    "trace-ball optimizer:" quad
      X_1^* = B^(1/2) / "Tr"(B^(1/2)),
    \
    "penalized optimizer:" quad
      X_2^* = B^(1/2).
  $

  #v(0.35em)

  Applying the second formula to $A = G_T$ gives the AdaGrad matrices:
  $
    H_T = G_T^(1/2)
    quad "or" quad
    H_T = ("diag"(G_T))^(1/2).
  $
]

== Lemma 5.14: Gradient Term is at Most Trace

#[
  #set text(size: 0.78em)

  For the full-matrix version,
  $
    G_T dot H_T^(-1)
      = G_T dot G_T^(-1/2)
      = "Tr"(G_T^(1/2))
      = "Tr"(H_T).
  $

  #v(0.35em)

  For the diagonal version, $H_T$ ignores off-diagonal entries:
  $
    G_T dot H_T^(-1)
      = "diag"(G_T) dot ("diag"(G_T))^(-1/2)
      = "Tr"(("diag"(G_T))^(1/2))
      = "Tr"(H_T).
  $

  #v(0.3em)

  Therefore, in both cases,
  $ G_T dot H_T^(-1) <= "Tr"(H_T). $
]

== Lemma 5.15: Diagonal Drift Term

#[
  #set text(size: 0.75em)

  For diagonal AdaGrad, $G_t succ.eq G_(t-1)$ implies
  $H_t - H_(t-1) succ.eq 0$. Since for diagonal $H$,
  $x^top H x <= norm(x)_oo^2 "Tr"(H)$,
  $
    sum_(t=1)^T
      norm(x_t - x^star)_(H_t - H_(t-1))^2
      &<= sum_(t=1)^T D_oo^2 "Tr"(H_t - H_(t-1)) \
      &= D_oo^2 sum_(t=1)^T ("Tr"(H_t) - "Tr"(H_(t-1))) \
      &<= D_oo^2 "Tr"(H_T).
  $

  #v(0.35em)

  The trace telescopes because the metric increments are PSD.
]

== Lemma 5.15: Full-Matrix Drift Term

#[
  #set text(size: 0.75em)

  In the full-matrix case, $H_t - H_(t-1) succ.eq 0$ and
  $lambda_max(A) <= "Tr"(A)$ for $A succ.eq 0$:
  $
    sum_(t=1)^T
      norm(x_t - x^star)_(H_t - H_(t-1))^2
      &<= sum_(t=1)^T D^2 lambda_max(H_t - H_(t-1)) \
      &<= D^2 sum_(t=1)^T "Tr"(H_t - H_(t-1)) \
      &= D^2 sum_(t=1)^T ("Tr"(H_t) - "Tr"(H_(t-1))) \
      &<= D^2 "Tr"(H_T).
  $

  #v(0.25em)

  This proves Lemma 5.15.
]

== Putting the Pieces Together

#[
  #set text(size: 0.74em)

  Lemma 5.13 plus Lemmas 5.14 and 5.15 gives
  $
    "Regret"_T
      &<= eta / 2 (2 "Tr"(H_T))
        + D_*^2 / (2 eta) "Tr"(H_T) \
      &= (eta + D_*^2 / (2 eta)) "Tr"(H_T),
  $
  where $D_* = D_oo$ for diagonal AdaGrad and $D_* = D$ for full AdaGrad.

  #v(0.35em)

  Choosing $eta = D_* / sqrt(2)$ yields
  $
    "Regret"_T <= sqrt(2) D_* "Tr"(H_T).
  $

  #v(0.35em)

  Finally, Lemma 5.11 converts $"Tr"(H_T)$ back to the best hindsight metric:
  $
    "Tr"(H_T)
      = sqrt( min_(H in cal(H)_i) sum_(t=1)^T
          norm(nabla_t)_(H)^(* 2) ),
  $
  which is exactly Theorem 5.12.
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

== Exercise 1(a): Dual of a Matrix Norm

#[
#set text(size: 0.84em)

*Claim.* Let $A succ 0$ and define
$norm(x)_A := sqrt(x^top A x)$. Then its dual norm is
$ norm(y)_A^* = norm(y)_(A^(-1)) = sqrt(y^top A^(-1) y) . $

#proof[
  By definition,
  $
    norm(y)_A^*
      = sup_(norm(x)_A <= 1) x^top y .
  $
  Put $z = A^(1 / 2) x$, so $x = A^(-1 / 2) z$ and
  $norm(x)_A = norm(z)_2$. Hence
  $
    norm(y)_A^*
      &= sup_(norm(z)_2 <= 1) z^top A^(-1 / 2) y \
      &= norm(A^(-1 / 2) y)_2
       = sqrt(y^top A^(-1) y).
  $
  The supremum is attained in the direction
  $z = A^(-1 / 2)y \/ norm(A^(-1 / 2)y)_2$ when $y != 0$.
]
]

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

== Problem 5: Negative Entropy Setup

#[
  #set text(size: 0.78em)

  #definition([Setup])[
    The decision set is the $n$-dimensional simplex
    $
      Delta_n = { x in RR^n_(>= 0) : sum_(i=1)^n x_i = 1 },
    $
    and the regularizer is negative entropy
    $
      R(x) = sum_(i=1)^n x_i log x_i,
      quad 0 log 0 := 0 .
    $
  ]

  #v(0.35em)

  The Bregman divergence is
  $
    D_R(x, y)
      := R(x) - R(y) - chevron.l nabla R(y), x - y chevron.r .
  $
  Since $nabla R(y)_i = log y_i + 1$,
  $
    chevron.l nabla R(y), x - y chevron.r
      = sum_i (log y_i + 1)(x_i - y_i).
  $
]

== Problem 5: Bregman Divergence is KL

#[
  #set text(size: 0.78em)

  Substitute the previous identities into the Bregman divergence:
  $
    D_R(x, y)
      &= sum_i x_i log x_i - sum_i y_i log y_i
         - sum_i (log y_i + 1)(x_i - y_i) \
      &= sum_i x_i log(x_i / y_i) - sum_i x_i + sum_i y_i .
  $

  #v(0.35em)

  For $x, y in Delta_n$, the last two terms cancel, hence
  $
    D_R(x, y)
      = sum_i x_i log(x_i / y_i).
  $

  #v(0.4em)

  #theorem("Relative entropy")[
    $
      D_R(x, y)
        = "KL"(x || y)
        = sum_i x_i log(x_i / y_i).
    $
  ]

  #v(0.35em)

  This is the relative entropy geometry underlying multiplicative-weights
  style updates.
]

== Problem 5: Diameter Bound

#[
  #set text(size: 0.76em)

  For this exercise, the diameter is the range of the regularizer on the
  simplex:
  $
    D_R := max_(x in Delta_n) R(x) - min_(x in Delta_n) R(x).
  $

  #v(0.25em)

  #text(fill: red, weight: "bold")[
    Note: if we instead used $max_(x,y in Delta_n) D_R(x,y)$, the value would
    be infinite on the boundary whenever $y_i = 0$ and $x_i > 0$.
  ]

  #v(0.3em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1.1em,
    [
      *Minimum.* By convexity, the minimum occurs at the uniform point
      $u = (1/n, ..., 1/n)$:
      $
        R(u)
          = sum_i 1/n log(1/n)
          = -log n .
      $
    ],
    [
      *Maximum.* The maximum occurs at a vertex, say
      $e_1 = (1, 0, ..., 0)$:
      $
        R(e_1)
          = 1 log 1 + sum_(i != 1) 0 log 0
          = 0 .
      $
    ],
  )

  #v(0.35em)

  Therefore
  $
    D_R = 0 - (-log n) = log n .
  $

  #v(0.2em)

  #theorem("Diameter bound")[
    $
      D_R <= log n,
      quad "in fact" quad
      D_R = log n .
    $
  ]
]

== Problem 5: Projection Objective

#[
  #set text(size: 0.78em)

  Let $y in RR^n_(> 0)$ and project it onto the simplex:
  $
    x^star = arg min_(x in Delta_n) D_R(x, y).
  $

  #v(0.25em)

  From the previous calculation,
  $
    D_R(x, y)
      = sum_i x_i log(x_i / y_i) - sum_i x_i + sum_i y_i .
  $
  Since $x in Delta_n$, $sum_i x_i = 1$, and $sum_i y_i$ is constant in $x$.
  Thus the essential problem is
  $
    min_(x in Delta_n) sum_i x_i log(x_i / y_i).
  $
]

== Problem 5: Projection First-Order Condition

#[
  #set text(size: 0.78em)

  The Lagrangian for the constraint $sum_i x_i = 1$ is
  $
    cal(L)(x, lambda)
      = sum_i x_i log(x_i / y_i)
        + lambda (sum_i x_i - 1).
  $
  The first-order condition gives
  $
    (partial cal(L)) / (partial x_i)
      = log(x_i / y_i) + 1 + lambda = 0.
  $
  Hence $x_i / y_i = C$ for a constant $C$, so $x_i = C y_i$.
]

== Problem 5: Projection Formula

#[
  #set text(size: 0.82em)

  #v(0.35em)

  Enforcing $sum_i x_i = 1$ gives
  $
    C sum_i y_i = 1,
    quad
    C = 1 / norm(y)_1,
    quad
    x_i^star = y_i / norm(y)_1 .
  $

  #theorem("Projection formula")[
    $
      Pi_(Delta_n)^R (y) = y / norm(y)_1 .
    $
  ]

  #v(0.35em)

  Thus Bregman projection for negative entropy simply rescales a positive
  vector so that its coordinates sum to one.
]

== Problem 5: Takeaway

#[
  #set text(size: 0.82em)

  For the negative entropy regularizer
  $
    R(x) = sum_i x_i log x_i
  $
  on the simplex $Delta_n$:

  #v(0.35em)

  #theorem("Summary")[
    #grid(
      columns: (1.1fr, 4fr),
      column-gutter: 0.9em,
      row-gutter: 0.35em,
      [*Divergence.*],
      [
        $
          D_R(x, y) = "KL"(x || y) = sum_i x_i log(x_i / y_i).
        $
      ],
      [*Diameter.*],
      [
        $
          max_(x in Delta_n) R(x) - min_(x in Delta_n) R(x) = log n.
        $
      ],
      [*Projection.*],
      [
        $
          Pi_(Delta_n)^R(y) = y / norm(y)_1.
        $
      ],
    )
  ]

  #v(0.45em)

  *Interpretation.* In negative-entropy geometry, projecting a positive vector
  onto the simplex is not Euclidean projection. It is just normalization:
  divide by its $ell_1$ norm to return to a probability distribution.
]
