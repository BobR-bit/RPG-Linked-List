# RPG-Linked-List
With the eventual advent of auto or dynamic arrays in RPG my past effort in creating doubly linked lists in RPG is probably going to be for wastes.  However, I have never seen a truly dynamic linked list in RPG before mine.  It might be out there, but I was not able to find one when I was looking. 

Having a background in C, and all of it variants led me to desire linked lists back when I started writing RPG programs. 

I wrote my first linked list module in C back in the 1980’s, probably.

I used them extensively over the years and recreated a module in C on the iSeries many years ago.  I have used it in many C program on the ISeries over the years as well.

In all fairness I could very well have just used this module for my linked list in RPG.  But I wanted a more in-depth understanding of RPG pointers and especially RPG base pointers.  So, I recreated my linked list module in RPG back in 2024.

Now a linked list module can contain many procedures to do many things.  I created mine with procedures that meet the way I have come to use them over the years.  I add data to the list sorted rather than have a procedure to sort the list after the fact.  I also choose to have the calling program maintain the Root and allocate memory for the data.  RPG and C are not object languages and it just seems to better fit for non-object languages.

Anyway, keep that in mind when you choose to critique it.  I also wrote my own version or memory copy and memory compare.  I will share that some day as well.  For now, here is a truly dynamic linked list module.   If anyone thinks it would be useful, your more then welcome to hack away.

# LINKED LIST UTILITIES (ILE RPG)

Comprehensive documentation for the pointer-based, doubly-linked list implementation and its prototypes and tests.

Copyright (c) 2024, Bob Richardson. All Rights Reserved.

---

## Files
| Member | Purpose |
|--------|---------|
| `linklistpr.rpgle` | Public procedure prototypes (interface contract). |
| `linklistr.rpgle`  | Implementation module (exported procedures, `nomain`). |
| `linklistt.rpgle`  | Test harness validating core operations. |
| `COMMONPR` (copy)  | Referenced for common prototypes (not supplied here). |

Binder directories used: `QC2LE` (C runtime) and `WYNBOB/WYNBOB` (custom services).

## Node Structure
Implementation defines a doubly-linked node layout (qualified DS based on pointer):
```rpg
dcl-ds Node qualified based(p);
  Data_p pointer;  // pointer to caller-managed payload
  Prev_n pointer;  // previous node (NULL for root)
  Next_n pointer;  // next node (NULL for tail)
end-ds;
```
Internally every procedure that manipulates nodes declares one or more DS instances based on working pointers (`RootPtr`, `NodePtr`, `CurNodePtr`, etc.).

## API Reference
| Procedure | Defined In | Return | Summary |
|-----------|------------|--------|---------|
| `CreateLinkedList(Data)` | `linklistr.rpgle` | pointer | Allocates a single node initialized with payload pointer `Data`. Returns node pointer or *NULL. |
| `AddLinkedListEntry(RootPtr:Data)` | impl | pointer | If list absent, creates it; else finds tail, allocates new node, links `Prev_n`/`Next_n`. Returns pointer to new node (tail). |
| `AddLinkedListEntrySorted(RootPtr:Data:Size:ResetRootPtr)` | impl | pointer | Inserts new node maintaining ascending order using `myrpg_memcmp(Data:CurNode.Data_p:Size)`. Signals head change by setting indicator at `ResetRootPtr` to *ON. Allocates and links in middle or front; delegates end-of-list case to `AddLinkedListEntry`. Returns inserted node. |
| `FindLinkedListEntry(RootPtr:Data:Size)` | impl | pointer | Linear search from root; uses `myrpg_memcmp(Node.Data_p:Data:Size)` comparing up to `Size` bytes; returns matching node pointer or *NULL. |
| `DeleteLinkedListEntry(CurNodePtr:ResetRootPtr)` | impl | pointer | Removes specified node; adjusts neighbor links. If deleting first node, sets indicator at `ResetRootPtr` to *ON and makes next node new root. Frees payload (`CurNode.Data_p`) and node storage via `dealloc`. Returns adjacent node pointer (prev if exists else next). |
| `DeleteLinkedList(RootPtr)` | impl | ind | Walks list deleting each node via `DeleteLinkedListEntry`; ignores reset indicator internally. Returns *ON on completion. |

### Comparator Semantics
Sorting and searching rely on `myrpg_memcmp` (present in implementation, commented-out prototype in interface file). Behavior assumed analogous to C `memcmp`: returns <0, 0, >0 depending on lexical ordering of bytes. Key length is `Size` bytes—caller must ensure keys are stable and comparable. The test program currently does not call `myrpg_memcmp`; it uses pointer equality for find (prototype version); implementation uses `myrpg_memcmp` even for find.

### Root Reset Indicator Pattern
Procedures that can change head accept `ResetRootPtr` (pointer to an IND). Implementation maps it with `dcl-s ResetRoot ind based(ResetRootPtr)`. On head change it sets `ResetRoot = *on`; caller then:
```rpg
if ResetRoot;
  RootPtr = ReturnedNodePtr;
  ResetRoot = *off;
endif;
```
This indirect signaling avoids extra return codes while keeping interface stable.

## Memory Management
Allocation: `%alloc(%size(Node))` for nodes; caller allocates data payload separately and passes pointer.
Deallocation: `DeleteLinkedListEntry` frees both `Data_p` and node (`dealloc(n) pointer`). Full list deletion iteratively frees nodes.
Important:
* After deletion, implementation sets `CurNodePtr = *NULL` to mitigate dangling pointers.
* Caller must not attempt to reuse freed `Data_p`.
* `AddLinkedListEntrySorted` does not deep copy data; ensure lifetime of payload pointer spans list usage.

### Link Adjustment Diagrams
Insertion at front (sorted insert new minimum):
```
Before:
   [NewData] <comparison> [OldRoot]
   OldRoot.Prev_n = *NULL

After allocation & link:
   NewNode -> Next_n = OldRoot
   NewNode.Prev_n = *NULL
   OldRoot.Prev_n = NewNode
   (ResetRoot = *ON)

List:
   [NewNode] <-> [OldRoot] <-> [...]
```

Deletion of middle node (Prev_n and Next_n non-null):
```
PrevNode.Next_n ----+        +---- NextNode.Prev_n
                              v        v
   [PrevNode] <-> [CurNode] <-> [NextNode]

After:
   PrevNode.Next_n = NextNode
   NextNode.Prev_n = PrevNode
   Free CurNode.Data_p; Free CurNode

Result:
   [PrevNode] <-> [NextNode]
```

Deletion of first (root) node (Prev_n = *NULL, Next_n not null):
```
Before: [Root] -> [Second]
             Root.Prev_n = *NULL
             Root.Next_n = Second

After:
   Second.Prev_n = *NULL
   Free Root
   (ResetRoot = *ON; caller sets RootPtr = Second)
```

## Algorithmic Complexity
| Operation | Complexity |
|-----------|-----------|
| Create | O(1) |
| Append | O(n) (tail search) |
| Sorted Insert | O(n) (search for insertion point) |
| Find | O(n) linear |
| Delete (known node) | O(1) link adjustment |
| Delete List | O(n) |

Potential Improvement: Maintain tail pointer and node count for O(1) append and size queries.

## Test Harness Summary (`linklistt.rpgle`)
Data structure:
```rpg
dcl-ds TestData qualified;
  id int(10);
  name char(10);
end-ds;
```
Each test allocates new data block (`%alloc`) and copies bytes via `myrpg_memcpy`. Test cases executed:
| # | Case | Validates |
|---|------|-----------|
| 1 | Create | Initial node allocation. |
| 2 | Append id=2 | Tail insertion. |
| 3 | Find id=2 | Successful search (by pointer in test). |
| 4 | Sorted insert id=0 | Head insertion + indicator set. |
| 5 | Append id=3 | Further tail insertion post-sort. |
| 6 | Delete middle (id=2) | Correct relinking; return pointer semantics. |
| 7 | Find id=1 | Persistence of earlier node. |
| 8 | Find id=3 | Persistence of tail node. |
| 9 | Delete list | Full teardown. |
Results tallied and displayed via `DSPLY`.

## Compilation & Binding (IBM i)
Replace `MYLIB` with your library. Source file assumed `QRPGLESRC` or `SRCFILE` as shown.
```text
CRTRPGMOD MODULE(MYLIB/LINKLISTR)  SRCFILE(MYLIB/QRPGLESRC) SRCMBR(LINKLISTR)
CRTRPGMOD MODULE(MYLIB/COMMMON)  SRCFILE(MYLIB/QRPGLESRC) SRCMBR(COMMON)
CRTSRVPGM SRVPGM(MYLIB/LINKLISTSRV) MODULE(MYLIB/LINKLISTR MYLIB/COMMON) EXPORT(*ALL)
ADDBNDDIRE BNDDIR(MYLIB/MYBNDDIR) OBJ((MYLIB/LINKLISTSRV *SRVPGM))
CRTRPGMOD MODULE(MYLIB/LINKLISTT)  SRCFILE(MYLIB/QRPGLESRC) SRCMBR(LINKLISTT)
CRTPGM PGM(MYLIB/LINKLISTT) MODULE(MYLIB/LINKLISTT) BNDDIR(MYLIB/MYBNDDIR)
CALL PGM(MYLIB/LINKLISTT)
```
Or

CRTRPGMOD MODULE(MYLIB/LINKLISTR)  SRCFILE(MYLIB/QRPGLESRC) SRCMBR(LINKLISTR)
CRTRPGMOD MODULE(MYLIB/COMMMON)  SRCFILE(MYLIB/QRPGLESRC) SRCMBR(COMMON)
CRTPGM PGM(MYLIB/LINKLISTT) MODULE(MYLIB/LINKLISTT MYLIB/LINKLISTR MYLIB/COMMON)
CALL PGM(MYLIB/LINKLISTT)


## Known Issues / Observations
* `AddLinkedListEntry` references `NodePtr` without an explicit `dcl-s NodePtr pointer;` (implicit via later usage?) Ensure variable declared; else add it.
* Case differences (`CreateLinkedlist`, `AddlinkedListEntry`) appear in implementation; RPG is case-insensitive but maintain consistent spelling for readability.
* `FindLinkedListEntry` in test uses pointer equality; implementation uses `myrpg_memcmp` — confirm test expectations align with implementation comparison logic.
* `DeleteLinkedList` does not check return value from `DeleteLinkedListEntry`; assumes success. Consider aggregating failures.
* No explicit error/status propagation beyond *NULL and indicator; may add status DS for richer diagnostics.

### Refactor Checklist (Suggested Next Steps)
1. Declare missing `NodePtr` in `AddLinkedListEntry` for clarity.
2. Standardize procedure name casing (`CreateLinkedList`, `AddLinkedListEntry`, etc.).
3. Export `myrpg_memcmp` in prototypes (uncomment & adjust) for consistency.
4. Introduce tail pointer caching (add `TailPtr` parameter or maintain in root wrapper structure).
5. Maintain node count (increment/decrement on add/delete) to offer O(1) size.
6. Add status DS (e.g., error code, reason) returned by procedures or set via pointer parameter.
7. Provide iterator helpers (`FirstNode(root)` / `NextNode(node)`).
8. Add deep-copy insert variant to decouple lifetime of caller data.
9. Wrap memory operations to centralize allocation failure handling.
10. Convert test harness to automated assertion framework (counts only, optional logging service program).

Sorting (`AddLinkedListEntrySorted`) compares new data against current node data using this routine. Searching (`FindLinkedListEntry`) compares each node's payload to target data.

To ensure correctness:
1. Guarantee both payloads point to at least `Size` bytes.
2. Use stable key region (avoid transient fields like timestamps).
3. For structured records, place key fields first or create a separate contiguous key buffer.
4. Avoid using variable-length data unless normalized to fixed-size region.


## Extensibility Ideas
1. Tail pointer & node count cache.
2. Iterator API: `FirstNode(root)` / `NextNode(node)`.
3. Predicate-based search (function pointer or strategy DS).
4. Optional deep-copy insert variant.
5. Memory pool / slab allocator for reduced fragmentation.
6. Export `myrpg_memcmp` prototype in `linklistpr.rpgle` (uncomment lines) to align interface with implementation.
7. Convert test harness to automated assertion framework (store results in a DS, return counts instead of DSPLY messages).

## Error Handling Suggestions
Wrap API calls with small helpers that set application-level status codes; integrate with IBM i messages (`QMHSNDPM`) for logging if needed.

## Maintenance
Maintain modification logs at top of each member. Update README when adding procedures or altering semantics (e.g., switching comparator, adding deep copy).

## License
All rights reserved; internal use only unless explicitly relicensed.

---
README regenerated with implementation details and test context (October 29, 2025).

This member (`linklistpr.rpgle`) defines the ILE RPG procedure prototypes for a small pointer‑based linked list utility set. It is intended to be included (via `/COPY` or binder source) in modules that implement or consume linked list operations on IBM i.

> Copyright (c) 2024, Bob Richardson. All Rights Reserved.

## Contents
The file currently declares these procedures:

| Procedure | Returns | Purpose |
|-----------|---------|---------|
| `CreateLinkedList` | `pointer` | Initialize a new (empty) linked list anchor/root structure and return its pointer. |
| `AddLinkedListEntry` | `pointer` | Append a new node (containing the passed `Data`) to the tail of the list whose root is `Root`. Returns pointer to the new node (or updated root). |
| `AddLinkedListEntrySorted` | `pointer` | Insert `DataPtr` into the list pointed to by `RootPtr` keeping list sorted by a key of length `Size`. Optionally resets a base pointer (`ResetBasePtr`) after structural changes. Returns pointer to the inserted node. |
| `FindLinkedListEntry` | `pointer` | Search from `RootPtr` for a node whose data matches `Data` for `Size` bytes. Returns pointer to the matching node or *NULL if not found. |
| `DeleteLinkedListEntry` | `pointer` | Remove the node at `Node` from the list; may adjust `ResetBasePtr` if it pointed to the deleted node. Returns pointer to the next logical node (or updated root). |
| `DeleteLinkedList` | `ind` (indicator) | Delete (free) the entire linked list starting at `Root`. Returns *ON if success, *OFF on failure. |
| `myrpg_memcmp` (commented) | `int(10)` | Optional external comparison routine for raw memory blocks; currently commented out. |

## Assumed Node Layout
Although the implementation source isn’t included here, a conventional node layout would be:
```rpg
dcl-ds NodeTemplate qualified based(template);
   Next     pointer;       // forward link
   DataPtr  pointer;       // pointer to user data payload
end-ds;
```
`CreateLinkedList` may either allocate a dummy root node or simply return *NULL to indicate an empty list; adapt calls based on your actual implementation.

## Parameter Semantics
| Parameter | Direction | Description |
|-----------|-----------|-------------|
| `Root` / `RootPtr` | input/output | Pointer to the head/root of the list. Some procedures may return a (possibly new) root if structure changes. |
| `Data` / `DataPtr` | input | Pointer to caller-managed data buffer (record, DS, etc.) to store or compare. The list stores the pointer; caller owns lifecycle unless implementation copies content. |
| `Size` | input | Unsigned size (bytes) used for comparisons when sorting or finding. |
| `Node` | input | Pointer to an existing node targeted for deletion. |
| `ResetBasePtr` | input/output | Pointer variable that should stay synchronized with part of the list (e.g., a cached traversal position); procedures update it when structural changes could invalidate its value. |

## Return Values
- Procedures returning `pointer`: *NULL (or `*ZERO`) indicates allocation/search failure or an empty result.
- `DeleteLinkedList` returning `ind`: *ON for success, *OFF for partial or failed cleanup.

## Usage Example
Below is a conceptual free-form RPG snippet that consumes these prototypes (adjust binding to your service program / module names):
```rpg
ctl-opt dftactgrp(*no) actgrp(*new);

/copy PUBLIC/SRCFILE,LINKLISTPR   // or appropriate copy member reference

dcl-s root pointer inz(*null);
dcl-s node pointer;
dcl-s dataDs char(64) inz('Customer 123');
dcl-s rootReset ind inz(*off);
dcl-s rootResetPtr pointer based(rootReset);


// Create list (if API expects an explicit root structure)
root = CreateLinkedList(dataDs); // or CreateLinkedList(*null) depending on impl

// Add unsorted entry
node = AddLinkedListEntry(root: %addr(dataDs));

// Add sorted entry (assuming key length 20)
node = AddLinkedListEntrySorted(root: %addr(dataDs): %size(dataDs): rootResetPtr);

// Find entry
node = FindLinkedListEntry(root: %addr(dataDs): %size(dataDs));
if node <> *null;
   // process found node
endif;

// Delete a single entry
node = DeleteLinkedListEntry(node: root);

// Delete entire list
if DeleteLinkedList(root);
   // success
endif;
```
## Memory Management Notes
- Ensure every allocated node is freed in `DeleteLinkedList`; use `CEE4RADD` / `CEE4DLAB` or `%ALLOC` / `%DEALLOC` as implemented.
- Avoid double-free: set pointers to *NULL after deletion.
- If `ResetBasePtr` tracks traversal state, always check it for *NULL after operations modifying head or targeted node.

## Error Handling Recommendations
Since prototypes return raw pointers or an indicator, you can layer simple wrappers:
```rpg
if node = *null;
   // log failure: allocation or search miss
endif;
```
## Contributing / Maintenance
Track changes in the modification log header. When adding procedures:
1. Update this README table.
2. Bump copyright year if needed.
3. Document parameter and return semantics.

## License
All rights reserved; internal use only unless explicitly relicensed.

---
Generated README to accompany `linklistpr.rpgle` prototype definitions.

