
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

