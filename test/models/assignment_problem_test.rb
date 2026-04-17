require "test_helper"

class AssignmentProblemTest < ActiveSupport::TestCase
  test "validates cost matrix dimensions" do
    problem = AssignmentProblem.new(
      name: "bad_matrix",
      workers: 2,
      tasks: 2,
      cost_matrix: [[1, 2, 3], [4, 5, 6]]
    )

    refute problem.valid?
    assert_includes problem.errors[:cost_matrix], "must be a 2x2 numeric matrix"
  end

  test "requires square matrix for one to one assignment" do
    problem = AssignmentProblem.new(
      name: "rectangular",
      workers: 2,
      tasks: 3,
      cost_matrix: [[1, 2, 3], [4, 5, 6]]
    )

    refute problem.valid?
    assert_includes problem.errors[:tasks], "must equal workers for one-to-one assignment"
  end
end
