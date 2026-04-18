require "test_helper"

class MaxFlowResultComparisonTest < ActiveSupport::TestCase
  test "marks optimal valid candidate as exact match" do
    edges = [[0, 1, 10], [1, 2, 10]]
    candidate = MaxFlowSolver::Result.new(max_flow: 10, flow_edges: [[0, 1, 10], [1, 2, 10]], source: "edmonds-karp")
    reference = GemMaxFlowSolver::Result.new(
      max_flow: 10,
      flow_edges: [[0, 1, 10], [1, 2, 10]],
      source: "or-tools",
      reference_version: GemMaxFlowSolver::REFERENCE_VERSION
    )

    comparison = MaxFlowResultComparison.compare(3, edges, 0, 2, candidate, reference)

    assert_equal "exact_match", comparison.fetch(:status)
    assert comparison.fetch(:is_optimal)
    assert_equal 0, comparison.fetch(:flow_difference)
  end
end
