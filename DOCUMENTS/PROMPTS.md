
---

# P0022: Max Flow Problem Implementation

**Date:** 2026-04-17  
**Status:** Ready for implementation  
**Architect:** Claude  
**Algorithm:** Edmonds-Karp (Ford-Fulkerson with BFS) - PI approved Option A

## Problem Statement

Implement the Maximum Flow Problem solver using the Edmonds-Karp algorithm (Ford-Fulkerson with BFS for augmenting paths).

**Problem definition:**
- Input: Directed graph with nodes, edges with capacities, source node, sink node
- Goal: Find maximum flow from source to sink
- Constraints: Flow on edge ≤ capacity, flow conservation at intermediate nodes (except source/sink)
- Output: Maximum flow value and flow assignments on edges

**Complexity:** O(VE²) - exact optimal solution

## Algorithm: Edmonds-Karp

**Overview:**
The Edmonds-Karp algorithm is a specific implementation of the Ford-Fulkerson method that uses BFS to find augmenting paths. It guarantees polynomial time complexity by always choosing the shortest augmenting path.

**Key concepts:**
- **Residual graph:** For each edge (u,v) with capacity c and flow f, residual graph has:
  * Forward edge (u,v) with residual capacity c-f
  * Backward edge (v,u) with residual capacity f
- **Augmenting path:** Path from source to sink in residual graph with positive capacity
- **Bottleneck capacity:** Minimum residual capacity along augmenting path
- **Flow augmentation:** Increase flow along path by bottleneck amount


**Algorithm steps:**

1. **Initialize flow:** Set flow on all edges to 0

2. **Build residual graph:**
   - For each edge (u,v) with capacity c and current flow f:
     * Add forward edge (u,v) with residual capacity c-f
     * Add backward edge (v,u) with residual capacity f
   - Only include edges with positive residual capacity

3. **Find augmenting path using BFS:**
   - Start from source
   - Use BFS to find shortest path to sink in residual graph
   - Track parent pointers to reconstruct path
   - If no path exists, algorithm terminates (optimal found)

4. **Calculate bottleneck capacity:**
   - Find minimum residual capacity along the path found

5. **Augment flow:**
   - For each edge on the path:
     * If forward edge: increase flow by bottleneck
     * If backward edge: decrease flow by bottleneck

6. **Repeat steps 2-5** until no augmenting path exists

**Termination:** When BFS cannot find path from source to sink, current flow is maximum

**Reference materials:**
- Cormen, Leiserson, Rivest, Stein "Introduction to Algorithms" Chapter 26
- Wikipedia "Edmonds-Karp algorithm" for implementation details
- Ford & Fulkerson original 1956 paper


## Test Fixtures

Create 5 max flow fixtures in `db/seeds.rb`:

### Fixture 1: maxflow_simple_4
```ruby
{
  name: "maxflow_simple_4",
  nodes: 4,
  edges: [
    [0, 1, 10],   # source → node1, capacity 10
    [0, 2, 5],    # source → node2, capacity 5
    [1, 3, 15],   # node1 → sink, capacity 15
    [2, 3, 10]    # node2 → sink, capacity 10
  ],
  source: 0,
  sink: 3,
  description: "Simple 4-node network, manual verification possible (max flow = 15)"
}
```
**Expected:** Max flow = 15 (both paths fully utilized: 10 via node1, 5 via node2)

### Fixture 2: maxflow_bottleneck_6
```ruby
{
  name: "maxflow_bottleneck_6",
  nodes: 6,
  edges: [
    [0, 1, 16],
    [0, 2, 13],
    [1, 3, 12],
    [2, 1, 4],
    [2, 4, 14],
    [3, 2, 9],
    [3, 5, 20],
    [4, 3, 7],
    [4, 5, 4]
  ],
  source: 0,
  sink: 5,
  description: "Classic 6-node network with bottleneck at sink"
}
```


### Fixture 3: maxflow_parallel_8
```ruby
{
  name: "maxflow_parallel_8",
  nodes: 8,
  edges: [
    [0, 1, 10], [0, 2, 10], [0, 3, 10],  # Source splits 3 ways
    [1, 4, 8], [1, 5, 5],
    [2, 4, 5], [2, 5, 8],
    [3, 6, 10],
    [4, 7, 10],
    [5, 7, 10],
    [6, 7, 10]
  ],
  source: 0,
  sink: 7,
  description: "Multiple parallel paths with varying capacities"
}
```

### Fixture 4: maxflow_complex_12
```ruby
{
  name: "maxflow_complex_12",
  nodes: 12,
  edges: [
    [0, 1, 15], [0, 2, 10], [0, 3, 8],
    [1, 4, 12], [1, 5, 7],
    [2, 5, 9], [2, 6, 8],
    [3, 6, 11], [3, 7, 6],
    [4, 8, 10], [4, 9, 8],
    [5, 8, 7], [5, 9, 9], [5, 10, 5],
    [6, 9, 6], [6, 10, 8],
    [7, 10, 12],
    [8, 11, 15],
    [9, 11, 18],
    [10, 11, 14]
  ],
  source: 0,
  sink: 11,
  description: "Complex 12-node network with many intermediate paths"
}
```


### Fixture 5: maxflow_dense_15
```ruby
{
  name: "maxflow_dense_15",
  nodes: 15,
  edges: [
    # Layer 1: source to 3 nodes
    [0, 1, 20], [0, 2, 18], [0, 3, 16],
    # Layer 2: interconnected middle layer
    [1, 4, 12], [1, 5, 10], [1, 6, 8],
    [2, 4, 10], [2, 5, 12], [2, 7, 9],
    [3, 6, 11], [3, 7, 13], [3, 8, 7],
    # Layer 3: more interconnections
    [4, 9, 15], [4, 10, 10],
    [5, 9, 8], [5, 10, 12], [5, 11, 9],
    [6, 10, 7], [6, 11, 11], [6, 12, 8],
    [7, 11, 10], [7, 12, 13],
    [8, 12, 15], [8, 13, 9],
    # Layer 4: to sink
    [9, 14, 20],
    [10, 14, 18],
    [11, 14, 16],
    [12, 14, 19],
    [13, 14, 12]
  ],
  source: 0,
  sink: 14,
  description: "Dense 15-node network with multiple layers"
}
```


## Rails Implementation Requirements

### 1. Database Model: `MaxFlowProblem`

**Migration:**
```ruby
class CreateMaxFlowProblems < ActiveRecord::Migration[7.2]
  def change
    create_table :max_flow_problems do |t|
      t.string :name, null: false, index: { unique: true }
      t.integer :nodes, null: false
      t.text :edges, null: false  # JSON serialized: [[from, to, capacity], ...]
      t.integer :source, null: false
      t.integer :sink, null: false
      t.text :description
      t.timestamps
    end
  end
end
```

**Model (`app/models/max_flow_problem.rb`):**
```ruby
class MaxFlowProblem < ApplicationRecord
  serialize :edges, coder: JSON
  
  validates :name, presence: true, uniqueness: true
  validates :nodes, :source, :sink, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :valid_edges_structure
  validate :source_and_sink_in_range
  
  private
  
  def valid_edges_structure
    return unless edges.is_a?(Array)
    unless edges.all? { |e| e.is_a?(Array) && e.length == 3 && e.all? { |v| v.is_a?(Integer) } }
      errors.add(:edges, "must be array of [from, to, capacity] triples")
    end
  end
  
  def source_and_sink_in_range
    errors.add(:source, "must be in range [0, #{nodes-1}]") unless source.between?(0, nodes-1)
    errors.add(:sink, "must be in range [0, #{nodes-1}]") unless sink.between?(0, nodes-1)
    errors.add(:sink, "cannot equal source") if source == sink
  end
end
```


### 2. Solver Service: `MaxFlowSolver`

**File:** `app/services/max_flow_solver.rb`

**Interface:**
```ruby
class MaxFlowSolver
  def initialize(nodes, edges, source, sink)
    @nodes = nodes
    @edges = edges  # Array of [from, to, capacity]
    @source = source
    @sink = sink
  end
  
  def solve
    # Returns: { max_flow: value, flow_edges: [[from, to, flow], ...] }
    # Example: { max_flow: 23, flow_edges: [[0,1,10], [0,2,13], [1,3,10], ...] }
  end
end
```

**Implementation requirements:**
- Pure Ruby implementation (no external gems except standard library)
- Edmonds-Karp algorithm with BFS for augmenting paths
- Build residual graph dynamically
- Use BFS to find shortest augmenting path
- Track parent pointers for path reconstruction
- Augment flow along path by bottleneck capacity
- Return maximum flow value and flow on each edge

**Edge cases:**
- Source has no outgoing edges (max flow = 0)
- Sink has no incoming edges (max flow = 0)
- No path from source to sink (max flow = 0)
- Multiple edges between same nodes (treat as separate edges)
- Self-loops (should not affect max flow)


### 3. Reference Solver: `GemMaxFlowSolver`

**File:** `app/services/gem_max_flow_solver.rb`

**Use OR-Tools SimpleMaxFlow:**
```ruby
require "or_tools"

class GemMaxFlowSolver
  def initialize(nodes, edges, source, sink)
    @nodes = nodes
    @edges = edges
    @source = source
    @sink = sink
  end
  
  def solve
    max_flow = ORTools::SimpleMaxFlow.new
    
    # Add all edges with capacities
    @edges.each do |from, to, capacity|
      max_flow.add_arc_with_capacity(from, to, capacity)
    end
    
    # Solve
    status = max_flow.solve(@source, @sink)
    
    if status == :optimal
      flow_value = max_flow.optimal_flow
      
      # Extract flow on each edge
      flow_edges = @edges.map do |from, to, capacity|
        flow = max_flow.flow(max_flow.get_arc_index(from, to))
        [from, to, flow]
      end
      
      { max_flow: flow_value, flow_edges: flow_edges }
    else
      { max_flow: 0, flow_edges: [], error: "No solution found" }
    end
  end
end
```

**Note:** OR-Tools SimpleMaxFlow API uses `add_arc_with_capacity(tail, head, capacity)`


### 4. Validation Service: `MaxFlowSolutionValidator`

**File:** `app/services/max_flow_solution_validator.rb`

**Validations:**
1. **Flow conservation:** For each node except source/sink, inflow = outflow
2. **Capacity constraints:** Flow on edge ≤ capacity for all edges
3. **Non-negativity:** Flow on all edges ≥ 0
4. **Source flow:** Total outflow from source = reported max flow
5. **Sink flow:** Total inflow to sink = reported max flow

```ruby
class MaxFlowSolutionValidator
  def self.validate(nodes, edges, source, sink, flow_edges, reported_max_flow)
    errors = []
    
    # Build flow map
    flow_map = {}
    flow_edges.each do |from, to, flow|
      flow_map[[from, to]] = flow
      errors << "Negative flow on edge (#{from}, #{to}): #{flow}" if flow < 0
    end
    
    # Check capacity constraints
    edges.each do |from, to, capacity|
      flow = flow_map[[from, to]] || 0
      errors << "Flow exceeds capacity on edge (#{from}, #{to}): #{flow} > #{capacity}" if flow > capacity
    end
    
    # Check flow conservation (excluding source and sink)
    (0...nodes).each do |node|
      next if node == source || node == sink
      
      inflow = edges.select { |_, to, _| to == node }.sum { |from, to, _| flow_map[[from, to]] || 0 }
      outflow = edges.select { |from, _, _| from == node }.sum { |from, to, _| flow_map[[from, to]] || 0 }
      
      unless (inflow - outflow).abs < 0.01
        errors << "Flow conservation violated at node #{node}: inflow=#{inflow}, outflow=#{outflow}"
      end
    end
    
    # Verify max flow value
    source_outflow = edges.select { |from, _, _| from == source }.sum { |from, to, _| flow_map[[from, to]] || 0 }
    sink_inflow = edges.select { |_, to, _| to == sink }.sum { |from, to, _| flow_map[[from, to]] || 0 }
    
    errors << "Max flow mismatch: reported=#{reported_max_flow}, source_outflow=#{source_outflow}" unless (source_outflow - reported_max_flow).abs < 0.01
    errors << "Max flow mismatch: sink_inflow=#{sink_inflow}, source_outflow=#{source_outflow}" unless (sink_inflow - source_outflow).abs < 0.01
    
    { valid: errors.empty?, errors: errors, source_outflow: source_outflow, sink_inflow: sink_inflow }
  end
end
```


### 5. Comparison Service: `MaxFlowResultComparison`

**File:** `app/services/max_flow_result_comparison.rb`

**Compare candidate vs reference:**
```ruby
class MaxFlowResultComparison
  def self.compare(candidate_result, reference_result)
    {
      flow_difference: candidate_result[:max_flow] - reference_result[:max_flow],
      flow_ratio: candidate_result[:max_flow].to_f / reference_result[:max_flow],
      is_optimal: (candidate_result[:max_flow] - reference_result[:max_flow]).abs < 0.01,
      candidate_max_flow: candidate_result[:max_flow],
      reference_max_flow: reference_result[:max_flow],
      candidate_flow_edges: candidate_result[:flow_edges],
      reference_flow_edges: reference_result[:flow_edges]
    }
  end
end
```

### 6. Runner Service: `MaxFlowAttemptRunner`

**File:** `app/services/max_flow_attempt_runner.rb`

**Run all fixtures:**
```ruby
class MaxFlowAttemptRunner
  def self.run_all
    MaxFlowProblem.all.map do |problem|
      run_single(problem)
    end
  end
  
  def self.run_single(problem)
    candidate = MaxFlowSolver.new(problem.nodes, problem.edges, problem.source, problem.sink).solve
    reference = GemMaxFlowSolver.new(problem.nodes, problem.edges, problem.source, problem.sink).solve
    
    validation = MaxFlowSolutionValidator.validate(
      problem.nodes,
      problem.edges,
      problem.source,
      problem.sink,
      candidate[:flow_edges],
      candidate[:max_flow]
    )
    
    comparison = MaxFlowResultComparison.compare(candidate, reference)
    
    {
      problem: problem.name,
      candidate: candidate,
      reference: reference,
      validation: validation,
      comparison: comparison
    }
  end
end
```


## Test Requirements

### Unit Tests

**File:** `test/services/max_flow_solver_test.rb`

```ruby
require "test_helper"

class MaxFlowSolverTest < ActiveSupport::TestCase
  test "solves simple 4-node problem" do
    edges = [[0, 1, 10], [0, 2, 5], [1, 3, 15], [2, 3, 10]]
    result = MaxFlowSolver.new(4, edges, 0, 3).solve
    
    assert_not_nil result[:max_flow]
    assert_equal 15, result[:max_flow]  # 10 via node1 + 5 via node2
  end
  
  test "finds optimal solution for bottleneck problem" do
    problem = max_flow_problems(:maxflow_bottleneck_6)
    candidate = MaxFlowSolver.new(problem.nodes, problem.edges, problem.source, problem.sink).solve
    reference = GemMaxFlowSolver.new(problem.nodes, problem.edges, problem.source, problem.sink).solve
    
    assert_equal reference[:max_flow], candidate[:max_flow], "Flow should match optimal"
  end
  
  test "produces valid flow" do
    problem = max_flow_problems(:maxflow_complex_12)
    result = MaxFlowSolver.new(problem.nodes, problem.edges, problem.source, problem.sink).solve
    validation = MaxFlowSolutionValidator.validate(
      problem.nodes,
      problem.edges,
      problem.source,
      problem.sink,
      result[:flow_edges],
      result[:max_flow]
    )
    
    assert validation[:valid], "Flow should be valid: #{validation[:errors]}"
  end
  
  test "handles no path from source to sink" do
    edges = [[0, 1, 10], [2, 3, 10]]  # Disconnected
    result = MaxFlowSolver.new(4, edges, 0, 3).solve
    
    assert_equal 0, result[:max_flow]
  end
end
```

**Additional test files:**
- `test/models/max_flow_problem_test.rb` - Model validations
- `test/services/gem_max_flow_solver_test.rb` - Reference solver
- `test/services/max_flow_solution_validator_test.rb` - Validator logic
- `test/services/max_flow_result_comparison_test.rb` - Comparison logic


## Success Criteria

1. ✅ **All 5 fixtures pass validation** - Flows satisfy conservation, capacity, non-negativity
2. ✅ **Optimal solutions found** - Candidate max flow matches reference within tolerance
3. ✅ **Tests pass** - All unit tests green
4. ✅ **Edmonds-Karp implemented** - BFS for augmenting paths, residual graph, flow augmentation
5. ✅ **Performance acceptable** - 15-node problem solves in < 5 seconds

## Expected Behavior

**For all 5 fixtures:**
- Candidate produces valid flow (validation passes)
- Candidate max flow matches OR-Tools optimal (within 0.01 tolerance)
- Flow conservation holds at all intermediate nodes
- No capacity constraints violated

**Comparison with previous algorithms:**
- TSP/VRP: Routing problems (finding tours/routes)
- Assignment: Bipartite matching (pairing workers/tasks)
- Max Flow: Network flow (source → sink optimization)

All use exact or optimal algorithms, but different problem structures.

## Implementation Notes

**Algorithm complexity:**
- Edmonds-Karp is clearer than Hungarian but still requires:
  * BFS implementation
  * Residual graph construction
  * Parent pointer tracking
  * Flow augmentation logic
- ~100-150 lines of algorithmic code

**Testing strategy:**
- Start with simple 4-node (manual verification: max flow = 15)
- Verify optimality on all fixtures (compare with OR-Tools)
- Edge cases: no path, disconnected graph, single edge

**UI considerations:**
- Network graph visualization (nodes and edges)
- Show flow values on edges
- Highlight augmenting paths found by BFS
- Display source/sink nodes distinctly

---

**Ready for Codex implementation.**

**Approved algorithm:** Edmonds-Karp (Ford-Fulkerson with BFS)  
**PI approval:** 2026-04-17 (Option A selected)



---

# P0023: Minimum Cost Flow Problem Implementation

**Date:** 2026-04-22  
**Status:** Ready for implementation  
**Architect:** Claude  
**Algorithm:** Successive Shortest Path

## Problem Statement

Implement the Minimum Cost Flow Problem solver using the Successive Shortest Path algorithm.

**Problem definition:**
- Input: Directed graph with nodes, edges with capacities and costs, source node with supply, sink node with demand
- Goal: Find flow from source to sink that satisfies demand at minimum total cost
- Constraints: Flow on edge must not exceed capacity, flow conservation at intermediate nodes, total flow must satisfy demand
- Output: Minimum cost value and flow assignments on edges

**Complexity:** Polynomial time with proper shortest path implementation

## Algorithm: Successive Shortest Path

**Overview:**
The Successive Shortest Path algorithm finds minimum cost flow by iteratively sending flow along the cheapest augmenting path in the residual graph. Unlike Edmonds-Karp which maximizes flow, this algorithm minimizes total cost while satisfying a fixed demand.

**Key concepts:**
- **Residual graph with costs:** For each edge from u to v with capacity c, current flow f, and unit cost w, the residual graph contains a forward edge from u to v with residual capacity c minus f and cost w, plus a backward edge from v to u with residual capacity f and cost negative w.
- **Shortest path by cost:** Path from source to sink in residual graph with minimum total cost (sum of edge costs).
- **Flow augmentation:** Increase flow along shortest cost path by minimum of remaining demand and path bottleneck capacity.
- **Optimality:** When demand is satisfied and no negative cost cycle exists, the flow is optimal.

**Algorithm steps:**

1. **Initialize flow:** Set flow on all edges to zero.

2. **Build residual graph with costs:**
   - For each edge from u to v with capacity c, current flow f, and cost w, add forward edge from u to v with residual capacity c minus f and cost w. If f is greater than zero, add backward edge from v to u with residual capacity f and cost negative w.
   - Only include edges with positive residual capacity.

3. **Find shortest cost path:**
   - Use Bellman-Ford or Dijkstra (with non-negative costs after potential adjustment) to find minimum cost path from source to sink in residual graph.
   - Track parent pointers to reconstruct path.
   - If no path exists or remaining demand is zero, algorithm terminates.

4. **Calculate bottleneck capacity:**
   - Find minimum residual capacity along the path found.
   - Take minimum of bottleneck and remaining demand.

5. **Augment flow:**
   - For each edge on the path, if it is a forward edge, increase flow by augmentation amount. If it is a backward edge, decrease flow by augmentation amount.
   - Reduce remaining demand by augmentation amount.

6. **Repeat steps 2 through 5** until demand is satisfied or no augmenting path exists.

**Termination:** When remaining demand reaches zero or no path exists from source to sink, current flow represents minimum cost solution.

**Reference materials:**
- Ahuja, Magnanti, Orlin "Network Flows" Chapter 9
- Wikipedia "Minimum-cost flow problem" for algorithm variants
- OR-Tools documentation for verification approach

## Test Fixtures

Create five minimum cost flow fixtures in db/seeds.rb:

### Fixture 1: mincostflow_simple_4
```ruby
{
  name: "mincostflow_simple_4",
  nodes: 4,
  edges: [
    [0, 1, 15, 4],   # source to node1, capacity 15, cost 4 per unit
    [0, 2, 8, 4],    # source to node2, capacity 8, cost 4 per unit
    [1, 3, 20, 2],   # node1 to sink, capacity 20, cost 2 per unit
    [2, 3, 10, 6]    # node2 to sink, capacity 10, cost 6 per unit
  ],
  source: 0,
  sink: 3,
  demand: 15,
  description: "Simple 4-node network with two paths of different costs (optimal uses cheaper path via node1)"
}
```
**Expected:** Minimum cost uses 15 units via node1 (cost = 15 times 6 = 90), no flow via node2.

### Fixture 2: mincostflow_balanced_6
```ruby
{
  name: "mincostflow_balanced_6",
  nodes: 6,
  edges: [
    [0, 1, 10, 2],
    [0, 2, 10, 4],
    [1, 3, 8, 5],
    [1, 4, 2, 3],
    [2, 3, 5, 1],
    [2, 4, 8, 2],
    [3, 5, 15, 1],
    [4, 5, 10, 3]
  ],
  source: 0,
  sink: 5,
  demand: 12,
  description: "Medium network requiring cost-aware path selection across multiple intermediate nodes"
}
```
**Expected:** Optimal flow balances between cheaper long paths and expensive short paths.

### Fixture 3: mincostflow_high_cost_shortcut_5
```ruby
{
  name: "mincostflow_high_cost_shortcut_5",
  nodes: 5,
  edges: [
    [0, 1, 20, 1],   # cheap first leg
    [1, 2, 20, 1],   # cheap second leg
    [2, 4, 20, 1],   # cheap final leg (long path total cost 3)
    [0, 3, 15, 10],  # expensive first leg of shortcut
    [3, 4, 15, 1]    # cheap second leg of shortcut (shortcut total cost 11)
  ],
  source: 0,
  sink: 4,
  demand: 18,
  description: "Tests preference for longer cheap path over expensive shortcut"
}
```
**Expected:** Algorithm should route flow through the three-hop cheap path, not the expensive shortcut.

### Fixture 4: mincostflow_capacity_limited_7
```ruby
{
  name: "mincostflow_capacity_limited_7",
  nodes: 7,
  edges: [
    [0, 1, 5, 1],
    [0, 2, 10, 3],
    [1, 3, 3, 2],
    [1, 4, 4, 4],
    [2, 4, 8, 1],
    [2, 5, 6, 2],
    [3, 6, 10, 3],
    [4, 6, 12, 2],
    [5, 6, 8, 1]
  ],
  source: 0,
  sink: 6,
  demand: 14,
  description: "Capacity constraints force use of multiple paths despite cost differences"
}
```
**Expected:** Cheapest path has insufficient capacity, requiring flow distribution across more expensive alternatives.

### Fixture 5: mincostflow_parallel_edges_8
```ruby
{
  name: "mincostflow_parallel_edges_8",
  nodes: 8,
  edges: [
    [0, 1, 8, 3],
    [0, 2, 7, 2],
    [1, 3, 6, 4],
    [1, 4, 5, 1],
    [2, 3, 4, 2],
    [2, 5, 9, 3],
    [3, 6, 10, 2],
    [4, 6, 8, 5],
    [4, 7, 6, 1],
    [5, 7, 7, 4],
    [6, 7, 15, 1]
  ],
  source: 0,
  sink: 7,
  demand: 16,
  description: "Complex network with multiple parallel routing options requiring optimal cost balancing"
}
```
**Expected:** Optimal solution distributes flow across multiple paths based on combined capacity and cost tradeoffs.

## Reference Implementation

Use OR-Tools MinCostFlow solver:

```ruby
require 'or_tools'

min_cost_flow = ORTools::SimpleMinCostFlow.new

# Add edges: start_node, end_node, capacity, unit_cost
edges.each do |start_node, end_node, capacity, unit_cost|
  min_cost_flow.add_arc_with_capacity_and_unit_cost(
    start_node, end_node, capacity, unit_cost
  )
end

# Add supply at source, demand at sink
min_cost_flow.set_node_supply(source, demand)
min_cost_flow.set_node_supply(sink, -demand)

status = min_cost_flow.solve

if status == ORTools::SimpleMinCostFlow::OPTIMAL
  optimal_cost = min_cost_flow.optimal_cost
  # Extract flow on each arc with min_cost_flow.flow(arc_index)
end
```

## Candidate Implementation

Create MinCostFlowSolver class that implements Successive Shortest Path:

**Required methods:**
- initialize: accepts nodes, edges with capacities and costs, source, sink, demand
- solve: returns hash with optimal_cost and flow_assignments
- validate_flow: verifies flow conservation, capacity constraints, demand satisfaction

**Data structure:**
- Edge: start_node, end_node, capacity, cost, flow
- ResidualEdge: start_node, end_node, residual_capacity, cost

**Algorithm components:**
- build_residual_graph: constructs residual network with forward and backward edges
- shortest_cost_path: uses Bellman-Ford to find minimum cost path (handles negative costs from backward edges)
- augment_flow: updates flow along path and decreases remaining demand
- calculate_total_cost: sums cost times flow for all edges

## Validation Requirements

For each fixture:

1. **Flow conservation:** For every intermediate node, total inflow equals total outflow
2. **Capacity constraints:** Flow on every edge does not exceed its capacity
3. **Non-negativity:** Flow on every edge is greater than or equal to zero
4. **Demand satisfaction:** Total flow from source equals demand
5. **Cost optimality:** Total cost matches OR-Tools solution within tolerance of 0.01

## Comparison Metrics

**Primary metric:** Total cost of candidate flow versus OR-Tools optimal cost

**Secondary metrics:**
- Flow assignments per edge (should match OR-Tools within tolerance)
- Number of iterations required to reach optimal solution
- Path selection sequence (for debugging non-optimal solutions)

**Error patterns to detect:**
- Candidate finds feasible flow but with higher cost than optimal
- Capacity violations during flow augmentation
- Flow conservation errors at intermediate nodes
- Infinite loops from incorrect residual graph construction
- Incorrect handling of backward edges or negative costs

## Success Criteria

1. ✅ **All 5 fixtures pass validation** - Flows satisfy conservation, capacity, non-negativity, and demand
2. ✅ **Optimal costs found** - Candidate total cost matches OR-Tools reference within tolerance of 0.01
3. ✅ **Tests pass** - All unit tests green
4. ✅ **Successive Shortest Path implemented** - Bellman-Ford for shortest cost path, residual graph with costs, flow augmentation
5. ✅ **Performance acceptable** - 8-node problem solves in under 5 seconds

## Expected Behavior

**For all 5 fixtures:**
- Candidate produces valid flow (validation passes)
- Candidate total cost matches OR-Tools optimal (within 0.01 tolerance)
- Flow conservation holds at all intermediate nodes
- No capacity constraints violated
- Demand fully satisfied

**Comparison with previous algorithms:**
- Max Flow: Maximizes flow from source to sink (no costs)
- Min Cost Flow: Minimizes cost while satisfying fixed demand (adds cost dimension)
- Both use residual graphs but optimize different objectives

## Implementation Notes

**Algorithm complexity:**
- Successive Shortest Path requires Bellman-Ford implementation for handling negative edge costs in residual graph
- Approximately 150 to 200 lines of algorithmic code
- More complex than Edmonds-Karp due to cost tracking and demand satisfaction logic

**Testing strategy:**
- Start with simple 4-node fixture (manual cost verification possible)
- Verify cost optimality on all fixtures (compare with OR-Tools)
- Edge cases: demand exceeds max flow capacity, no feasible flow, single path network

**UI considerations:**
- Network graph visualization with nodes and edges
- Display both capacity and cost on edges
- Show flow values and resulting costs per edge
- Highlight paths used in optimal solution
- Display total cost prominently
- Compare candidate cost with OR-Tools reference cost

---

**Ready for Codex implementation.**

**Approved algorithm:** Successive Shortest Path  
**PI approval:** 2026-04-22


---

# P0024: Job Shop Scheduling Problem Implementation

**Date:** 2026-04-22  
**Status:** Ready for implementation  
**Architect:** Claude  
**Algorithm:** Constraint Programming (CP-SAT solver)

## Problem Statement

Implement the Job Shop Scheduling Problem solver using constraint programming with the CP-SAT solver from OR-Tools.

**Problem definition:**
- Input: Set of jobs, each job has ordered tasks, each task requires a specific machine and has a duration
- Goal: Assign start times to all tasks to minimize makespan (total completion time)
- Constraints: 
  * Each machine processes at most one task at a time (no overlap)
  * Task precedence within each job must be respected
  * All tasks must be scheduled
- Output: Optimal makespan and task start times

**Complexity:** NP-hard (constraint satisfaction with optimization)

## Algorithm: Constraint Programming with CP-SAT

**Overview:**
The CP-SAT (Constraint Programming - Boolean Satisfiability) solver from OR-Tools handles Job Shop Scheduling by modeling tasks as interval variables with precedence and no-overlap constraints. Unlike heuristic approaches, CP-SAT searches for provably optimal solutions using constraint propagation and branch-and-bound techniques.

**Key concepts:**
- **Interval variables:** Represent tasks with start time, duration, and end time
- **Precedence constraints:** Task B cannot start until Task A completes (within same job)
- **No-overlap constraints:** Tasks assigned to same machine cannot execute simultaneously
- **Objective:** Minimize maximum end time across all tasks (makespan)
- **Horizon:** Upper bound on schedule duration (sum of all task durations provides safe bound)

**Algorithm steps:**

1. **Define horizon:** Calculate maximum possible schedule duration (sum of all task durations provides conservative upper bound)

2. **Create interval variables:** For each task, create interval variable representing its execution window with start time, duration, and end time

3. **Add precedence constraints:** For each job, ensure tasks execute in specified order by constraining each task's start to occur after previous task's end

4. **Add no-overlap constraints:** For each machine, create no-overlap constraint ensuring all tasks assigned to that machine do not execute simultaneously

5. **Define objective:** Create makespan variable representing maximum end time across all tasks, then minimize this variable

6. **Solve:** Invoke CP-SAT solver to find optimal solution

**Termination:** Solver returns OPTIMAL status when provably optimal schedule found, or FEASIBLE status with best solution found within time limit

**Reference materials:**
- OR-Tools CP-SAT documentation for Job Shop Scheduling
- Taillard benchmark instances for standard test problems
- Wikipedia "Job Shop Scheduling" for problem definition


## Test Fixtures

Create five job shop scheduling fixtures in db/seeds.rb:

### Fixture 1: jobshop_tiny_3x3
```ruby
{
  name: "jobshop_tiny_3x3",
  jobs: [
    [[0, 3], [1, 2], [2, 2]],  # Job 0: Machine 0 for 3 time units, then Machine 1 for 2, then Machine 2 for 2
    [[0, 2], [2, 1], [1, 4]],  # Job 1: Machine 0 for 2, then Machine 2 for 1, then Machine 1 for 4
    [[1, 4], [2, 3]]           # Job 2: Machine 1 for 4, then Machine 2 for 3
  ],
  description: "Tiny 3 jobs on 3 machines, manual verification possible (optimal makespan = 11)"
}
```
**Expected:** Optimal makespan = 11 time units

### Fixture 2: jobshop_small_4x4
```ruby
{
  name: "jobshop_small_4x4",
  jobs: [
    [[0, 4], [1, 3], [2, 1], [3, 2]],
    [[1, 2], [0, 3], [3, 4], [2, 1]],
    [[2, 3], [3, 2], [0, 2], [1, 3]],
    [[3, 1], [2, 4], [1, 2], [0, 3]]
  ],
  description: "Small 4 jobs on 4 machines with varied task orderings"
}
```
**Expected:** Optimal makespan to be determined by OR-Tools reference


### Fixture 3: jobshop_asymmetric_5x4
```ruby
{
  name: "jobshop_asymmetric_5x4",
  jobs: [
    [[0, 5], [2, 3], [3, 2]],
    [[1, 4], [0, 2], [3, 3], [2, 1]],
    [[2, 2], [1, 3], [0, 4]],
    [[3, 3], [2, 2], [1, 1], [0, 2]],
    [[0, 1], [1, 5], [3, 2], [2, 3]]
  ],
  description: "5 jobs with different number of tasks on 4 machines (asymmetric job lengths)"
}
```
**Expected:** Optimal makespan to be determined by OR-Tools reference

### Fixture 4: jobshop_precedence_test_6x3
```ruby
{
  name: "jobshop_precedence_test_6x3",
  jobs: [
    [[0, 3], [1, 2], [2, 4]],
    [[1, 2], [0, 3], [2, 1]],
    [[2, 3], [0, 2], [1, 3]],
    [[0, 4], [2, 2], [1, 1]],
    [[1, 3], [2, 2], [0, 2]],
    [[2, 1], [1, 4], [0, 3]]
  ],
  description: "6 jobs on 3 machines designed to test strict precedence constraint enforcement"
}
```
**Expected:** Optimal makespan to be determined by OR-Tools reference


### Fixture 5: jobshop_medium_8x5
```ruby
{
  name: "jobshop_medium_8x5",
  jobs: [
    [[0, 2], [1, 3], [2, 2], [3, 1], [4, 2]],
    [[1, 1], [0, 4], [3, 2], [2, 3], [4, 1]],
    [[2, 3], [4, 2], [0, 1], [1, 2], [3, 3]],
    [[3, 2], [2, 1], [4, 3], [0, 2], [1, 1]],
    [[4, 1], [1, 2], [0, 3], [2, 1], [3, 2]],
    [[0, 3], [3, 2], [1, 1], [4, 2], [2, 3]],
    [[1, 2], [2, 2], [3, 3], [4, 1], [0, 2]],
    [[2, 1], [0, 2], [4, 3], [1, 2], [3, 1]]
  ],
  description: "Medium complexity: 8 jobs on 5 machines with full task sequences"
}
```
**Expected:** Optimal makespan to be determined by OR-Tools reference

## Reference Implementation

Use OR-Tools CP-SAT solver:

```ruby
require 'or_tools'

solver = ORTools::CpSolver.new
model = ORTools::CpModel.new

# Calculate horizon
horizon = jobs.flat_map { |job| job.map { |task| task[1] } }.sum

# Create interval variables for each task
task_vars = {}
jobs.each_with_index do |job, job_id|
  job.each_with_index do |(machine, duration), task_id|
    start_var = model.new_int_var(0, horizon, "start_#{job_id}_#{task_id}")
    end_var = model.new_int_var(0, horizon, "end_#{job_id}_#{task_id}")
    interval_var = model.new_interval_var(start_var, duration, end_var, "interval_#{job_id}_#{task_id}")
    task_vars[[job_id, task_id]] = { start: start_var, end: end_var, interval: interval_var, machine: machine }
  end
end

# Add precedence constraints (within each job)
jobs.each_with_index do |job, job_id|
  job.each_cons(2).with_index do |(task1, task2), task_id|
    model.add(task_vars[[job_id, task_id + 1]][:start] >= task_vars[[job_id, task_id]][:end])
  end
end

# Add no-overlap constraints (for each machine)
machines = task_vars.values.group_by { |task| task[:machine] }
machines.each do |machine_id, tasks|
  model.add_no_overlap(tasks.map { |task| task[:interval] })
end

# Define objective: minimize makespan
makespan = model.new_int_var(0, horizon, "makespan")
task_vars.values.each do |task|
  model.add(makespan >= task[:end])
end
model.minimize(makespan)

# Solve
status = solver.solve(model)

if status == :optimal || status == :feasible
  optimal_makespan = solver.value(makespan)
  # Extract task start times: solver.value(task_vars[[job_id, task_id]][:start])
end
```


## Candidate Implementation

Create JobShopScheduler class that implements constraint programming approach:

**Required methods:**
- initialize: accepts jobs array where each job is array of [machine_id, duration] pairs
- solve: returns hash with optimal_makespan and task_start_times
- validate_schedule: verifies precedence constraints, no machine overlaps, all tasks scheduled

**Data structure:**
- Task: job_id, task_id, machine_id, duration, start_time, end_time
- Schedule: collection of tasks with assigned start times

**Algorithm components:**
- build_constraints: creates precedence and no-overlap constraint graph
- search_space_reduction: uses constraint propagation to reduce possible start times
- branch_and_bound: systematically searches for optimal solution
- validate_solution: checks constraint satisfaction and calculates makespan

**Note:** Candidate implementation may use simplified CP approach or constraint-aware heuristic. Full CP-SAT solver implementation not required, but solution must respect all constraints.

## Validation Requirements

For each fixture:

1. **Precedence constraints satisfied:** Within each job, tasks execute in specified order (task N plus one starts after task N ends)
2. **No machine conflicts:** No two tasks assigned to same machine execute simultaneously
3. **All tasks scheduled:** Every task has assigned start time
4. **Makespan calculated correctly:** Maximum end time across all tasks

5. **Optimality comparison:** Candidate makespan compared against OR-Tools optimal makespan

## Comparison Metrics

**Primary metric:** Candidate makespan versus OR-Tools optimal makespan

**Secondary metrics:**
- Constraint violation count (should be zero for valid schedules)
- Schedule compactness (idle time on machines)
- Solution time for candidate versus reference

**Error patterns to detect:**
- Precedence constraint violations (task starts before predecessor completes)
- Machine overlap conflicts (two tasks on same machine at same time)
- Incomplete schedules (some tasks not assigned start times)
- Suboptimal makespan (valid schedule but longer than optimal)
- False optimality claims (candidate reports optimal but schedule has slack)

## Success Criteria

1. ✅ **All 5 fixtures pass validation** - Schedules satisfy precedence, no-overlap, and completeness constraints
2. ✅ **Optimal or near-optimal solutions** - Candidate makespan matches or is close to OR-Tools optimal
3. ✅ **Tests pass** - All unit tests green
4. ✅ **CP or constraint-aware approach implemented** - Solution respects constraint structure
5. ✅ **Performance acceptable** - 8-job problem solves in under 30 seconds

## Expected Behavior

**For all 5 fixtures:**
- Candidate produces valid schedule (validation passes)
- Precedence constraints respected within each job
- No machine conflicts (no simultaneous tasks on same machine)
- All tasks scheduled with start times
- Makespan comparison with OR-Tools shows quality gap if heuristic used


**Comparison with previous algorithms:**
- TSP/VRP: Routing problems (sequencing and assignment)
- Assignment: Bipartite matching (one-to-one pairing)
- Max Flow/Min Cost Flow: Network flow (capacity and cost optimization)
- Job Shop: Scheduling with precedence and resource constraints

All are combinatorial optimization problems but Job Shop adds temporal constraints and resource contention.

## Implementation Notes

**Algorithm complexity:**
- Job Shop Scheduling is NP-hard, no polynomial exact algorithm known
- CP-SAT provides optimal solutions but may take exponential time for large instances
- Candidate may use heuristics (earliest start time, critical path) for tractability
- Approximately 200 to 300 lines of algorithmic code expected

**Testing strategy:**
- Start with tiny 3x3 fixture (manual verification possible: makespan equals 11)
- Verify constraint satisfaction on all fixtures
- Compare makespan quality against OR-Tools
- Edge cases: single job, single machine, very long task sequences

**UI considerations:**
- Gantt chart visualization showing tasks on timeline
- Color-code tasks by job
- Display machine assignments and task durations
- Show precedence dependencies
- Highlight critical path if identified
- Display makespan prominently
- Compare candidate makespan with OR-Tools reference

---

**Ready for Codex implementation.**

**Approved algorithm:** Constraint Programming (CP-SAT solver for reference, CP-aware approach for candidate)  
**PI approval:** 2026-04-22


---

# P0025: Moon Phase Calculations

**Date:** 2026-04-22
**Status:** Ready for implementation
**Architect:** Claude
**Reference gem:** `astronoby` (v0.7.0)

## Prerequisites

This prompt introduces the astronomy domain and the `astronoby` gem.
It requires a one-time ephemeris download before seeding or running tests.

```bash
bundle add astronoby
bin/rails runner "Ephem::IO::Download.call(name: 'de421.bsp', target: 'tmp/de421.bsp')"
```

The file `tmp/de421.bsp` (17 MB) must be present on the local filesystem.
It should be added to `.gitignore`. It is not committed to the repository.

## Problem Statement

Calculate Moon phase data for specific UTC instants and compare a native Ruby
candidate implementation against the `astronoby` reference gem.

**Outputs to compare per fixture:**
- `illuminated_fraction` - fraction of Moon surface illuminated (0.0 to 1.0)
- `phase_fraction` - position within lunar cycle (0.0 = new moon, 0.5 = full moon, 1.0 = new moon again)
- `phase_name` - human-readable phase label (New Moon, Waxing Crescent, First Quarter, Waxing Gibbous, Full Moon, Waning Gibbous, Last Quarter, Waning Crescent)


## Reference Implementation

Use `astronoby` gem:

```ruby
require "astronoby"

ephem = Astronoby::Ephem.load("tmp/de421.bsp")
time  = Time.utc(2025, 1, 13, 22, 27, 0)  # example: Full Moon
instant = Astronoby::Instant.from_time(time)
moon = Astronoby::Moon.new(instant: instant, ephem: ephem)

illuminated_fraction = moon.illuminated_fraction.round(4)
phase_fraction       = moon.current_phase_fraction.round(4)
```

**Note:** `illuminated_fraction` and `current_phase_fraction` return floats.
Phase name derivation from `phase_fraction` follows standard 8-phase boundaries:
- 0.0–0.0625 or 0.9375–1.0 → New Moon
- 0.0625–0.1875 → Waxing Crescent
- 0.1875–0.3125 → First Quarter
- 0.3125–0.4375 → Waxing Gibbous
- 0.4375–0.5625 → Full Moon
- 0.5625–0.6875 → Waning Gibbous
- 0.6875–0.8125 → Last Quarter
- 0.8125–0.9375 → Waning Crescent

## Test Fixtures

Create five Moon phase fixtures in `db/seeds.rb`.
All times are UTC. Expected values are to be confirmed by running the reference solver.

### Fixture 1: moon_phase_new_moon
```ruby
{ name: "moon_phase_new_moon",
  time: Time.utc(2025, 1, 29, 12, 36, 0),
  description: "New Moon - January 2025" }
```
**Expected:** illuminated_fraction ≈ 0.0, phase_fraction ≈ 0.0, phase_name = "New Moon"



---

# P0025: Moon Phase Calculations

**Date:** 2026-04-22
**Status:** Ready for implementation
**Architect:** Claude
**Reference gem:** `astronoby` (verified API from official wiki, v0.7.0)

## Problem Statement

Implement a native Ruby Moon phase calculator and compare against the `astronoby` gem reference.

**Problem definition:**
- Input: A UTC date (year, month, day)
- Goal: Calculate Moon phase properties for that date
- Output: Illuminated fraction (0.0 to 1.0) and phase fraction (0.0 to 1.0)
- Secondary output: Identify major phase events (new moon, first quarter, full moon, last quarter) for a given month

**Complexity:** Numerical astronomy - trigonometric series approximation

## C005 Compliance: gem verification

**Gem:** `astronoby` (https://github.com/rhannequin/astronoby)
**Version verified:** 0.7.0
**Maintenance status:** Actively maintained, updated May 2025
**API verified from official wiki (https://github.com/rhannequin/astronoby/wiki):**

```ruby
# One-time ephemeris download (17 MB, stored in tmp/, gitignored)
Ephem::IO::Download.call(name: "de421.bsp", target: "tmp/de421.bsp")

# Load ephemeris
ephem = Astronoby::Ephem.load("tmp/de421.bsp")

# Instantiated fraction and phase for a given UTC time
time = Time.utc(2025, 5, 15)
instant = Astronoby::Instant.from_time(time)
moon = Astronoby::Moon.new(ephem: ephem, instant: instant)
moon.illuminated_fraction.round(4)   # => Float between 0.0 and 1.0
moon.current_phase_fraction.round(4) # => Float between 0.0 and 1.0

# Major phase events for a given month
phases = Astronoby::Events::MoonPhases.phases_for(year: 2024, month: 5)
phases.each { |p| puts "#{p.phase}: #{p.time}" }
# phase values: :last_quarter, :new_moon, :first_quarter, :full_moon
# time values: UTC Time objects
```

**Ephemeris dependency:**
- `de421.bsp` must be present at `tmp/de421.bsp`
- Download once with `Ephem::IO::Download.call(name: "de421.bsp", target: "tmp/de421.bsp")`
- File is 17 MB, covers 1900-2050
- Add `tmp/de421.bsp` to `.gitignore`
- README setup instructions must document this download step


## Algorithm: Jean Meeus Astronomical Algorithms

**Overview:**
The standard approach for native Moon phase calculation is the algorithm from Jean Meeus "Astronomical Algorithms" (2nd ed.), which uses trigonometric series to approximate the Moon's orbital position. This is the same algorithmic basis used by most astronomy libraries including `astronoby`.

**Key concepts:**
- **Julian Day Number (JDN):** Continuous day count from noon January 1, 4713 BC used as astronomical time reference
- **Synodic month:** 29.53058868 days, the period between identical Moon phases
- **Phase fraction:** 0.0 = new moon, 0.25 = first quarter, 0.5 = full moon, 0.75 = last quarter, 1.0 = new moon again
- **Illuminated fraction:** Fraction of Moon's visible surface illuminated (0.0 to 1.0), derived from elongation angle between Moon and Sun

**Algorithm steps:**

1. **Convert UTC date to Julian Day Number:**
   - Account for the Gregorian calendar correction
   - JDN provides a uniform time reference independent of calendar systems

2. **Calculate days since known new moon:**
   - Use a known new moon epoch (e.g. January 6, 2000 18:14 UTC = JDN 2451550.1)
   - Divide elapsed days by synodic month length to get phase cycles elapsed

3. **Extract phase fraction:**
   - Take fractional part of cycles elapsed
   - Phase fraction between 0.0 and 1.0 represents position in current lunar cycle

4. **Calculate illuminated fraction:**
   - Compute Moon's mean anomaly, Sun's mean anomaly, and Moon's argument of latitude
   - Apply trigonometric correction terms from Meeus Chapter 48
   - Derive elongation angle and compute illuminated fraction as (1 - cos(elongation)) / 2

5. **Identify major phase events:**
   - Search forward from start of month for phase fractions near 0.0, 0.25, 0.5, 0.75
   - Refine event times using Newton's method or binary search to specified tolerance

**Reference materials:**
- Meeus, Jean. "Astronomical Algorithms" 2nd ed. Chapter 48 (Illuminated Fraction of the Moon's Disk)
- Meeus, Jean. "Astronomical Algorithms" 2nd ed. Chapter 49 (Phases of the Moon)


## Test Fixtures

Create five Moon phase fixtures in db/seeds.rb. All times are UTC. Reference values must be confirmed against `astronoby` before seeding.

### Fixture 1: moon_phase_new_moon_2024_01
```ruby
{
  name: "moon_phase_new_moon_2024_01",
  date: Date.new(2024, 1, 11),
  description: "Date near January 2024 new moon - low illuminated fraction expected"
}
```

### Fixture 2: moon_phase_full_moon_2024_01
```ruby
{
  name: "moon_phase_full_moon_2024_01",
  date: Date.new(2024, 1, 25),
  description: "Date near January 2024 full moon - high illuminated fraction expected"
}
```

### Fixture 3: moon_phase_first_quarter_2024_05
```ruby
{
  name: "moon_phase_first_quarter_2024_05",
  date: Date.new(2024, 5, 15),
  description: "Date near May 2024 first quarter - moderate illuminated fraction expected"
}
```

### Fixture 4: moon_phase_events_2024_05
```ruby
{
  name: "moon_phase_events_2024_05",
  year: 2024,
  month: 5,
  description: "All major phase events for May 2024 - verified against astronoby wiki example"
}
```
**Known reference output from astronoby wiki:**
- last_quarter: 2024-05-01 11:27:15 UTC
- new_moon: 2024-05-08 03:21:56 UTC
- first_quarter: 2024-05-15 11:48:02 UTC
- full_moon: 2024-05-23 13:53:12 UTC
- last_quarter: 2024-05-30 17:12:43 UTC

### Fixture 5: moon_phase_events_2025_03
```ruby
{
  name: "moon_phase_events_2025_03",
  year: 2025,
  month: 3,
  description: "All major phase events for March 2025 - reference values from astronoby"
}
```
**Reference values:** Codex must run astronoby to obtain reference values before seeding.


## Reference Implementation

Use `astronoby` gem with verified API:

```ruby
require "astronoby"

ephem = Astronoby::Ephem.load("tmp/de421.bsp")

# Illuminated fraction and phase fraction for a date
time = Time.utc(year, month, day, 12, 0, 0)  # noon UTC
instant = Astronoby::Instant.from_time(time)
moon = Astronoby::Moon.new(ephem: ephem, instant: instant)

illuminated_fraction = moon.illuminated_fraction.round(4)
phase_fraction = moon.current_phase_fraction.round(4)

# Major phase events for a month
phases = Astronoby::Events::MoonPhases.phases_for(year: year, month: month)
phase_events = phases.map { |p| { phase: p.phase, time: p.time } }
```

**Important:** The `astronoby` gem requires the ephemeris file at `tmp/de421.bsp`. Codex must verify this file exists before running the reference solver. If absent, run:

```ruby
Ephem::IO::Download.call(name: "de421.bsp", target: "tmp/de421.bsp")
```

## Candidate Implementation

Create MoonPhaseCalculator class using Jean Meeus algorithm:

**Required methods:**
- initialize: accepts a UTC Date object
- illuminated_fraction: returns Float between 0.0 and 1.0
- phase_fraction: returns Float between 0.0 and 1.0 (0.0 = new moon, 0.5 = full moon)
- phase_name: returns String (:new_moon, :waxing_crescent, :first_quarter, :waxing_gibbous, :full_moon, :waning_gibbous, :last_quarter, :waning_crescent)

Create MoonPhaseEventFinder class:

**Required methods:**
- initialize: accepts year and month integers
- major_events: returns array of hashes with :phase and :time keys, matching astronoby output format


## Validation Requirements

For illuminated fraction and phase fraction fixtures:

1. **Range validity:** illuminated_fraction between 0.0 and 1.0 inclusive
2. **Range validity:** phase_fraction between 0.0 and 1.0 inclusive
3. **Tolerance:** candidate illuminated_fraction matches astronoby within 0.02 (2%)
4. **Tolerance:** candidate phase_fraction matches astronoby within 0.02 (2%)
5. **Phase name consistency:** phase_name matches expected quadrant given phase_fraction

For phase event fixtures:

1. **Event count:** correct number of major phase events for the month
2. **Event types present:** new_moon, first_quarter, full_moon, last_quarter all represented
3. **Time tolerance:** candidate event times match astronoby within 60 minutes
4. **Ordering:** events appear in chronological order

## Comparison Metrics

**Primary metrics:**
- illuminated_fraction difference (candidate vs astronoby)
- phase_fraction difference (candidate vs astronoby)
- phase event time offset in minutes (candidate vs astronoby)

**Expected LLM failure modes (from NEXT_PROJECT_SHORTLIST.md):**
- UTC vs local time confusion
- Julian date conversion errors
- Event boundary mistakes near month transitions
- Tolerance or rounding errors presented as exact results

## Success Criteria

1. ✅ **All 5 fixtures pass validation** - fractions within tolerance, events within 60 minutes
2. ✅ **Reference solver runs** - astronoby produces values using de421.bsp
3. ✅ **Candidate implemented** - Jean Meeus algorithm with JDN and synodic month
4. ✅ **Tests pass** - All unit tests green
5. ✅ **Performance acceptable** - All calculations complete in under 5 seconds

## Implementation Notes

**New domain notes:**
- This is the first astronomy benchmark. The error surface differs from OR-Tools problems.
- Numerical tolerance matters: candidate and reference will not produce bit-identical results.
- UTC is the required time reference throughout. Local time must not appear in calculations.
- Julian Day Numbers must use the Gregorian calendar correction for dates after 1582-10-15.

**Testing strategy:**
- Use Fixture 4 (May 2024 events) as primary verification since reference values are already known from the astronoby wiki
- Verify illuminated fraction near 0.0 for new moon fixture and near 1.0 for full moon fixture
- Edge cases: month boundaries, southern hemisphere dates (phase fractions identical, illumination direction differs)

**UI considerations:**
- Display Moon phase as both numeric fraction and named phase
- Show illuminated fraction as percentage
- Display phase events for the month in chronological list
- Simple Moon phase icon or indicator if feasible
- Compare candidate vs astronoby values side by side with difference highlighted

---

**Ready for Codex implementation.**

**Approved reference:** astronoby gem with de421.bsp ephemeris
**Approved candidate algorithm:** Jean Meeus "Astronomical Algorithms" Chapter 48/49
**Ephemeris dependency:** de421.bsp (17 MB, one-time download to tmp/, gitignored)
**README update required:** Yes - document ephemeris download step in setup instructions
**PI approval:** 2026-04-22


---

# P0026: Moon Phase Calculations - Full Meeus Correction Series

**Date:** 2026-04-22
**Status:** Ready for implementation
**Architect:** Claude
**Algorithm:** meeus-full-corrections-v1
**Builds on:** P0025 (meeus-v1)

## Purpose and Research Context

P0025 implemented `meeus-v1` using a simplified Jean Meeus approach:
- epoch-based phase fraction from synodic month arithmetic
- basic Chapter 48 illuminated fraction calculation
- event finding via phase fraction search

R0025 showed that `meeus-v1` produces:
- daily fraction differences well within 0.02 tolerance
- monthly event time offsets of approximately 70 seconds later than astronoby

The 70-second systematic offset indicates the simplified implementation omits the
higher-order planetary correction terms that Meeus Chapter 47 and Chapter 49 require
for sub-minute accuracy.

P0026 introduces `meeus-full-corrections-v1` as a distinct versioned algorithm that
implements the full correction series. This allows the attempts table to record both
versions and make the accuracy improvement directly visible as a comparative finding.

## Research Question

Does implementing the full Meeus Chapter 47 and Chapter 49 correction series reduce
the systematic event time offset from ~70 seconds to under 10 seconds compared to
the astronoby reference?


## Algorithm: meeus-full-corrections-v1

**What meeus-v1 implemented (simplified approach):**
- Julian Day Number from Gregorian calendar conversion
- Phase fraction from days elapsed since known new moon epoch divided by synodic month
- Illuminated fraction from basic elongation calculation (Chapter 48 first-order terms only)
- Event finding by searching phase fraction near 0.0, 0.25, 0.5, 0.75

**What meeus-full-corrections-v1 must add:**

### 1. Full Moon position series (Meeus Chapter 47)

The Moon's ecliptic longitude requires summing the full periodic term table.
Key additional terms beyond the simplified version:

- Mean elongation D
- Sun's mean anomaly M
- Moon's mean anomaly M'
- Moon's argument of latitude F
- Additional argument A1 (Venus perturbation: 119.75 + 131.849 * T)
- Additional argument A2 (Jupiter perturbation: 53.09 + 479264.290 * T)
- Additional argument A3 (flattening correction: 313.45 + 481266.484 * T)

The longitude sum requires all 60 periodic terms from Table 47.A.
The latitude sum requires all 60 periodic terms from Table 47.B.
Both sums must include the A1, A2, A3 additive corrections.

### 2. Full phase event correction series (Meeus Chapter 49)

For each major phase event the simplified meeus-v1 uses only the JDE approximation.
The full series adds 25 correction terms per phase type:

For new moon and full moon events, the corrections include:
- E factor for Sun's anomaly terms (accounts for eccentricity of Earth's orbit)
- M (Sun's anomaly), M' (Moon's anomaly), F (argument of latitude)
- Omega (Moon's longitude of ascending node)
- Full 25-term correction table from Table 49.A (new/full moon)
- Additional A1 through A14 planetary corrections from Table 49.B

For quarter moon events the corrections include:
- 25-term correction table from Table 49.A (quarters)
- Additional W correction term for quarter phases specifically

### 3. Tighter tolerances

Because `meeus-full-corrections-v1` targets higher accuracy, the success criteria
use tighter tolerances than P0025:
- illuminated_fraction tolerance: 0.005 (was 0.02)
- phase_fraction tolerance: 0.005 (was 0.02)
- event time tolerance: 2 minutes (was 60 minutes)


## Candidate Implementation

Create a new class `MoonPhaseFullCalculator` (distinct from P0025's `MoonPhaseCalculator`).
Create a new class `MoonPhaseFullEventFinder` (distinct from P0025's `MoonPhaseEventFinder`).

**Do not modify the existing meeus-v1 classes.** Both versions must coexist so the
attempts table can record results from both algorithms independently.

**Algorithm version string:** `meeus-full-corrections-v1`

**Required methods (same interface as meeus-v1):**

MoonPhaseFullCalculator:
- initialize: accepts a UTC Date object
- illuminated_fraction: returns Float between 0.0 and 1.0
- phase_fraction: returns Float between 0.0 and 1.0
- phase_name: returns Symbol

MoonPhaseFullEventFinder:
- initialize: accepts year and month integers
- major_events: returns array of hashes with :phase and :time keys

**Key implementation requirements:**

1. T value must use Julian centuries from J2000.0:
   T = (JDE - 2451545.0) / 36525.0

2. All angular arguments must be computed in degrees then converted to radians
   for trigonometric functions

3. The E eccentricity factor must be applied:
   E = 1 - 0.002516 * T - 0.0000074 * T^2
   Terms involving M use E as a multiplier
   Terms involving 2M use E^2 as a multiplier

4. The full 60-term longitude and latitude tables from Chapter 47 must be used,
   not a truncated subset

5. The full 25-term event correction tables from Chapter 49 must be used,
   including the W correction for quarter phases

6. The A1 through A14 planetary corrections from Table 49.B must be applied
   after the main correction sum

## Test Fixtures

Reuse the same five fixtures from P0025. The MoonPhaseFixtures class already seeds
these records. P0026 adds new Attempt records using `meeus-full-corrections-v1`
against the same MoonPhaseProblem records.

**Do not create new fixture records.** Create new Attempt records only.

The runner should be named `MoonPhaseFullAttemptRunner` and should record attempts
under prompt `P0026` with algorithm version `meeus-full-corrections-v1`.


## Reference Implementation

Same as P0025. Use the existing astronoby reference solver and existing
GemMoonPhaseSolver. Do not create a new reference solver.

The comparison is: `meeus-full-corrections-v1` candidate vs astronoby reference,
on the same five fixtures already in the database.

## Validation Requirements

For illuminated fraction and phase fraction fixtures:

1. **Range validity:** illuminated_fraction between 0.0 and 1.0 inclusive
2. **Range validity:** phase_fraction between 0.0 and 1.0 inclusive
3. **Tolerance:** candidate illuminated_fraction matches astronoby within 0.005
4. **Tolerance:** candidate phase_fraction matches astronoby within 0.005
5. **Phase name consistency:** phase_name matches expected quadrant given phase_fraction

For phase event fixtures:

1. **Event count:** correct number of major phase events for the month
2. **Event types present:** new_moon, first_quarter, full_moon, last_quarter all represented
3. **Time tolerance:** candidate event times match astronoby within 2 minutes
4. **Ordering:** events appear in chronological order

## Comparison Metrics

Same metrics as P0025, with tighter tolerances:
- illuminated_fraction difference (target under 0.005)
- phase_fraction difference (target under 0.005)
- phase event time offset in minutes (target under 2 minutes)

**Direct comparison with meeus-v1:**
R0026 should explicitly state the improvement over R0025:
- fraction difference improvement
- event time offset improvement (target: from ~70 seconds to under 2 minutes)

## Success Criteria

1. ✅ **All 5 fixtures pass validation** - fractions within 0.005, events within 2 minutes
2. ✅ **Full Chapter 47 longitude/latitude tables implemented** - all 60 terms used
3. ✅ **Full Chapter 49 correction tables implemented** - all 25 terms plus planetary corrections
4. ✅ **E eccentricity factor applied correctly** - M and 2M terms scaled by E and E^2
5. ✅ **Tests pass** - All unit tests green
6. ✅ **meeus-v1 classes unchanged** - both versions coexist in codebase
7. ✅ **Performance acceptable** - All calculations complete in under 5 seconds

## Implementation Notes

**Critical distinction from meeus-v1:**
The simplified meeus-v1 derives phase fraction purely from synodic arithmetic.
meeus-full-corrections-v1 derives JDE of each event from the full Chapter 49
series, then converts to UTC. These are different computational paths that
should produce significantly different accuracy levels.

**Seed file pattern:**
Add `MoonPhaseFullAttemptRunner.new.run_all` to db/seeds.rb alongside the
existing `MoonPhaseAttemptRunner.new.run_all` call. The UI will then show
both `meeus-v1` and `meeus-full-corrections-v1` attempts for the same fixtures,
enabling direct side-by-side comparison.

**UI considerations:**
The existing moon_phase attempts UI should display both algorithm versions
for the same fixture, making the accuracy difference directly visible.
No new UI routes or views are required.

---

**Ready for Codex implementation.**

**Approved candidate algorithm:** meeus-full-corrections-v1
  (Jean Meeus "Astronomical Algorithms" full Chapter 47 + Chapter 49 correction series)
**Approved reference:** existing astronoby GemMoonPhaseSolver (unchanged from P0025)
**Fixture reuse:** existing MoonPhaseProblem records (no new fixture seeding)
**New runner:** MoonPhaseFullAttemptRunner under prompt P0026
**PI approval:** 2026-04-22
