require "test_helper"

class VrpSolverTest < ActiveSupport::TestCase
  test "clarke wright returns feasible routes for all fixtures" do
    VrpFixtures.all.each do |fixture|
      problem = VrpFixtures.problem_for(fixture)
      result = VrpSolver.new.solve(problem)

      assert_equal "clarke-wright-savings", result.source
      assert_equal problem.num_vehicles, result.routes.length
      assert VrpSolutionValidator.new(problem).valid?(result.routes), "#{fixture.fetch(:name)} should be feasible"
      assert_kind_of Numeric, result.total_distance
      assert result.total_distance.positive?
      assert result.vehicle_loads.all? { |load| load <= problem.vehicle_capacity }
    end
  end

  test "visits every customer exactly once" do
    problem = VrpFixtures.problem_for(VrpFixtures.asymmetric_10)
    result = VrpSolver.new.solve(problem)
    visited = result.routes.flat_map { |route| route[1...-1] }

    assert_equal problem.customer_indices.sort, visited.sort
    assert_equal visited.uniq.length, visited.length
  end

  test "calculates total distance from route distances" do
    problem = VrpFixtures.problem_for(VrpFixtures.small_5)
    result = VrpSolver.new.solve(problem)
    expected_distance = result.routes.sum { |route| problem.route_distance(route) }

    assert_in_delta expected_distance, result.total_distance, 1e-9
  end

  test "problem rejects invalid demand" do
    assert_raises(ArgumentError) do
      VrpProblem.new(
        num_vehicles: 1,
        vehicle_capacity: 5,
        demands: [0, 6],
        depot: 0,
        distance_matrix: [[0, 1], [1, 0]]
      )
    end
  end
end
