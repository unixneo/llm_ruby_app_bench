class VrpSolutionValidator
  def initialize(problem)
    @problem = problem
  end

  def valid?(routes)
    errors_for(routes).empty?
  end

  def errors_for(routes)
    errors = []
    visited = []

    routes.each_with_index do |route, vehicle_index|
      errors << "vehicle #{vehicle_index} route must start at depot" unless route.first == @problem.depot
      errors << "vehicle #{vehicle_index} route must end at depot" unless route.last == @problem.depot

      load = @problem.route_load(route)
      errors << "vehicle #{vehicle_index} load #{load} exceeds capacity #{@problem.vehicle_capacity}" if load > @problem.vehicle_capacity

      visited.concat(route[1...-1] || [])
    end

    expected = @problem.customer_indices.sort
    errors << "customers visited do not match expected set" unless visited.sort == expected
    errors << "customers must be visited exactly once" unless visited.uniq.length == visited.length

    errors
  end
end
