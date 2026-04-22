require "test_helper"

class MinCostFlowProblemTest < ActiveSupport::TestCase
  test "validates edge quadruples" do
    problem = MinCostFlowProblem.new(
      name: "bad_edges",
      nodes: 4,
      source: 0,
      sink: 3,
      demand: 5,
      edges: [[0, 1, 10], [1, 3, -1, 2]]
    )

    refute problem.valid?
    assert_includes problem.errors[:edges], "must be array of [from, to, capacity, cost] integer quadruples with nonnegative capacities"
  end

  test "validates source and sink range" do
    problem = MinCostFlowProblem.new(
      name: "bad_source",
      nodes: 3,
      source: 3,
      sink: 3,
      demand: 4,
      edges: [[0, 1, 5, 2]]
    )

    refute problem.valid?
    assert_includes problem.errors[:source], "must be in range [0, 2]"
    assert_includes problem.errors[:sink], "must be in range [0, 2]"
    assert_includes problem.errors[:sink], "cannot equal source"
  end
end
