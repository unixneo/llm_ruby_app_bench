require "or-tools"

class GemMaxFlowSolver
  REFERENCE_VERSION = "or-tools-simple-max-flow-v1"

  Result = Data.define(:max_flow, :flow_edges, :source, :reference_version) do
    def to_h
      {
        max_flow: max_flow,
        flow_edges: flow_edges,
        source: source,
        reference_version: reference_version
      }
    end
  end

  def initialize(nodes, edges, source, sink)
    @nodes = nodes
    @edges = edges
    @source = source
    @sink = sink
  end

  def solve
    solver = ORTools::SimpleMaxFlow.new
    @edges.each do |from, to, capacity|
      solver.add_arc_with_capacity(from, to, capacity)
    end

    status = solver.solve(@source, @sink)
    raise "OR-Tools SimpleMaxFlow failed with status #{status}" unless status == :optimal

    Result.new(
      max_flow: solver.optimal_flow,
      flow_edges: @edges.each_index.map { |arc_index| [solver.tail(arc_index), solver.head(arc_index), solver.flow(arc_index)] },
      source: "or-tools",
      reference_version: REFERENCE_VERSION
    )
  end
end
