require "or-tools"

class GemMinCostFlowSolver
  REFERENCE_VERSION = "or-tools-simple-min-cost-flow-v1"

  Result = Data.define(:optimal_cost, :flow_edges, :source, :reference_version, :total_flow, :demand_satisfied) do
    def to_h
      {
        optimal_cost: optimal_cost,
        flow_edges: flow_edges,
        source: source,
        reference_version: reference_version,
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
  end

  def solve
    solver = ORTools::SimpleMinCostFlow.new
    @edges.each do |from, to, capacity, unit_cost|
      solver.add_arc_with_capacity_and_unit_cost(from, to, capacity, unit_cost)
    end
    solver.set_node_supply(@source, @demand)
    solver.set_node_supply(@sink, -@demand)

    status = solver.solve
    raise "OR-Tools SimpleMinCostFlow failed with status #{status}" unless status == :optimal

    Result.new(
      optimal_cost: solver.optimal_cost,
      flow_edges: (0...solver.num_arcs).map { |arc_index| [solver.tail(arc_index), solver.head(arc_index), solver.flow(arc_index)] },
      source: "or-tools",
      reference_version: REFERENCE_VERSION,
      total_flow: solver.maximum_flow,
      demand_satisfied: solver.maximum_flow == @demand
    )
  end
end
