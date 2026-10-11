import Std

/- Retained-list storage model for checker_p24.rs: reserve only when a NEW
   declaration arrives. The ordered unique list is the semantic result; capacity is an
   implementation detail. Correspondence of DeclarationSet's membership
   table to list membership is covered by the existing Rust tests and review.
   The temporary hash table is not modeled here: it can grow on a duplicate
   at its load threshold, but its size still depends on the unique list.
   This is not a proof of the allocator or the whole checker. -/
namespace UniqueDeclarationStorage

structure Buffer where
  nodes : List Nat
  capacity : Nat
deriving DecidableEq

def empty : Buffer := ⟨[], 4⟩

def add (s : Buffer) (node : Nat) : Buffer :=
  if node ∈ s.nodes then s else
    ⟨s.nodes ++ [node], if s.nodes.length < s.capacity then s.capacity else 2 * s.capacity⟩

def appendUnique (nodes : List Nat) (node : Nat) : List Nat :=
  if node ∈ nodes then nodes else nodes ++ [node]

theorem add_preserves_order (s : Buffer) (node : Nat) :
    (add s node).nodes = appendUnique s.nodes node := by
  simp only [add, appendUnique]
  split <;> rfl

theorem duplicate_allocates_nothing (s : Buffer) (node : Nat)
    (present : node ∈ s.nodes) : add s node = s := by
  simp [add, present]

def Bounded (s : Buffer) : Prop :=
  4 ≤ s.capacity ∧ s.nodes.length ≤ s.capacity ∧
    s.capacity ≤ max 4 (2 * s.nodes.length)

theorem empty_bounded : Bounded empty := by simp [Bounded, empty]

theorem add_bounded (s : Buffer) (node : Nat) (h : Bounded s) :
    Bounded (add s node) := by
  unfold add
  split
  · exact h
  · unfold Bounded at *
    simp only [List.length_append, List.length_singleton]
    split <;> omega

theorem collect_preserves_order (input : List Nat) (s : Buffer) :
    (input.foldl add s).nodes = input.foldl appendUnique s.nodes := by
  induction input generalizing s with
  | nil => rfl
  | cons node rest ih =>
    simp only [List.foldl_cons]
    rw [ih, add_preserves_order]

theorem collect_bounded (input : List Nat) (s : Buffer) (h : Bounded s) :
    Bounded (input.foldl add s) := by
  induction input generalizing s with
  | nil => exact h
  | cons node rest ih =>
    exact ih (add s node) (add_bounded s node h)

-- The storage bound depends on UNIQUE declarations, regardless of how many
-- times the Cartesian product repeats them in the input.
theorem storage_depends_on_unique_count (input : List Nat) :
    (input.foldl add empty).capacity ≤
      max 4 (2 * (input.foldl appendUnique []).length) := by
  have h := (collect_bounded input empty empty_bounded).2.2
  rw [collect_preserves_order] at h
  exact h

#print axioms add_preserves_order
#print axioms duplicate_allocates_nothing
#print axioms collect_preserves_order
#print axioms storage_depends_on_unique_count

end UniqueDeclarationStorage
