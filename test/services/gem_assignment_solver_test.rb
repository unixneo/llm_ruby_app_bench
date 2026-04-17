require "test_helper"

class GemAssignmentSolverTest < ActiveSupport::TestCase
  test "or tools linear sum assignment solves tiny fixture" do
    result = GemAssignmentSolver.new(AssignmentFixtures.tiny_3x3.fetch(:cost_matrix)).solve

    assert_equal "or-tools", result.source
    assert_equal GemAssignmentSolver::REFERENCE_VERSION, result.reference_version
    assert_equal [1, 0, 2], result.assignment
    assert_equal 9, result.cost
    assert_equal 9000, result.scaled_optimal_cost
  end
end
