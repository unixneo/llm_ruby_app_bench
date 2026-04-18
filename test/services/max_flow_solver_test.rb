require "test_helper"

class MaxFlowSolverTest < ActiveSupport::TestCase
  test "solves simple 4-node problem" do
    edges = [[0, 1, 10], [0, 2, 5], [1, 3, 15], [2, 3, 10]]
    result = MaxFlowSolver.new(4, edges, 0, 3).solve

    assert_equal 15, result.max_flow
    assert_equal MaxFlowSolver::SOURCE, result.source
    assert MaxFlowSolutionValidator.validate(4, edges, 0, 3, result.flow_edges, result.max_flow).fetch(:valid)
  end

  test "matches reference on all fixtures" do
    MaxFlowFixtures.all.each do |fixture|
      candidate = MaxFlowSolver.new(fixture.fetch(:nodes), fixture.fetch(:edges), fixture.fetch(:source), fixture.fetch(:sink)).solve
      reference = GemMaxFlowSolver.new(fixture.fetch(:nodes), fixture.fetch(:edges), fixture.fetch(:source), fixture.fetch(:sink)).solve

      assert_equal reference.max_flow, candidate.max_flow, "#{fixture.fetch(:name)} should match reference max flow"
      assert MaxFlowSolutionValidator.validate(
        fixture.fetch(:nodes),
        fixture.fetch(:edges),
        fixture.fetch(:source),
        fixture.fetch(:sink),
        candidate.flow_edges,
        candidate.max_flow
      ).fetch(:valid)
    end
  end

  test "handles no path from source to sink" do
    edges = [[0, 1, 10], [2, 3, 10]]
    result = MaxFlowSolver.new(4, edges, 0, 3).solve

    assert_equal 0, result.max_flow
    assert_equal [[0, 1, 0], [2, 3, 0]], result.flow_edges
  end

  test "handles parallel edges and self loops" do
    edges = [[0, 1, 4], [0, 1, 6], [1, 1, 100], [1, 2, 8]]
    result = MaxFlowSolver.new(3, edges, 0, 2).solve

    assert_equal 8, result.max_flow
    assert_equal 0, result.flow_edges.fetch(2).fetch(2)
    assert MaxFlowSolutionValidator.validate(3, edges, 0, 2, result.flow_edges, result.max_flow).fetch(:valid)
  end
end
