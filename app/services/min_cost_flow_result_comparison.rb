class MinCostFlowResultComparison
  TOLERANCE = 0.01

  def self.compare(nodes, edges, source, sink, demand, candidate_result, reference_result)
    new(nodes, edges, source, sink, demand).compare(candidate_result, reference_result)
  end

  def initialize(nodes, edges, source, sink, demand)
    @nodes = nodes
    @edges = edges
    @source = source
    @sink = sink
    @demand = demand
  end

  def compare(candidate_result, reference_result)
    candidate_validation = MinCostFlowSolutionValidator.validate(
      @nodes,
      @edges,
      @source,
      @sink,
      @demand,
      candidate_result.flow_edges,
      candidate_result.optimal_cost
    )
    reference_validation = MinCostFlowSolutionValidator.validate(
      @nodes,
      @edges,
      @source,
      @sink,
      @demand,
      reference_result.flow_edges,
      reference_result.optimal_cost
    )
    cost_difference = candidate_result.optimal_cost - reference_result.optimal_cost

    {
      status: status(candidate_validation, reference_validation, cost_difference),
      cost_difference: cost_difference,
      is_optimal: cost_difference.abs <= TOLERANCE,
      candidate_optimal_cost: candidate_result.optimal_cost,
      reference_optimal_cost: reference_result.optimal_cost,
      candidate_flow_edges: candidate_result.flow_edges,
      reference_flow_edges: reference_result.flow_edges,
      candidate_errors: candidate_validation.fetch(:errors),
      reference_errors: reference_validation.fetch(:errors)
    }
  end

  private

  def status(candidate_validation, reference_validation, cost_difference)
    return "infeasible" unless candidate_validation.fetch(:valid)
    return "reference_failed" unless reference_validation.fetch(:valid)

    cost_difference.abs <= TOLERANCE ? "exact_match" : "length_mismatch"
  end
end
