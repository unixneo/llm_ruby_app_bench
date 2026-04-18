class MaxFlowResultComparison
  TOLERANCE = 0.01

  def self.compare(nodes, edges, source, sink, candidate_result, reference_result)
    new(nodes, edges, source, sink).compare(candidate_result, reference_result)
  end

  def initialize(nodes, edges, source, sink)
    @nodes = nodes
    @edges = edges
    @source = source
    @sink = sink
  end

  def compare(candidate_result, reference_result)
    candidate_validation = MaxFlowSolutionValidator.validate(
      @nodes,
      @edges,
      @source,
      @sink,
      candidate_result.flow_edges,
      candidate_result.max_flow
    )
    reference_validation = MaxFlowSolutionValidator.validate(
      @nodes,
      @edges,
      @source,
      @sink,
      reference_result.flow_edges,
      reference_result.max_flow
    )
    flow_difference = candidate_result.max_flow - reference_result.max_flow

    {
      status: status(candidate_validation, reference_validation, flow_difference),
      flow_difference: flow_difference,
      flow_ratio: reference_result.max_flow.zero? ? nil : candidate_result.max_flow.to_f / reference_result.max_flow,
      is_optimal: flow_difference.abs <= TOLERANCE,
      candidate_max_flow: candidate_result.max_flow,
      reference_max_flow: reference_result.max_flow,
      candidate_flow_edges: candidate_result.flow_edges,
      reference_flow_edges: reference_result.flow_edges,
      candidate_errors: candidate_validation.fetch(:errors),
      reference_errors: reference_validation.fetch(:errors)
    }
  end

  private

  def status(candidate_validation, reference_validation, flow_difference)
    return "infeasible" unless candidate_validation.fetch(:valid)
    return "reference_failed" unless reference_validation.fetch(:valid)

    flow_difference.abs <= TOLERANCE ? "exact_match" : "length_mismatch"
  end
end
