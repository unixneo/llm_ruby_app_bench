

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

