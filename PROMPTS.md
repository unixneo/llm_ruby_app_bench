
---

# P0022: Max Flow Problem - Algorithm Selection

**Date:** 2026-04-17  
**Status:** Awaiting PI approval  
**Architect:** Claude

## Problem Description

**Maximum Flow Problem:**
- Given: Directed graph with source node s, sink node t, edge capacities c(u,v)
- Goal: Find maximum flow from source to sink
- Constraints: Flow on edge ≤ capacity, flow conservation at intermediate nodes
- Output: Maximum flow value and flow assignments on edges

**Classic network optimization problem** - ships data, water, traffic, etc.

## Reference Implementation

**Gem:** OR-Tools (already in project)
**Module:** `ORTools::SimpleMaxFlow`
**API:** `add_arc_with_capacity(tail, head, capacity)`, `solve(source, sink)`, `optimal_flow()`

## Algorithm Options

### Option A: Ford-Fulkerson with BFS (Edmonds-Karp)

**Description:** Augmenting path algorithm using BFS to find shortest paths
**Complexity:** O(VE²) worst case, O(VE·f) where f is max flow value
**Quality:** Always finds optimal maximum flow

**Advantages:**
- Well-defined exact algorithm
- BFS ensures shortest augmenting paths (faster than DFS)
- Clear correctness criterion (flow value matches OR-Tools)
- Tests corrections on network flow (different from routing/matching)
- Good conceptual fit (residual graph, augmenting paths)

**Disadvantages:**
- More complex than greedy (residual graph management)
- ~100-150 lines implementation
- Requires understanding of network flow concepts


### Option B: Push-Relabel Algorithm

**Description:** Pre-flow based algorithm with vertex height labeling
**Complexity:** O(V²E) best known bounds
**Quality:** Finds optimal maximum flow

**Advantages:**
- Often faster than Ford-Fulkerson in practice
- Different algorithmic paradigm (push/relabel vs augmenting paths)
- Interesting for testing LLM on advanced algorithms

**Disadvantages:**
- More complex implementation (~200+ lines)
- Harder to understand and debug
- Height functions and excess flow more abstract

### Option C: Dinic's Algorithm

**Description:** Uses level graphs and blocking flows
**Complexity:** O(V²E)
**Quality:** Finds optimal maximum flow

**Advantages:**
- Efficient in practice
- Good balance of complexity and performance
- Popular in competitive programming

**Disadvantages:**
- Blocking flow concept more advanced
- Similar implementation complexity to Push-Relabel
- Less standard than Ford-Fulkerson for teaching


## Recommendation

**Option A: Ford-Fulkerson with BFS (Edmonds-Karp)**

**Rationale:**
1. ✅ **Standard algorithm** - Most common teaching version of max flow
2. ✅ **Tests network flow concepts** - Different from routing (tours) and matching (assignment)
3. ✅ **Clear correctness** - Flow value must equal OR-Tools optimal
4. ✅ **Reasonable complexity** - ~100-150 lines, not trivial but manageable
5. ✅ **BFS ensures termination** - Unlike DFS variant which can loop infinitely on irrational capacities
6. ✅ **Good UI potential** - Network graph with flow visualization

**Comparison with previous algorithms:**
- TSP/VRP: Routing problems (tours, vehicles)
- Assignment: Bipartite matching (workers ↔ tasks)
- Max Flow: Network flow (source → sink through capacities)

This adds a third distinct problem structure to the OR-Tools family.

## Research Questions

If Edmonds-Karp implemented:
- Can LLM correctly build residual graph?
- Will it handle BFS for augmenting paths correctly?
- How will it manage flow updates and capacity checks?
- Does governance framework work for network algorithms?
- Will it properly detect when no augmenting path exists (termination)?


## Fixtures Needed

**5 test cases:**

1. **Simple 4-node network** (manual verification possible)
2. **Small 6-node network** (single bottleneck)
3. **Medium 8-node network** (multiple paths)
4. **Larger 12-node network** (complex topology)
5. **Dense 15-node network** (many edges)

Each fixture should have:
- Node count
- Edge list with capacities: [(from, to, capacity), ...]
- Source node (typically 0)
- Sink node (typically n-1)

**Example structure:**
```ruby
{
  name: "maxflow_simple_4",
  nodes: 4,
  edges: [
    [0, 1, 10],  # source → node1, capacity 10
    [0, 2, 5],   # source → node2, capacity 5
    [1, 3, 15],  # node1 → sink, capacity 15
    [2, 3, 10]   # node2 → sink, capacity 10
  ],
  source: 0,
  sink: 3
}
```

## Awaiting PI Decision

**Options:** A (Edmonds-Karp), B (Push-Relabel), or C (Dinic's)

**Please approve one option to proceed with P0022.**

