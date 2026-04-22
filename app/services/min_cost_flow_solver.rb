class MinCostFlowSolver
  SOURCE = "successive-shortest-path"

  Edge = Struct.new(:from, :to, :capacity, :cost, :reverse_index, :original_index, :flow, keyword_init: true)

  Result = Data.define(:optimal_cost, :flow_edges, :source, :iterations, :total_flow, :demand_satisfied) do
    def to_h
      {
        optimal_cost: optimal_cost,
        flow_edges: flow_edges,
        source: source,
        iterations: iterations,
        total_flow: total_flow,
        demand_satisfied: demand_satisfied
      }
    end
  end

  def initialize(nodes, edges, source, sink, demand)
    @nodes = nodes
    @edges = edges
    @source = source
    @sink = sink
    @demand = demand
    validate_input!
  end

  def solve
    build_residual_graph
    remaining_demand = @demand
    iterations = 0

    while remaining_demand.positive? && (path = shortest_cost_path)
      bottleneck = path.map { |node, edge_index| @graph.fetch(node).fetch(edge_index).capacity }.min
      augmentation = [bottleneck, remaining_demand].min
      augment_flow(path, augmentation)
      remaining_demand -= augmentation
      iterations += 1
    end

    total_flow = @demand - remaining_demand

    Result.new(
      optimal_cost: calculate_total_cost,
      flow_edges: original_flow_edges,
      source: SOURCE,
      iterations: iterations,
      total_flow: total_flow,
      demand_satisfied: remaining_demand.zero?
    )
  end

  def validate_flow(flow_edges, reported_cost)
    MinCostFlowSolutionValidator.validate(@nodes, @edges, @source, @sink, @demand, flow_edges, reported_cost)
  end

  private

  def validate_input!
    unless @nodes.is_a?(Integer) && @nodes.positive?
      raise ArgumentError, "nodes must be a positive integer"
    end

    unless [@source, @sink].all? { |node| node.is_a?(Integer) && node.between?(0, @nodes - 1) } && @source != @sink
      raise ArgumentError, "source and sink must be distinct node indexes"
    end

    unless @demand.is_a?(Integer) && @demand >= 0
      raise ArgumentError, "demand must be a nonnegative integer"
    end

    unless @edges.is_a?(Array) &&
        @edges.all? do |edge|
          edge.is_a?(Array) &&
            edge.length == 4 &&
            edge.all? { |value| value.is_a?(Integer) } &&
            edge.fetch(2) >= 0 &&
            edge.fetch(0).between?(0, @nodes - 1) &&
            edge.fetch(1).between?(0, @nodes - 1)
        end
      raise ArgumentError, "edges must be [from, to, capacity, cost] quadruples with valid nodes and nonnegative capacities"
    end
  end

  def build_residual_graph
    @graph = Array.new(@nodes) { [] }
    @original_edges = []

    @edges.each_with_index do |(from, to, capacity, cost), index|
      if from == to
        @original_edges[index] = Edge.new(from: from, to: to, capacity: capacity, cost: cost, reverse_index: nil, original_index: index, flow: 0)
        next
      end

      forward = Edge.new(
        from: from,
        to: to,
        capacity: capacity,
        cost: cost,
        reverse_index: @graph.fetch(to).length,
        original_index: index,
        flow: 0
      )
      backward = Edge.new(
        from: to,
        to: from,
        capacity: 0,
        cost: -cost,
        reverse_index: @graph.fetch(from).length,
        original_index: nil,
        flow: 0
      )

      @graph.fetch(from) << forward
      @graph.fetch(to) << backward
      @original_edges[index] = forward
    end
  end

  def shortest_cost_path
    distances = Array.new(@nodes, Float::INFINITY)
    parents = Array.new(@nodes)
    distances[@source] = 0

    (@nodes - 1).times do
      updated = false

      @graph.each_with_index do |edges, node|
        next if distances.fetch(node).infinite?

        edges.each_with_index do |edge, edge_index|
          next if edge.capacity <= 0

          candidate_distance = distances.fetch(node) + edge.cost
          next unless candidate_distance < distances.fetch(edge.to)

          distances[edge.to] = candidate_distance
          parents[edge.to] = [node, edge_index]
          updated = true
        end
      end

      break unless updated
    end

    return nil if distances.fetch(@sink).infinite?

    reconstruct_path(parents)
  end

  def reconstruct_path(parents)
    path = []
    node = @sink

    until node == @source
      parent_node, edge_index = parents.fetch(node)
      path.unshift([parent_node, edge_index])
      node = parent_node
    end

    path
  end

  def augment_flow(path, amount)
    path.each do |node, edge_index|
      edge = @graph.fetch(node).fetch(edge_index)
      reverse = @graph.fetch(edge.to).fetch(edge.reverse_index)

      edge.capacity -= amount
      reverse.capacity += amount
      if edge.original_index
        edge.flow += amount
      else
        reverse.flow -= amount
      end
    end
  end

  def calculate_total_cost
    @original_edges.sum { |edge| edge.flow * edge.cost }
  end

  def original_flow_edges
    @original_edges.map do |edge|
      [edge.from, edge.to, edge.flow]
    end
  end
end
