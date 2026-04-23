require "test_helper"

class NQueensResultComparisonTest < ActiveSupport::TestCase
  test "returns exact_match when candidate and reference agree with known count" do
    problem = NQueensProblem.new(name: "nqueens_8", n: 8, description: "n8")
    candidate = NQueensSolver.new(8).solve
    reference = GemNQueensSolver.new(8).solve

    comparison = NQueensResultComparison.compare(problem, candidate, reference)

    assert_equal "exact_match", comparison.fetch(:status)
    assert_equal 0, comparison.fetch(:count_difference)
    assert_equal 92, comparison.fetch(:known_count)
  end

  test "returns length_mismatch when candidate count differs" do
    problem = NQueensProblem.new(name: "nqueens_4", n: 4, description: "n4")
    candidate = NQueensSolver::Result.new(
      n: 4,
      count: 1,
      solutions: [[1, 3, 0, 2]],
      method: :backtracking,
      duration: 0.01,
      source: "backtracking"
    )
    reference = GemNQueensSolver.new(4).solve

    comparison = NQueensResultComparison.compare(problem, candidate, reference)

    assert_equal "length_mismatch", comparison.fetch(:status)
    assert_equal(-1, comparison.fetch(:count_difference))
  end
end

