require "test_helper"

class MaxFlowProblemTest < ActiveSupport::TestCase
  test "validates edge triples" do
    problem = MaxFlowProblem.new(
      name: "bad_edges",
      nodes: 4,
      source: 0,
      sink: 3,
      edges: [[0, 1], [1, 3, -1]]
    )

    refute problem.valid?
    assert_includes problem.errors[:edges], "must be array of [from, to, capacity] integer triples with nonnegative capacities"
  end

  test "validates source and sink range" do
    problem = MaxFlowProblem.new(
      name: "bad_source",
      nodes: 3,
      source: 3,
      sink: 3,
      edges: [[0, 1, 5]]
    )

    refute problem.valid?
    assert_includes problem.errors[:source], "must be in range [0, 2]"
    assert_includes problem.errors[:sink], "must be in range [0, 2]"
    assert_includes problem.errors[:sink], "cannot equal source"
  end
end
