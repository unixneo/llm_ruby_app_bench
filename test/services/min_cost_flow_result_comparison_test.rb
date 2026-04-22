require "test_helper"

class MinCostFlowResultComparisonTest < ActiveSupport::TestCase
  test "marks optimal valid candidate as exact match" do
    edges = [[0, 1, 10, 2], [1, 2, 10, 3]]
    candidate = MinCostFlowSolver::Result.new(
      optimal_cost: 50,
      flow_edges: [[0, 1, 10], [1, 2, 10]],
      source: "successive-shortest-path",
      iterations: 1,
      total_flow: 10,
      demand_satisfied: true
    )
    reference = GemMinCostFlowSolver::Result.new(
      optimal_cost: 50,
      flow_edges: [[0, 1, 10], [1, 2, 10]],
      source: "or-tools",
      reference_version: GemMinCostFlowSolver::REFERENCE_VERSION,
      total_flow: 10,
      demand_satisfied: true
    )

    comparison = MinCostFlowResultComparison.compare(3, edges, 0, 2, 10, candidate, reference)

    assert_equal "exact_match", comparison.fetch(:status)
    assert comparison.fetch(:is_optimal)
    assert_equal 0, comparison.fetch(:cost_difference)
  end
end
