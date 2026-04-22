class MinCostFlowFixtures
  class << self
    def all
      [
        simple_4,
        balanced_6,
        high_cost_shortcut_5,
        capacity_limited_7,
        parallel_edges_8
      ]
    end

    def find(name)
      all.find { |fixture| fixture.fetch(:name) == name } || raise(KeyError, "unknown min cost flow fixture: #{name}")
    end

    def seed!
      all.each do |fixture|
        MinCostFlowProblem.find_or_create_by!(name: fixture.fetch(:name)) do |problem|
          problem.nodes = fixture.fetch(:nodes)
          problem.edges = fixture.fetch(:edges)
          problem.source = fixture.fetch(:source)
          problem.sink = fixture.fetch(:sink)
          problem.demand = fixture.fetch(:demand)
          problem.description = fixture.fetch(:description)
        end
      end
    end

    def simple_4
      {
        name: "mincostflow_simple_4",
        nodes: 4,
        edges: [
          [0, 1, 15, 4],
          [0, 2, 8, 4],
          [1, 3, 20, 2],
          [2, 3, 10, 6]
        ],
        source: 0,
        sink: 3,
        demand: 15,
        description: "Simple 4-node network with two paths of different costs"
      }
    end

    def balanced_6
      {
        name: "mincostflow_balanced_6",
        nodes: 6,
        edges: [
          [0, 1, 10, 2],
          [0, 2, 10, 4],
          [1, 3, 8, 5],
          [1, 4, 2, 3],
          [2, 3, 5, 1],
          [2, 4, 8, 2],
          [3, 5, 15, 1],
          [4, 5, 10, 3]
        ],
        source: 0,
        sink: 5,
        demand: 12,
        description: "Medium network requiring cost-aware path selection across multiple intermediate nodes"
      }
    end

    def high_cost_shortcut_5
      {
        name: "mincostflow_high_cost_shortcut_5",
        nodes: 5,
        edges: [
          [0, 1, 20, 1],
          [1, 2, 20, 1],
          [2, 4, 20, 1],
          [0, 3, 15, 10],
          [3, 4, 15, 1]
        ],
        source: 0,
        sink: 4,
        demand: 18,
        description: "Tests preference for longer cheap path over expensive shortcut"
      }
    end

    def capacity_limited_7
      {
        name: "mincostflow_capacity_limited_7",
        nodes: 7,
        edges: [
          [0, 1, 5, 1],
          [0, 2, 10, 3],
          [1, 3, 3, 2],
          [1, 4, 4, 4],
          [2, 4, 8, 1],
          [2, 5, 6, 2],
          [3, 6, 10, 3],
          [4, 6, 12, 2],
          [5, 6, 8, 1]
        ],
        source: 0,
        sink: 6,
        demand: 14,
        description: "Capacity constraints force use of multiple paths despite cost differences"
      }
    end

    def parallel_edges_8
      {
        name: "mincostflow_parallel_edges_8",
        nodes: 8,
        edges: [
          [0, 1, 8, 3],
          [0, 2, 7, 2],
          [1, 3, 6, 4],
          [1, 4, 5, 1],
          [2, 3, 4, 2],
          [2, 5, 9, 3],
          [3, 6, 10, 2],
          [4, 6, 8, 5],
          [4, 7, 6, 1],
          [5, 7, 7, 4],
          [6, 7, 15, 1]
        ],
        source: 0,
        sink: 7,
        demand: 15,
        description: "Complex network with multiple parallel routing options requiring optimal cost balancing"
      }
    end
  end
end
