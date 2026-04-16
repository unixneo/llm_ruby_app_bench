require "or-tools"

class GemTspSolver
  SCALE = 1_000_000
  FIRST_SOLUTION_STRATEGY = :path_cheapest_arc
  LOCAL_SEARCH_METAHEURISTIC = :guided_local_search
  TIME_LIMIT_SECONDS = 1
  REFERENCE_VERSION = "or-tools-guided-local-search-v1"

  Result = Data.define(
    :tour,
    :length,
    :source,
    :objective_value,
    :scale,
    :reference_version,
    :first_solution_strategy,
    :local_search_metaheuristic,
    :time_limit_seconds
  ) do
    def to_h
      {
        tour: tour,
        length: length,
        source: source,
        objective_value: objective_value,
        scale: scale,
        reference_version: reference_version,
        first_solution_strategy: first_solution_strategy,
        local_search_metaheuristic: local_search_metaheuristic,
        time_limit_seconds: time_limit_seconds
      }
    end
  end

  def solve(problem, _fixture = nil)
    scaled_matrix = problem.distance_matrix.map do |row|
      row.map { |distance| (distance * SCALE).round }
    end

    manager = ORTools::RoutingIndexManager.new(scaled_matrix.length, 1, 0)
    routing = ORTools::RoutingModel.new(manager)

    distance_callback = lambda do |from_index, to_index|
      from_node = manager.index_to_node(from_index)
      to_node = manager.index_to_node(to_index)
      scaled_matrix.fetch(from_node).fetch(to_node)
    end

    callback_index = routing.register_transit_callback(distance_callback)
    routing.set_arc_cost_evaluator_of_all_vehicles(callback_index)

    assignment = routing.solve(
      first_solution_strategy: FIRST_SOLUTION_STRATEGY,
      local_search_metaheuristic: LOCAL_SEARCH_METAHEURISTIC,
      time_limit: TIME_LIMIT_SECONDS
    )
    raise "OR-Tools did not return a TSP assignment" unless assignment

    tour = extract_tour(manager, routing, assignment)
    length = tour.each_cons(2).sum { |from_index, to_index| problem.distance(from_index, to_index) }

    Result.new(
      tour: tour,
      length: length,
      source: "or-tools",
      objective_value: assignment.objective_value,
      scale: SCALE,
      reference_version: REFERENCE_VERSION,
      first_solution_strategy: FIRST_SOLUTION_STRATEGY,
      local_search_metaheuristic: LOCAL_SEARCH_METAHEURISTIC,
      time_limit_seconds: TIME_LIMIT_SECONDS
    )
  end

  private

  def extract_tour(manager, routing, assignment)
    index = routing.start(0)
    tour = []

    until routing.end?(index)
      tour << manager.index_to_node(index)
      index = assignment.value(routing.next_var(index))
    end

    tour << manager.index_to_node(index)
  end
end
