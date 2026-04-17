require "test_helper"

class GemVrpSolverTest < ActiveSupport::TestCase
  test "or tools returns feasible routes for all vrp fixtures" do
    VrpFixtures.all.each do |fixture|
      problem = VrpFixtures.problem_for(fixture)
      result = GemVrpSolver.new.solve(problem, fixture)

      assert_equal "or-tools", result.source
      assert_equal GemVrpSolver::REFERENCE_VERSION, result.reference_version
      assert_equal problem.num_vehicles, result.routes.length
      assert VrpSolutionValidator.new(problem).valid?(result.routes), "#{fixture.fetch(:name)} should be feasible"
      assert_kind_of Numeric, result.total_distance
      assert result.total_distance.positive?
    end
  end
end
