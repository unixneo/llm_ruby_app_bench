class VrpSolver
  Result = Data.define(:routes, :total_distance, :vehicle_loads, :source) do
    def to_h
      {
        routes: routes,
        total_distance: total_distance,
        vehicle_loads: vehicle_loads,
        source: source
      }
    end
  end

  def solve(problem)
    routes = problem.customer_indices.map { |customer| [problem.depot, customer, problem.depot] }
    route_loads = routes.to_h { |route| [route.object_id, problem.route_load(route)] }

    savings(problem).each do |saving|
      first_route = routes.find { |route| route.include?(saving.fetch(:from)) }
      second_route = routes.find { |route| route.include?(saving.fetch(:to)) }
      next unless first_route && second_route
      next if first_route.equal?(second_route)
      next unless route_endpoint?(first_route, saving.fetch(:from))
      next unless route_endpoint?(second_route, saving.fetch(:to))

      merged_load = route_loads.fetch(first_route.object_id) + route_loads.fetch(second_route.object_id)
      next if merged_load > problem.vehicle_capacity

      merged_route = merge_routes(problem.depot, first_route, saving.fetch(:from), second_route, saving.fetch(:to))
      routes.delete(first_route)
      routes.delete(second_route)
      routes << merged_route
      route_loads[merged_route.object_id] = merged_load
    end

    raise ArgumentError, "solution requires #{routes.length} routes but only #{problem.num_vehicles} vehicles are available" if routes.length > problem.num_vehicles

    routes = routes.sort_by { |route| route[1] || Float::INFINITY }
    routes += Array.new(problem.num_vehicles - routes.length) { [problem.depot, problem.depot] }

    build_result(problem, routes)
  end

  private

  def savings(problem)
    problem.customer_indices.combination(2).flat_map do |first, second|
      [
        saving_for(problem, first, second),
        saving_for(problem, second, first)
      ]
    end.sort_by { |entry| [-entry.fetch(:saving), entry.fetch(:from), entry.fetch(:to)] }
  end

  def saving_for(problem, from, to)
    {
      from: from,
      to: to,
      saving: problem.distance(problem.depot, from) + problem.distance(to, problem.depot) - problem.distance(from, to)
    }
  end

  def route_endpoint?(route, customer)
    route[1] == customer || route[-2] == customer
  end

  def merge_routes(depot, first_route, first_customer, second_route, second_customer)
    first_customers = first_route[1...-1]
    second_customers = second_route[1...-1]

    first_customers = first_customers.reverse unless first_customers.last == first_customer
    second_customers = second_customers.reverse unless second_customers.first == second_customer

    [depot] + first_customers + second_customers + [depot]
  end

  def build_result(problem, routes)
    Result.new(
      routes: routes,
      total_distance: routes.sum { |route| problem.route_distance(route) },
      vehicle_loads: routes.map { |route| problem.route_load(route) },
      source: "clarke-wright-savings"
    )
  end
end
