require "test_helper"

class AssignmentResultComparisonTest < ActiveSupport::TestCase
  test "marks optimal candidate as exact match even with different optimal assignment" do
    matrix = [[1, 1], [1, 1]]
    candidate = AssignmentSolver::Result.new(assignment: [0, 1], cost: 2, source: "hungarian")
    reference = GemAssignmentSolver::Result.new(
      assignment: [1, 0],
      cost: 2,
      source: "or-tools",
      reference_version: GemAssignmentSolver::REFERENCE_VERSION,
      scaled_optimal_cost: 2000
    )

    comparison = AssignmentResultComparison.compare(matrix, candidate, reference)

    assert_equal "exact_match", comparison.fetch(:status)
    assert comparison.fetch(:is_optimal)
    refute comparison.fetch(:assignment_matches)
  end
end
