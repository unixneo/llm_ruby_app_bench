require "test_helper"

class SatProblemTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    problem = SatProblem.new(
      name: "sat_trivial_sat_2",
      num_vars: 2,
      clauses: [[1, 2], [-1, 2]],
      satisfiable: true,
      description: "valid sat fixture"
    )

    assert problem.valid?
  end

  test "invalid with malformed clauses" do
    problem = SatProblem.new(
      name: "bad_sat",
      num_vars: 2,
      clauses: [[1, 0]],
      satisfiable: true,
      description: "invalid literal 0"
    )

    refute problem.valid?
    assert_includes problem.errors[:clauses], "must be an array of non-empty literal arrays"
  end

  test "invalid without boolean satisfiable flag" do
    problem = SatProblem.new(
      name: "missing_sat_flag",
      num_vars: 1,
      clauses: [[1]],
      description: "missing satisfiable"
    )

    refute problem.valid?
    assert_includes problem.errors[:satisfiable], "is not included in the list"
  end
end
