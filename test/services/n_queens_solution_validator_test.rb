require "test_helper"

class NQueensSolutionValidatorTest < ActiveSupport::TestCase
  test "accepts valid n=8 solution set" do
    problem = NQueensProblem.new(name: "nqueens_8", n: 8, description: "n8")
    result = NQueensSolver.new(8).solve

    validation = NQueensSolutionValidator.validate(problem, result)

    assert validation.fetch(:valid)
    assert_empty validation.fetch(:errors)
  end

  test "rejects diagonal conflicts" do
    problem = NQueensProblem.new(name: "nqueens_4", n: 4, description: "n4")
    bad_result = NQueensSolver::Result.new(
      n: 4,
      count: 1,
      solutions: [[0, 1, 2, 3]],
      method: :backtracking,
      duration: 0.01,
      source: "backtracking"
    )

    validation = NQueensSolutionValidator.validate(problem, bad_result)

    refute validation.fetch(:valid)
    assert_includes validation.fetch(:errors).join(" "), "diagonal conflict"
  end
end

