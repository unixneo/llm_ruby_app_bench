class MaxFlowSolver
  SOURCE = "edmonds-karp"

  Edge = Struct.new(:from, :to, :capacity, :reverse_index, :original_index, :flow, keyword_init: true)

  Result = Data.define(:max_flow, :flow_edges, :source) do
    def to_h
      {
        max_flow: max_flow,
        flow_edges: flow_edges,
        source: source
      }
    end
  end

  def initialize(nodes, edges, source, sink)
    @nodes = nodes
    @edges = edges
    @source = source
    @sink = sink
    validate_input!
  end

  def solve
    build_residual_graph
    max_flow = 0

    while (path = bfs_augmenting_path)
      bottleneck = path.map { |node, edge_index| @graph.fetch(node).fetch(edge_index).capacity }.min
      path.each do |node, edge_index|
        edge = @graph.fetch(node).fetch(edge_index)
        reverse = @graph.fetch(edge.to).fetch(edge.reverse_index)

        edge.capacity -= bottleneck
        reverse.capacity += bottleneck
        if edge.original_index
          edge.flow += bottleneck
        else
          reverse.flow -= bottleneck
        end
      end
      max_flow += bottleneck
    end

    Result.new(
      max_flow: max_flow,
      flow_edges: original_flow_edges,
      source: SOURCE
    )
  end

  private

  def validate_input!
    unless @nodes.is_a?(Integer) && @nodes.positive?
      raise ArgumentError, "nodes must be a positive integer"
    end

    unless [@source, @sink].all? { |node| node.is_a?(Integer) && node.between?(0, @nodes - 1) } && @source != @sink
      raise ArgumentError, "source and sink must be distinct node indexes"
    end

    unless @edges.is_a?(Array) &&
        @edges.all? { |edge| edge.is_a?(Array) && edge.length == 3 && edge.all? { |value| value.is_a?(Integer) } && edge.fetch(2) >= 0 && edge.fetch(0).between?(0, @nodes - 1) && edge.fetch(1).between?(0, @nodes - 1) }
      raise ArgumentError, "edges must be [from, to, capacity] triples with valid nodes and nonnegative capacities"
    end
  end

  def build_residual_graph
    @graph = Array.new(@nodes) { [] }
    @original_edges = []

    @edges.each_with_index do |(from, to, capacity), index|
      if from == to
        @original_edges[index] = Edge.new(from: from, to: to, capacity: capacity, reverse_index: nil, original_index: index, flow: 0)
        next
      end

      forward = Edge.new(
        from: from,
        to: to,
        capacity: capacity,
        reverse_index: @graph.fetch(to).length,
        original_index: index,
        flow: 0
      )
      backward = Edge.new(
        from: to,
        to: from,
        capacity: 0,
        reverse_index: @graph.fetch(from).length,
        original_index: nil,
        flow: 0
      )

      @graph.fetch(from) << forward
      @graph.fetch(to) << backward
      @original_edges[index] = forward
    end
  end

  def bfs_augmenting_path
    parents = Array.new(@nodes)
    visited = Array.new(@nodes, false)
    queue = [@source]
    visited[@source] = true

    until queue.empty?
      node = queue.shift
      @graph.fetch(node).each_with_index do |edge, edge_index|
        next if visited.fetch(edge.to) || edge.capacity <= 0

        visited[edge.to] = true
        parents[edge.to] = [node, edge_index]
        return reconstruct_path(parents) if edge.to == @sink

        queue << edge.to
      end
    end

    nil
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

  def original_flow_edges
    @original_edges.map do |edge|
      [edge.from, edge.to, edge.flow]
    end
  end
end
