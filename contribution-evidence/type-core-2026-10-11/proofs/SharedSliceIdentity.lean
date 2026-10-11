import Std

/- Same-length immutable slices with the same data pointer have identical
   TypeId elements. The Rust comparator skips equal TypeIds before calling
   compare_types. This model proves that their identity scan leaves state
   unchanged; Rust memory validity and pointer correspondence are reviewed
   in the implementation. No comparison-cache assumption is needed. -/
namespace SharedSliceIdentity

variable {Q R S : Type}

def directTrace (run : Q → S → R × S) : List Q → S → List R × S
  | [], s => ([], s)
  | q :: rest, s =>
    let (r, next) := run q s
    let (results, final) := directTrace run rest next
    (r :: results, final)

theorem self_comparisons_inert (run : (Q × Q) → S → Ordering × S)
    (identity : ∀ q s, run (q, q) s = (.eq, s))
    (types : List Q) (s : S) :
    directTrace run (types.map fun q => (q, q)) s =
      (List.replicate types.length .eq, s) := by
  induction types generalizing s with
  | nil => rfl
  | cons q rest ih => simp [directTrace, identity, ih, List.replicate_succ]

#print axioms self_comparisons_inert

end SharedSliceIdentity
