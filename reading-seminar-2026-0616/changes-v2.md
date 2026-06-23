# Changes in `main-v2.typ`

## Summary

This version updates only Section 2, **Adaptive Gradient Descent (AdaGrad)**. The proof flow and final regret rates are unchanged.

## Main Changes

- Added a technical convention slide for singular AdaGrad metrics, Moore-Penrose pseudoinverses, seminorms, and support-compatible dual quantities.
- Rewrote Algorithm 19 to use `H_t^\dagger` and the corrected diagonal metric `(diag G_t)^{1/2}`.
- Clarified the best hindsight metric slide with the support-compatible pseudoinverse convention and scale/shape separation.
- Added source typo notes for Theorem 5.12 and Lemma 5.13.
- Corrected Lemma 5.13's drift sum from `t = 0` to `t = 1`.
- Added the range argument `H_t H_t^\dagger \nabla_t = \nabla_t` before the one-step identity.
- Reformulated Proposition 5.16 with a support condition so singular PSD matrices are handled correctly.
- Corrected the diagonal trace-ball normalization in Proposition 5.16.
- Rewrote Lemma 5.14 using pseudoinverse equalities.
- Clarified diagonal and full-matrix monotonicity in Lemma 5.15.
- Added a final slide summarizing source corrections and technical caveats.

## Outputs

- Typst source: `main-v2.typ`
- Compiled PDF: `main-v2.pdf`
- Source correction list: `source-corrections-v2.md`
