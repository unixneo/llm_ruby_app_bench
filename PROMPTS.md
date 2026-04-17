

---

## P0020 - Vehicle Routing Problem (VRP): Multi-Vehicle Capacity-Constrained Routing

**Target:** Implement multi-vehicle routing with capacity constraints using OR-Tools RoutingModel and compare against OR-Tools reference solver.

**Problem Definition:**

Given:
- Fleet of M vehicles, each with capacity limit
- N customers, each with demand (delivery or pickup)
- One depot (start/end location for all vehicles)
- Distance/cost matrix between all locations

Find: Route assignment for each vehicle that:
- Visits all customers exactly once
- Satisfies vehicle capacity constraints
- Minimizes total distance/cost
- All vehicles start and end at depot

**VRP vs TSP:**

TSP (already implemented):
- Single vehicle
- No capacity constraints
- Visit all locations once

VRP (this prompt):
- **Multiple vehicles** (fleet)
- **Capacity constraints** per vehicle
- **Customer demands** must be satisfied
- **Load balancing** across fleet

**Constraints:**

- Pure Ruby implementation in `llm_ruby_app_bench` Rails app
- SQLite3 for storage
- No external VRP gems/libraries in candidate implementation
- Use OR-Tools RoutingModel as reference (already in project)
- Support fixtures with n≤20 customers, m≤5 vehicles

**Scope:**

1. **Data model:**
   - Create `VrpFixtures` class (similar to `TspFixtures`)
   - Reuse `Challenge` and `Attempt` models
   - Store: num_vehicles, vehicle_capacity, customer_demands, depot_location, distance_matrix
   - Result: routes per vehicle, total_distance, load per vehicle

2. **VRP problem representation:**
   - `VrpProblem` class with:
     * number of vehicles
     * vehicle capacity (uniform capacity for all vehicles)
     * customer demands array
     * depot index (typically 0)
     * distance matrix (n+1 × n+1 including depot)

3. **Candidate solver:**
   - Pure Ruby VRP implementation
   - Algorithm choice (PI approval required - see C001):
     * **Option A:** Savings algorithm (Clarke-Wright) - constructive heuristic
     * **Option B:** Sweep algorithm - geometric partitioning heuristic  
     * **Option C:** Nearest neighbor with capacity check - simple greedy
   - Input: VrpProblem instance
   - Output: { routes: [[depot, c1, c2, depot], [depot, c3, depot]], total_distance: Float, vehicle_loads: [Int] }
   - Must respect capacity constraints

4. **Reference comparison:**
   - Use OR-Tools RoutingModel (already in project for TSP)
   - Configure with capacity dimension
   - Run both candidate and reference on same fixtures
   - Compare: total_distance (may differ - heuristic vs optimization)
   - Verify: all customers visited, capacity constraints satisfied

5. **Fixtures:**
   - Create 5 VRP fixtures:
     * **Small (n=5, m=2):** 5 customers, 2 vehicles, capacity=15
     * **Symmetric (n=8, m=2):** Symmetric distances, uniform demands
     * **Asymmetric (n=10, m=3):** Asymmetric distances, varied demands
     * **Tight capacity (n=12, m=3):** Demands close to capacity limits
     * **Larger (n=20, m=5):** Stress test with 5-vehicle fleet
   - Each fixture includes:
     * Depot coordinates (location 0)
     * Customer locations with demands
     * Vehicle capacity
     * Known feasible solution or OR-Tools reference result

6. **Test coverage:**
   - Test candidate returns valid routes (all start/end at depot)
   - Test all customers visited exactly once
   - Test capacity constraints satisfied (sum of demands ≤ capacity per vehicle)
   - Test total distance calculation
   - Compare candidate vs reference feasibility (both find valid solutions)
   - Test edge cases: single customer, all demands equal, one vehicle

7. **Database schema:**
   - Extend `attempts` table or create `vrp_attempts`
   - Fields: fixture_name, num_vehicles, vehicle_capacity, customers_json, demands_json
   - candidate_routes, reference_routes (JSON arrays)
   - candidate_distance, reference_distance
   - status: 'feasible' (valid solution), 'infeasible' (constraint violation)

8. **Web interface:**
   - Add VRP to challenges index
   - Page listing VRP attempts with fixture, vehicles, distance comparison
   - Show routes per vehicle
   - Highlight capacity violations
   - Display OR-Tools reference for comparison

**Algorithm Selection Decision (C001 - PI Approval Required):**

**Available Options:**

**Option A: Clarke-Wright Savings Algorithm**
- Constructive heuristic
- Builds routes by merging pairs with highest savings
- Formula: savings(i,j) = distance(depot,i) + distance(depot,j) - distance(i,j)
- Complexity: O(n² log n)
- Quality: Good solutions, well-established
- Implementation: Moderate complexity (priority queue, route merging)

**Option B: Sweep Algorithm**
- Geometric partitioning
- Sort customers by polar angle from depot
- Assign customers to vehicles in angular order while respecting capacity
- Complexity: O(n log n)
- Quality: Fast, simple, works well for clustered customers
- Implementation: Simple (angle calculation, sequential assignment)

**Option C: Nearest Neighbor with Capacity**
- Greedy construction
- For each vehicle: add nearest unvisited customer until capacity full
- Complexity: O(n²)
- Quality: Simplest, may be suboptimal
- Implementation: Very simple (distance lookup, capacity tracking)

**Which option should be implemented?** (PI must select before implementation proceeds)

---

**Success criteria:**

- Candidate solver produces feasible routes (capacity constraints satisfied)
- All customers visited exactly once
- All routes start and end at depot
- Total distance calculated correctly
- OR-Tools reference provides comparison baseline
- Tests verify constraint satisfaction

**Out of scope for P0020:**

- Time windows
- Multiple depots
- Heterogeneous fleet (different vehicle capacities)
- Pickup and delivery
- Exact optimization (use heuristic)

**Example fixture (small):**

```ruby
{
  num_vehicles: 2,
  vehicle_capacity: 15,
  depot: 0,
  customers: [
    { id: 1, demand: 7 },
    { id: 2, demand: 5 },
    { id: 3, demand: 8 },
    { id: 4, demand: 6 },
    { id: 5, demand: 4 }
  ],
  distance_matrix: [
    # depot, c1, c2, c3, c4, c5
    [0,     10,  8, 15, 12,  9],  # from depot
    [10,     0,  5, 12,  8,  7],  # from c1
    [8,      5,  0,  9,  6,  4],  # from c2
    [15,    12,  9,  0,  7, 11],  # from c3
    [12,     8,  6,  7,  0,  5],  # from c4
    [9,      7,  4, 11,  5,  0]   # from c5
  ]
}
```

Feasible solution example:
- Vehicle 1: depot → c1(7) → c2(5) → depot (load: 12/15)
- Vehicle 2: depot → c3(8) → c5(4) → depot (load: 12/15)
- c4 could go to either vehicle

**OR-Tools Reference API (already in project):**

```ruby
require 'or-tools'

manager = ORTools::RoutingIndexManager.new(locations, num_vehicles, depot)
routing = ORTools::RoutingModel.new(manager)

# Add capacity dimension
routing.add_dimension_with_vehicle_capacity(
  evaluator_index,
  0,  # null capacity slack
  vehicle_capacities,
  true,  # start cumul to zero
  'Capacity'
)

# Solve and extract routes
solution = routing.solve(search_parameters: params)
# Extract routes from solution
```

**Deliverables:**

- `app/models/vrp_problem.rb` - problem representation
- `app/services/vrp_solver.rb` - candidate heuristic implementation
- `app/services/vrp_fixtures.rb` - fixture definitions
- `app/services/gem_vrp_solver.rb` - OR-Tools reference wrapper
- Tests for constraint satisfaction and reference comparison
- Updated challenges controller
- R0020 documenting:
  - Which algorithm was selected (PI approval)
  - Feasibility verification on all fixtures
  - Distance comparison with OR-Tools
  - Any capacity constraint violations

**Research focus:**

Test LLM behavior on:
- Multi-constraint optimization (capacity + routing)
- Heuristic algorithm implementation
- Load balancing across vehicles
- Comparing heuristic vs optimization results

**Important:** This is P0020 (VRP), superseding the blocked knapsack prompt. CLE0010 documents the insufficient gem verification error.


**PI APPROVAL (C001 Compliance):**

**Date:** 2026-04-17  
**Decision:** Option A - Clarke-Wright Savings Algorithm

**Rationale:**
- Best quality solutions among the three options
- Well-established classical heuristic (1964)
- Appropriate complexity for benchmarking LLM implementation
- Moderate implementation difficulty (priority queue, route merging)

**Algorithm Overview:**

Clarke-Wright Savings Algorithm:
1. Start with each customer on separate route (depot → customer → depot)
2. Calculate savings for merging each pair: savings(i,j) = d(depot,i) + d(depot,j) - d(i,j)
3. Sort pairs by savings (highest first)
4. Merge routes greedily while respecting capacity constraints
5. Result: Routes with customers merged by highest savings

**Implementation Requirements:**

- Calculate all pairwise savings
- Sort by savings (descending)
- Merge algorithm respecting:
  * Vehicle capacity constraints
  * Route feasibility (customers can only be in one route)
  * Depot start/end requirements

**Expected Behavior:**

Good solutions for VRP, though not guaranteed optimal. OR-Tools reference will likely find better (or equal) solutions using optimization rather than heuristic construction.

**Approved for implementation in P0020.**

---

---

# P0021: Assignment Problem - Algorithm Selection

**Date:** 2026-04-17  
**Status:** Awaiting PI approval  
**Architect:** Claude

## Problem Description

**Assignment Problem (Linear Sum Assignment):**
- Given: n workers, n tasks, cost matrix C[i][j] for assigning worker i to task j
- Goal: Find one-to-one assignment minimizing total cost
- Each worker assigned to exactly one task
- Each task assigned to exactly one worker
- Complexity: Polynomial O(n³) with Hungarian algorithm

## Reference Implementation

**Gem:** OR-Tools (already in project)
**Module:** `ORTools::LinearSumAssignment`
**API:** `add_arc_with_cost(worker, task, cost)`, `solve()`, `optimal_cost()`

## Algorithm Options

### Option A: Hungarian Algorithm (Exact, Polynomial)

**Description:** Classic combinatorial optimization algorithm
**Complexity:** O(n³)
**Quality:** Always finds optimal solution
**Implementation:** ~150-200 lines (augmenting path + dual updates)

**Advantages:**
- Exact polynomial algorithm (different complexity class from TSP/VRP)
- Well-defined correctness criterion (optimal cost match)
- Tests corrections on non-NP-hard problem
- Good UI potential (assignment matrix visualization)

**Disadvantages:**
- More complex than greedy heuristic
- Requires understanding of augmenting paths and dual variables


### Option B: Greedy Heuristic (Fast, Approximate)

**Description:** Repeatedly assign minimum-cost worker-task pair
**Complexity:** O(n² log n)
**Quality:** Often near-optimal, not guaranteed optimal

**Advantages:**
- Simpler implementation (~50 lines)
- Fast execution
- Easy to understand and verify

**Disadvantages:**
- Not optimal (research question becomes "how good is greedy?")
- Less interesting algorithmically
- Doesn't test corrections on complex algorithm

### Option C: Auction Algorithm (Exact, Different Approach)

**Description:** Market-based iterative approach with bidding
**Complexity:** O(n³) typical, can be faster in practice
**Quality:** Finds optimal solution

**Advantages:**
- Different algorithmic paradigm (market-based vs graph-based)
- Interesting alternative to Hungarian

**Disadvantages:**
- Less common reference implementation
- Requires understanding auction/bidding mechanics
- Similar implementation complexity to Hungarian


## Recommendation

**Option A: Hungarian Algorithm**

**Rationale:**
1. ✅ **Tests corrections on exact polynomial algorithm** - Different from NP-hard TSP/VRP
2. ✅ **Clear correctness criterion** - Optimal cost must match OR-Tools
3. ✅ **Algorithmic depth** - Complex enough to test LLM on matching theory
4. ✅ **Good UI potential** - Assignment matrix, bipartite graph visualization
5. ✅ **Standard algorithm** - Well-documented, clear reference materials

**Comparison with VRP:**
- VRP: NP-hard, heuristic (Clarke-Wright), approximate solution
- Assignment: P (polynomial), exact algorithm, optimal solution guaranteed

This provides diversity in complexity classes for the paper.

## Research Questions

If Hungarian algorithm implemented:
- Can LLM correctly implement augmenting path algorithm?
- Will it handle dual variable updates correctly?
- How will it handle edge cases (zero costs, negative costs, unbalanced assignments)?
- Does governance framework work for exact algorithms vs heuristics?

## Fixtures Needed

**5 test cases:**
1. Small 3x3 (manual verification possible)
2. Symmetric 5x5 (workers and tasks have similar structure)
3. Asymmetric 8x8 (diverse cost range)
4. Sparse 10x10 (many high-cost/impossible assignments)
5. Dense 15x15 (all assignments reasonable)

## Awaiting PI Decision

**Options:** A (Hungarian), B (Greedy), or C (Auction)

**Please approve one option to proceed with P0021.**


---

# P0021: Assignment Problem Implementation

**Date:** 2026-04-17  
**Status:** Ready for implementation  
**Architect:** Claude  
**Algorithm:** Hungarian Algorithm (PI approved Option A)

## Problem Statement

Implement the Linear Sum Assignment Problem solver using the Hungarian algorithm.

**Problem definition:**
- Input: n workers, n tasks, cost matrix C[i][j] for assigning worker i to task j
- Goal: Find one-to-one assignment minimizing total cost
- Constraints: Each worker assigned to exactly one task, each task to exactly one worker
- Output: Assignment array and total cost

**Complexity:** O(n³) polynomial time (exact algorithm)

## Algorithm: Hungarian Algorithm

**Overview:**
The Hungarian algorithm finds optimal assignment in bipartite graphs by:
1. Creating feasible labeling (dual variables)
2. Finding augmenting paths in equality subgraph
3. Updating labels when no augmenting path exists
4. Repeating until perfect matching found

**Key concepts:**
- **Feasible labeling:** Label workers u[i] and tasks v[j] such that u[i] + v[j] ≥ C[i][j] for all i,j
- **Equality edges:** Edges where u[i] + v[j] = C[i][j]
- **Equality subgraph:** Graph containing only equality edges
- **Augmenting path:** Path that alternates unmatched/matched edges, starting/ending at unmatched vertices


**Algorithm steps:**

1. **Initialize labels:**
   - u[i] = max(C[i][j]) for all j (worker labels)
   - v[j] = 0 for all j (task labels)

2. **Build equality subgraph:**
   - Include edge (i,j) if u[i] + v[j] = C[i][j]

3. **Find maximum matching in equality subgraph:**
   - Use augmenting paths (BFS or DFS)
   - If matching size = n, done (optimal found)

4. **Update labels (if matching incomplete):**
   - Find minimum slack: δ = min{u[i] + v[j] - C[i][j]} over edges not in equality subgraph
   - Update: u[i] -= δ for vertices in alternating tree, v[j] += δ for matched tasks in tree
   - This adds new equality edges without removing existing ones

5. **Repeat steps 3-4 until complete matching found**

**Reference materials:**
- Kuhn's original paper (1955)
- Papadimitriou & Steiglitz "Combinatorial Optimization" Chapter 11
- Wikipedia "Hungarian algorithm" for implementation details


## Test Fixtures

Create 5 assignment problem fixtures in `db/seeds.rb`:

### Fixture 1: assignment_tiny_3x3
```ruby
{
  name: "assignment_tiny_3x3",
  workers: 3,
  tasks: 3,
  cost_matrix: [
    [9, 2, 7],
    [6, 4, 3],
    [5, 8, 1]
  ],
  description: "Tiny 3x3 for manual verification"
}
```
**Expected:** Optimal assignment with total cost (manually verify: assign worker 0→task 1 (cost 2), worker 1→task 2 (cost 3), worker 2→task 0 (cost 5), total = 10)

### Fixture 2: assignment_small_5x5
```ruby
{
  name: "assignment_small_5x5",
  workers: 5,
  tasks: 5,
  cost_matrix: [
    [12, 18, 20, 17, 15],
    [19, 23, 21, 18, 19],
    [20, 15, 19, 22, 24],
    [14, 21, 25, 19, 16],
    [18, 17, 22, 20, 23]
  ],
  description: "Small symmetric-ish problem"
}
```


### Fixture 3: assignment_asymmetric_8x8
```ruby
{
  name: "assignment_asymmetric_8x8",
  workers: 8,
  tasks: 8,
  cost_matrix: [
    [82, 83, 69, 92, 52, 73, 48, 27],
    [77, 37, 49, 92, 11, 69, 87, 30],
    [11, 69, 5, 86, 21, 78, 58, 24],
    [13, 36, 16, 5, 28, 36, 24, 57],
    [42, 93, 37, 65, 17, 60, 87, 95],
    [81, 45, 91, 27, 24, 41, 15, 33],
    [89, 16, 23, 34, 45, 56, 67, 78],
    [12, 34, 56, 78, 90, 23, 45, 67]
  ],
  description: "Asymmetric costs with wide range"
}
```

### Fixture 4: assignment_sparse_10x10
```ruby
{
  name: "assignment_sparse_10x10",
  workers: 10,
  tasks: 10,
  cost_matrix: [
    [250, 400, 350, 400, 600, 240, 300, 280, 450, 500],
    [400, 600, 350, 150, 200, 450, 500, 380, 420, 480],
    [200, 100, 250, 320, 280, 170, 190, 220, 260, 300],
    [300, 200, 100, 220, 240, 280, 310, 290, 340, 360],
    [500, 450, 400, 180, 150, 380, 420, 440, 390, 410],
    [350, 280, 300, 250, 200, 120, 140, 160, 180, 200],
    [400, 380, 360, 340, 320, 300, 90, 110, 130, 150],
    [450, 430, 410, 390, 370, 350, 330, 80, 120, 140],
    [500, 480, 460, 440, 420, 400, 380, 360, 70, 100],
    [550, 530, 510, 490, 470, 450, 430, 410, 390, 60]
  ],
  description: "Sparse (diagonal pattern with low costs)"
}
```


### Fixture 5: assignment_dense_15x15
```ruby
{
  name: "assignment_dense_15x15",
  workers: 15,
  tasks: 15,
  cost_matrix: [
    [23, 45, 67, 34, 56, 78, 12, 34, 56, 78, 90, 23, 45, 67, 89],
    [34, 56, 78, 90, 12, 34, 56, 78, 90, 12, 34, 56, 78, 90, 12],
    [45, 67, 89, 23, 45, 67, 89, 23, 45, 67, 89, 23, 45, 67, 89],
    [56, 78, 12, 34, 56, 78, 12, 34, 56, 78, 12, 34, 56, 78, 12],
    [67, 89, 23, 45, 67, 89, 23, 45, 67, 89, 23, 45, 67, 89, 23],
    [78, 12, 34, 56, 78, 12, 34, 56, 78, 12, 34, 56, 78, 12, 34],
    [89, 23, 45, 67, 89, 23, 45, 67, 89, 23, 45, 67, 89, 23, 45],
    [12, 34, 56, 78, 12, 34, 56, 78, 12, 34, 56, 78, 12, 34, 56],
    [23, 45, 67, 89, 23, 45, 67, 89, 23, 45, 67, 89, 23, 45, 67],
    [34, 56, 78, 12, 34, 56, 78, 12, 34, 56, 78, 12, 34, 56, 78],
    [45, 67, 89, 23, 45, 67, 89, 23, 45, 67, 89, 23, 45, 67, 89],
    [56, 78, 12, 34, 56, 78, 12, 34, 56, 78, 12, 34, 56, 78, 12],
    [67, 89, 23, 45, 67, 89, 23, 45, 67, 89, 23, 45, 67, 89, 23],
    [78, 12, 34, 56, 78, 12, 34, 56, 78, 12, 34, 56, 78, 12, 34],
    [89, 23, 45, 67, 89, 23, 45, 67, 89, 23, 45, 67, 89, 23, 45]
  ],
  description: "Dense 15x15 with all reasonable costs"
}
```


## Rails Implementation Requirements

### 1. Database Model: `AssignmentProblem`

**Migration:**
```ruby
class CreateAssignmentProblems < ActiveRecord::Migration[7.2]
  def change
    create_table :assignment_problems do |t|
      t.string :name, null: false, index: { unique: true }
      t.integer :workers, null: false
      t.integer :tasks, null: false
      t.text :cost_matrix, null: false  # JSON serialized
      t.text :description
      t.timestamps
    end
  end
end
```

**Model (`app/models/assignment_problem.rb`):**
```ruby
class AssignmentProblem < ApplicationRecord
  serialize :cost_matrix, coder: JSON
  
  validates :name, presence: true, uniqueness: true
  validates :workers, :tasks, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validate :cost_matrix_dimensions
  
  private
  
  def cost_matrix_dimensions
    return unless cost_matrix.is_a?(Array)
    unless cost_matrix.length == workers && cost_matrix.all? { |row| row.is_a?(Array) && row.length == tasks }
      errors.add(:cost_matrix, "must be #{workers}x#{tasks} matrix")
    end
  end
end
```


### 2. Solver Service: `AssignmentSolver`

**File:** `app/services/assignment_solver.rb`

**Interface:**
```ruby
class AssignmentSolver
  def initialize(cost_matrix)
    @cost_matrix = cost_matrix
    @n = cost_matrix.length
  end
  
  def solve
    # Returns: { assignment: [task indices for each worker], cost: total_cost }
    # Example: { assignment: [1, 2, 0, 3, 4], cost: 157 }
  end
end
```

**Implementation requirements:**
- Pure Ruby implementation (no external gems except standard library)
- Hungarian algorithm with augmenting paths
- Handle floating-point costs (use proper epsilon for comparisons)
- Return assignment array where assignment[i] = task assigned to worker i
- Return total cost

**Edge cases:**
- Zero costs (valid, treat normally)
- Negative costs (should work, though unusual)
- Identical rows/columns (may have multiple optimal solutions)
- Large costs (ensure no integer overflow)


### 3. Reference Solver: `GemAssignmentSolver`

**File:** `app/services/gem_assignment_solver.rb`

**Use OR-Tools LinearSumAssignment:**
```ruby
require "or_tools"

class GemAssignmentSolver
  def initialize(cost_matrix)
    @cost_matrix = cost_matrix
    @n = cost_matrix.length
  end
  
  def solve
    assignment = ORTools::LinearSumAssignment.new
    
    @n.times do |worker|
      @n.times do |task|
        cost = (@cost_matrix[worker][task] * 1000).to_i  # Scale to integer
        assignment.add_arc_with_cost(worker, task, cost)
      end
    end
    
    status = assignment.solve
    
    if status == :optimal
      result = Array.new(@n)
      @n.times do |worker|
        result[worker] = assignment.right_mate(worker)
      end
      
      total_cost = result.each_with_index.sum { |task, worker| @cost_matrix[worker][task] }
      
      { assignment: result, cost: total_cost }
    else
      { assignment: nil, cost: nil, error: "No solution found" }
    end
  end
end
```

**Note:** OR-Tools requires integer costs, so scale floating-point costs by 1000


### 4. Validation Service: `AssignmentSolutionValidator`

**File:** `app/services/assignment_solution_validator.rb`

**Validations:**
1. **Valid assignment:** Each worker assigned to exactly one task
2. **Valid task assignment:** Each task assigned to exactly one worker  
3. **Correct cost calculation:** Sum of assigned costs equals reported cost
4. **Feasibility:** All assignments within bounds [0, n-1]

```ruby
class AssignmentSolutionValidator
  def self.validate(cost_matrix, assignment, reported_cost)
    n = cost_matrix.length
    errors = []
    
    # Check assignment array length
    errors << "Assignment length mismatch" unless assignment.length == n
    
    # Check all workers assigned
    errors << "Not all workers assigned" unless assignment.all? { |t| t.is_a?(Integer) && t >= 0 && t < n }
    
    # Check one-to-one mapping
    errors << "Tasks not uniquely assigned" unless assignment.uniq.length == n
    
    # Verify cost
    actual_cost = assignment.each_with_index.sum { |task, worker| cost_matrix[worker][task] }
    errors << "Cost mismatch: reported #{reported_cost}, actual #{actual_cost}" unless (actual_cost - reported_cost).abs < 0.01
    
    { valid: errors.empty?, errors: errors, actual_cost: actual_cost }
  end
end
```


### 5. Comparison Service: `AssignmentResultComparison`

**File:** `app/services/assignment_result_comparison.rb`

**Compare candidate vs reference:**
```ruby
class AssignmentResultComparison
  def self.compare(cost_matrix, candidate_result, reference_result)
    {
      cost_difference: candidate_result[:cost] - reference_result[:cost],
      cost_ratio: candidate_result[:cost].to_f / reference_result[:cost],
      is_optimal: (candidate_result[:cost] - reference_result[:cost]).abs < 0.01,
      assignment_matches: candidate_result[:assignment] == reference_result[:assignment],
      candidate_assignment: candidate_result[:assignment],
      reference_assignment: reference_result[:assignment],
      candidate_cost: candidate_result[:cost],
      reference_cost: reference_result[:cost]
    }
  end
end
```

### 6. Runner Service: `AssignmentAttemptRunner`

**File:** `app/services/assignment_attempt_runner.rb`

**Run all fixtures:**
```ruby
class AssignmentAttemptRunner
  def self.run_all
    AssignmentProblem.all.map do |problem|
      run_single(problem)
    end
  end
  
  def self.run_single(problem)
    candidate = AssignmentSolver.new(problem.cost_matrix).solve
    reference = GemAssignmentSolver.new(problem.cost_matrix).solve
    
    validation = AssignmentSolutionValidator.validate(
      problem.cost_matrix,
      candidate[:assignment],
      candidate[:cost]
    )
    
    comparison = AssignmentResultComparison.compare(
      problem.cost_matrix,
      candidate,
      reference
    )
    
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

**File:** `test/services/assignment_solver_test.rb`

```ruby
require "test_helper"

class AssignmentSolverTest < ActiveSupport::TestCase
  test "solves tiny 3x3 problem" do
    matrix = [[9, 2, 7], [6, 4, 3], [5, 8, 1]]
    result = AssignmentSolver.new(matrix).solve
    
    assert_not_nil result[:assignment]
    assert_equal 3, result[:assignment].length
    assert result[:cost] <= 10.1  # Optimal is 10 (0→1, 1→2, 2→0)
  end
  
  test "finds optimal solution for small problem" do
    problem = assignment_problems(:assignment_small_5x5)
    candidate = AssignmentSolver.new(problem.cost_matrix).solve
    reference = GemAssignmentSolver.new(problem.cost_matrix).solve
    
    assert_equal reference[:cost], candidate[:cost], "Cost should match optimal"
  end
  
  test "produces valid assignment" do
    problem = assignment_problems(:assignment_asymmetric_8x8)
    result = AssignmentSolver.new(problem.cost_matrix).solve
    validation = AssignmentSolutionValidator.validate(
      problem.cost_matrix,
      result[:assignment],
      result[:cost]
    )
    
    assert validation[:valid], "Assignment should be valid: #{validation[:errors]}"
  end
end
```

**Additional test files:**
- `test/models/assignment_problem_test.rb` - Model validations
- `test/services/gem_assignment_solver_test.rb` - Reference solver
- `test/services/assignment_solution_validator_test.rb` - Validator logic
- `test/services/assignment_result_comparison_test.rb` - Comparison logic


## Success Criteria

1. ✅ **All 5 fixtures pass validation** - Assignments are feasible one-to-one mappings
2. ✅ **Optimal solutions found** - Candidate cost matches reference cost within 0.01 tolerance
3. ✅ **Tests pass** - All unit tests green
4. ✅ **Hungarian algorithm implemented** - Augmenting paths, dual variables, label updates
5. ✅ **Performance acceptable** - 15x15 problem solves in < 5 seconds

## Expected Behavior

**For all 5 fixtures:**
- Candidate produces valid assignment (validated)
- Candidate cost matches OR-Tools optimal cost (within 0.01)
- This demonstrates Hungarian algorithm correctness

**Comparison with TSP/VRP:**
- TSP/VRP: NP-hard, used heuristics (nearest-neighbor, Clarke-Wright)
- Assignment: P (polynomial), using exact algorithm (Hungarian)
- Both tested with fixtures and reference comparison

## Implementation Notes

**Algorithm complexity:**
- Hungarian is more complex than VRP's Clarke-Wright
- Requires understanding of matching theory, augmenting paths, dual variables
- ~150-200 lines of non-trivial algorithm code

**Testing strategy:**
- Start with 3x3 (manual verification possible)
- Verify optimality on all fixtures (compare with OR-Tools)
- Edge cases: zero costs, negative costs, ties

**UI considerations:**
- Assignment matrix visualization (workers × tasks grid)
- Highlight assigned cells
- Show total cost and comparison with optimal

---

**Ready for Codex implementation.**

**Approved algorithm:** Hungarian (exact O(n³) polynomial)  
**PI approval:** 2026-04-17 (Option A selected)

