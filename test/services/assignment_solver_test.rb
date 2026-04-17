require "test_helper"

class AssignmentSolverTest < ActiveSupport::TestCase
  test "solves tiny 3x3 problem optimally" do
    matrix = [[9, 2, 7], [6, 4, 3], [5, 8, 1]]
    result = AssignmentSolver.new(matrix).solve

    assert_equal [1, 0, 2], result.assignment
    assert_equal 9, result.cost
    assert_equal AssignmentSolver::SOURCE, result.source
  end

  test "matches reference on all fixtures" do
    AssignmentFixtures.all.each do |fixture|
      matrix = fixture.fetch(:cost_matrix)
      candidate = AssignmentSolver.new(matrix).solve
      reference = GemAssignmentSolver.new(matrix).solve

      assert_in_delta reference.cost, candidate.cost, 0.01, "#{fixture.fetch(:name)} should match reference cost"
      assert AssignmentSolutionValidator.validate(matrix, candidate.assignment, candidate.cost).fetch(:valid)
    end
  end

  test "handles zero and negative costs" do
    matrix = [
      [0, -2, 4],
      [3, 0, -1],
      [2, 1, 0]
    ]
    result = AssignmentSolver.new(matrix).solve

    assert_equal [1, 2, 0], result.assignment
    assert_equal(-1, result.cost)
  end
end
