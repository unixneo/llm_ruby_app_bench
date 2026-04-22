class MinCostFlowSolutionValidator
  TOLERANCE = 0.01

  def self.validate(nodes, edges, source, sink, demand, flow_edges, reported_cost)
    new(nodes, edges, source, sink, demand).validate(flow_edges, reported_cost)
  end

  def initialize(nodes, edges, source, sink, demand)
    @nodes = nodes
    @edges = edges
    @source = source
    @sink = sink
    @demand = demand
  end

  def validate(flow_edges, reported_cost)
    errors = []
    unless flow_edges.is_a?(Array) && flow_edges.length == @edges.length
      return { valid: false, errors: ["Flow edge length mismatch"], source_outflow: nil, sink_inflow: nil, calculated_cost: nil }
    end

    balances = Array.new(@nodes, 0.0)
    calculated_cost = 0.0

    @edges.zip(flow_edges).each_with_index do |((from, to, capacity, cost), flow_edge), index|
      unless flow_edge.is_a?(Array) && flow_edge.length == 3
        errors << "Flow edge #{index} must be [from, to, flow]"
        next
      end

      flow_from, flow_to, flow = flow_edge
      errors << "Flow edge #{index} endpoint mismatch: expected (#{from}, #{to}), got (#{flow_from}, #{flow_to})" unless flow_from == from && flow_to == to
      errors << "Negative flow on edge #{index} (#{from}, #{to}): #{flow}" if flow < -TOLERANCE
      errors << "Flow exceeds capacity on edge #{index} (#{from}, #{to}): #{flow} > #{capacity}" if flow - capacity > TOLERANCE

      balances[from] -= flow
      balances[to] += flow
      calculated_cost += flow * cost
    end

    (0...@nodes).each do |node|
      next if node == @source || node == @sink

      unless balances.fetch(node).abs <= TOLERANCE
        errors << "Flow conservation violated at node #{node}: net=#{balances.fetch(node)}"
      end
    end

    source_outflow = -balances.fetch(@source)
    sink_inflow = balances.fetch(@sink)
    if (source_outflow - @demand).abs > TOLERANCE
      errors << "Demand mismatch at source: expected=#{@demand}, actual=#{source_outflow}"
    end
    if (sink_inflow - @demand).abs > TOLERANCE
      errors << "Demand mismatch at sink: expected=#{@demand}, actual=#{sink_inflow}"
    end
    if (calculated_cost - reported_cost).abs > TOLERANCE
      errors << "Reported cost mismatch: reported=#{reported_cost}, calculated=#{calculated_cost}"
    end

    {
      valid: errors.empty?,
      errors: errors,
      source_outflow: source_outflow,
      sink_inflow: sink_inflow,
      calculated_cost: calculated_cost
    }
  end
end
