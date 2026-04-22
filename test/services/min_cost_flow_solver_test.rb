require "test_helper"

class MinCostFlowSolverTest < ActiveSupport::TestCase
  test "solves simple 4-node problem" do
    fixture = MinCostFlowFixtures.simple_4
    result = MinCostFlowSolver.new(
      fixture.fetch(:nodes),
      fixture.fetch(:edges),
      fixture.fetch(:source),
      fixture.fetch(:sink),
      fixture.fetch(:demand)
    ).solve

    assert_equal 90, result.optimal_cost
    assert_equal MinCostFlowSolver::SOURCE, result.source
    assert_equal 15, result.total_flow
    assert result.demand_satisfied
    assert MinCostFlowSolutionValidator.validate(
      fixture.fetch(:nodes),
      fixture.fetch(:edges),
      fixture.fetch(:source),
      fixture.fetch(:sink),
      fixture.fetch(:demand),
      result.flow_edges,
      result.optimal_cost
    ).fetch(:valid)
  end

  test "matches reference on all fixtures" do
    MinCostFlowFixtures.all.each do |fixture|
      candidate = MinCostFlowSolver.new(
        fixture.fetch(:nodes),
        fixture.fetch(:edges),
        fixture.fetch(:source),
        fixture.fetch(:sink),
        fixture.fetch(:demand)
      ).solve
      reference = GemMinCostFlowSolver.new(
        fixture.fetch(:nodes),
        fixture.fetch(:edges),
        fixture.fetch(:source),
        fixture.fetch(:sink),
        fixture.fetch(:demand)
      ).solve

      assert_equal reference.optimal_cost, candidate.optimal_cost, "#{fixture.fetch(:name)} should match reference cost"
      assert_equal reference.total_flow, candidate.total_flow, "#{fixture.fetch(:name)} should satisfy the same flow"
      assert candidate.demand_satisfied, "#{fixture.fetch(:name)} should satisfy demand"
    end
  end

  test "handles unreachable demand without infinite loop" do
    edges = [[0, 1, 3, 1], [1, 2, 3, 1]]
    result = MinCostFlowSolver.new(4, edges, 0, 3, 5).solve

    assert_equal 0, result.optimal_cost
    assert_equal 0, result.total_flow
    refute result.demand_satisfied
    assert_equal [[0, 1, 0], [1, 2, 0]], result.flow_edges
  end
end
