require "or-tools"

class GemVrpSolver
  FIRST_SOLUTION_STRATEGY = :path_cheapest_arc
  LOCAL_SEARCH_METAHEURISTIC = :guided_local_search
  TIME_LIMIT_SECONDS = 1
  REFERENCE_VERSION = "or-tools-routing-cvrp-guided-local-search-v1"

  Result = Data.define(
    :routes,
    :total_distance,
    :vehicle_loads,
    :source,
    :reference_version,
    :first_solution_strategy,
    :local_search_metaheuristic,
    :time_limit_seconds
  ) do
    def to_h
      {
        routes: routes,
        total_distance: total_distance,
        vehicle_loads: vehicle_loads,
        source: source,
        reference_version: reference_version,
        first_solution_strategy: first_solution_strategy,
        local_search_metaheuristic: local_search_metaheuristic,
        time_limit_seconds: time_limit_seconds
      }
    end
  end

  def solve(problem, _fixture = nil)
    manager = ORTools::RoutingIndexManager.new(problem.location_count, problem.num_vehicles, problem.depot)
    routing = ORTools::RoutingModel.new(manager)

    distance_callback = lambda do |from_index, to_index|
      from_node = manager.index_to_node(from_index)
      to_node = manager.index_to_node(to_index)
      problem.distance(from_node, to_node).round
    end
    distance_callback_index = routing.register_transit_callback(distance_callback)
    routing.set_arc_cost_evaluator_of_all_vehicles(distance_callback_index)

    demand_callback = lambda do |from_index|
      from_node = manager.index_to_node(from_index)
      problem.demands.fetch(from_node)
    end
    demand_callback_index = routing.register_unary_transit_callback(demand_callback)
    routing.add_dimension_with_vehicle_capacity(
      demand_callback_index,
      0,
      Array.new(problem.num_vehicles, problem.vehicle_capacity),
      true,
      "Capacity"
    )

    assignment = routing.solve(
      first_solution_strategy: FIRST_SOLUTION_STRATEGY,
      local_search_metaheuristic: LOCAL_SEARCH_METAHEURISTIC,
      time_limit: TIME_LIMIT_SECONDS
    )
    raise "OR-Tools did not return a VRP assignment" unless assignment

    routes = extract_routes(manager, routing, assignment, problem.num_vehicles)

    Result.new(
      routes: routes,
      total_distance: routes.sum { |route| problem.route_distance(route) },
      vehicle_loads: routes.map { |route| problem.route_load(route) },
      source: "or-tools",
      reference_version: REFERENCE_VERSION,
      first_solution_strategy: FIRST_SOLUTION_STRATEGY,
      local_search_metaheuristic: LOCAL_SEARCH_METAHEURISTIC,
      time_limit_seconds: TIME_LIMIT_SECONDS
    )
  end

  private

  def extract_routes(manager, routing, assignment, num_vehicles)
    num_vehicles.times.map do |vehicle_index|
      index = routing.start(vehicle_index)
      route = []

      until routing.end?(index)
        route << manager.index_to_node(index)
        index = assignment.value(routing.next_var(index))
      end

      route << manager.index_to_node(index)
    end
  end
end
