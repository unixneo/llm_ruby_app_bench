

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
