require "test_helper"

class NQueensProblemTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    problem = NQueensProblem.new(
      name: "nqueens_8",
      n: 8,
      description: "Classic 8-queens fixture"
    )

    assert problem.valid?
  end

  test "invalid without name" do
    problem = NQueensProblem.new(n: 4, description: "missing name")

    refute problem.valid?
    assert_includes problem.errors[:name], "can't be blank"
  end

  test "invalid with nonpositive n" do
    problem = NQueensProblem.new(name: "bad", n: 0, description: "bad n")

    refute problem.valid?
    assert_includes problem.errors[:n], "must be greater than 0"
  end
end

