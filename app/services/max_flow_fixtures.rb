class MaxFlowFixtures
  class << self
    def all
      [
        simple_4,
        bottleneck_6,
        parallel_8,
        complex_12,
        dense_15
      ]
    end

    def find(name)
      all.find { |fixture| fixture.fetch(:name) == name } || raise(KeyError, "unknown max flow fixture: #{name}")
    end

    def seed!
      all.each do |fixture|
        MaxFlowProblem.find_or_create_by!(name: fixture.fetch(:name)) do |problem|
          problem.nodes = fixture.fetch(:nodes)
          problem.edges = fixture.fetch(:edges)
          problem.source = fixture.fetch(:source)
          problem.sink = fixture.fetch(:sink)
          problem.description = fixture.fetch(:description)
        end
      end
    end

    def simple_4
      {
        name: "maxflow_simple_4",
        nodes: 4,
        edges: [
          [0, 1, 10],
          [0, 2, 5],
          [1, 3, 15],
          [2, 3, 10]
        ],
        source: 0,
        sink: 3,
        description: "Simple 4-node network, manual verification possible"
      }
    end

    def bottleneck_6
      {
        name: "maxflow_bottleneck_6",
        nodes: 6,
        edges: [
          [0, 1, 16],
          [0, 2, 13],
          [1, 3, 12],
          [2, 1, 4],
          [2, 4, 14],
          [3, 2, 9],
          [3, 5, 20],
          [4, 3, 7],
          [4, 5, 4]
        ],
        source: 0,
        sink: 5,
        description: "Classic 6-node network with bottleneck at sink"
      }
    end

    def parallel_8
      {
        name: "maxflow_parallel_8",
        nodes: 8,
        edges: [
          [0, 1, 10], [0, 2, 10], [0, 3, 10],
          [1, 4, 8], [1, 5, 5],
          [2, 4, 5], [2, 5, 8],
          [3, 6, 10],
          [4, 7, 10],
          [5, 7, 10],
          [6, 7, 10]
        ],
        source: 0,
        sink: 7,
        description: "Multiple parallel paths with varying capacities"
      }
    end

    def complex_12
      {
        name: "maxflow_complex_12",
        nodes: 12,
        edges: [
          [0, 1, 15], [0, 2, 10], [0, 3, 8],
          [1, 4, 12], [1, 5, 7],
          [2, 5, 9], [2, 6, 8],
          [3, 6, 11], [3, 7, 6],
          [4, 8, 10], [4, 9, 8],
          [5, 8, 7], [5, 9, 9], [5, 10, 5],
          [6, 9, 6], [6, 10, 8],
          [7, 10, 12],
          [8, 11, 15],
          [9, 11, 18],
          [10, 11, 14]
        ],
        source: 0,
        sink: 11,
        description: "Complex 12-node network with many intermediate paths"
      }
    end

    def dense_15
      {
        name: "maxflow_dense_15",
        nodes: 15,
        edges: [
          [0, 1, 20], [0, 2, 18], [0, 3, 16],
          [1, 4, 12], [1, 5, 10], [1, 6, 8],
          [2, 4, 10], [2, 5, 12], [2, 7, 9],
          [3, 6, 11], [3, 7, 13], [3, 8, 7],
          [4, 9, 15], [4, 10, 10],
          [5, 9, 8], [5, 10, 12], [5, 11, 9],
          [6, 10, 7], [6, 11, 11], [6, 12, 8],
          [7, 11, 10], [7, 12, 13],
          [8, 12, 15], [8, 13, 9],
          [9, 14, 20],
          [10, 14, 18],
          [11, 14, 16],
          [12, 14, 19],
          [13, 14, 12]
        ],
        source: 0,
        sink: 14,
        description: "Dense 15-node network with multiple layers"
      }
    end
  end
end
