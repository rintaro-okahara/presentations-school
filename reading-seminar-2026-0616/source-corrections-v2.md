# Source Corrections and Technical Caveats

Checked against Hazan, *Introduction to Online Convex Optimization*, 2nd ed., arXiv:1909.05207v3, Section 5.6.

## 1. Algorithm 19, Diagonal Metric

Source prints:

```tex
\operatorname{diag}(G_t^{1/2})
```

Corrected form:

```tex
(\operatorname{diag} G_t)^{1/2}
```

The diagonal optimization separates by coordinate:

```tex
\min_{h_i \ge 0} \left\{ \frac{(G_t)_{ii}}{h_i} + h_i \right\},
```

so the optimizer is `h_i = sqrt((G_t)_{ii})`.

## 2. Theorem 5.12, Learning Rate

The source theorem statement prints `eta = D_*`, where `D_*` is `D_infty` for diagonal AdaGrad and `D` for full-matrix AdaGrad.

For the displayed `sqrt(2) D_*` bound, the corrected value is:

```tex
\eta = D_* / \sqrt{2}.
```

This is also the value used by direct minimization of `eta + D_*^2/(2 eta)` and by the source proof.

## 3. Lemma 5.13, Drift Index

Source prints:

```tex
\sum_{t=0}^T
```

Corrected form:

```tex
\sum_{t=1}^T
```

The `t = 0` form would require undefined quantities `x_0` and `H_{-1}`.

## 4. Proposition 5.16, Diagonal Normalization

For the diagonal trace-ball problem, the source denominator is:

```tex
\operatorname{Tr}(A^{1/2})
```

Corrected denominator:

```tex
\operatorname{Tr}((\operatorname{diag} A)^{1/2})
```

## 5. Proposition 5.16, Singular PSD Matrices

With an unrestricted Moore-Penrose inverse over `X >= 0`, the choice `X = 0` gives

```tex
A \bullet X^\dagger + \operatorname{Tr}(X) = 0
```

even for nonzero `A`, contradicting the stated optimizer.

The corrected formulation uses a support condition:

```tex
\operatorname{Range}(A) \subseteq \operatorname{Range}(X)
```

Equivalently, one may use an extended-value convention for the dual seminorm or take a positive-definite approximation followed by a limit.

## Consequence

After these corrections, Theorem 5.12 has the same final regret bound:

```tex
\operatorname{Regret}_T \le \sqrt{2} D_* \operatorname{Tr}(H_T).
```

The sparse-coordinate example still gives the same `sqrt(d)` improvement over the OGD upper bound.
