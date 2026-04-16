require "test_helper"

class GemTspSolverTest < ActiveSupport::TestCase
  test "returns OR-Tools result for known fixtures" do
    solver = GemTspSolver.new

    TspFixtures.all.each do |fixture|
      result = solver.solve(TspFixtures.problem_for(fixture))

      assert_equal "or-tools", result.source
      assert_equal "or-tools-guided-local-search-v1", result.reference_version
      assert_equal :path_cheapest_arc, result.first_solution_strategy
      assert_equal :guided_local_search, result.local_search_metaheuristic
      assert_equal 1, result.time_limit_seconds
      assert_kind_of Numeric, result.length
      assert_equal result.tour.first, result.tour.last
      assert result.length.positive?
      assert_in_delta fixture.fetch(:optimal_length), result.length, 1e-9, "#{fixture.fetch(:name)} length mismatch" if fixture.key?(:optimal_length)
    end
  end

  test "solves twenty city fixture" do
    result = GemTspSolver.new.solve(TspFixtures.problem_for(TspFixtures.random_20))

    assert_equal 21, result.tour.length
    assert_equal result.tour.first, result.tour.last
    assert_kind_of Numeric, result.length
    assert result.length.positive?
    assert_equal "or-tools-guided-local-search-v1", result.reference_version
  end

  test "solves world city fixture" do
    result = GemTspSolver.new.solve(TspFixtures.problem_for(TspFixtures.world_cities_13))

    assert_equal 14, result.tour.length
    assert_equal result.tour.first, result.tour.last
    assert_kind_of Numeric, result.length
    assert result.length.positive?
    assert_equal "or-tools-guided-local-search-v1", result.reference_version
  end
end
