class JobShopFixtures
  class << self
    def all
      [
        tiny_3x3,
        small_4x4,
        asymmetric_5x4,
        precedence_test_6x3,
        medium_8x5
      ]
    end

    def find(name)
      all.find { |fixture| fixture.fetch(:name) == name } || raise(KeyError, "unknown job shop fixture: #{name}")
    end

    def seed!
      all.each do |fixture|
        JobShopProblem.find_or_create_by!(name: fixture.fetch(:name)) do |problem|
          problem.jobs = fixture.fetch(:jobs)
          problem.description = fixture.fetch(:description)
        end
      end
    end

    def tiny_3x3
      {
        name: "jobshop_tiny_3x3",
        jobs: [
          [[0, 3], [1, 2], [2, 2]],
          [[0, 2], [2, 1], [1, 4]],
          [[1, 4], [2, 3]]
        ],
        description: "Tiny 3 jobs on 3 machines, manual verification possible"
      }
    end

    def small_4x4
      {
        name: "jobshop_small_4x4",
        jobs: [
          [[0, 4], [1, 3], [2, 1], [3, 2]],
          [[1, 2], [0, 3], [3, 4], [2, 1]],
          [[2, 3], [3, 2], [0, 2], [1, 3]],
          [[3, 1], [2, 4], [1, 2], [0, 3]]
        ],
        description: "Small 4 jobs on 4 machines with varied task orderings"
      }
    end

    def asymmetric_5x4
      {
        name: "jobshop_asymmetric_5x4",
        jobs: [
          [[0, 5], [2, 3], [3, 2]],
          [[1, 4], [0, 2], [3, 3], [2, 1]],
          [[2, 2], [1, 3], [0, 4]],
          [[3, 3], [2, 2], [1, 1], [0, 2]],
          [[0, 1], [1, 5], [3, 2], [2, 3]]
        ],
        description: "5 jobs with different number of tasks on 4 machines"
      }
    end

    def precedence_test_6x3
      {
        name: "jobshop_precedence_test_6x3",
        jobs: [
          [[0, 3], [1, 2], [2, 4]],
          [[1, 2], [0, 3], [2, 1]],
          [[2, 3], [0, 2], [1, 3]],
          [[0, 4], [2, 2], [1, 1]],
          [[1, 3], [2, 2], [0, 2]],
          [[2, 1], [1, 4], [0, 3]]
        ],
        description: "6 jobs on 3 machines designed to test strict precedence constraint enforcement"
      }
    end

    def medium_8x5
      {
        name: "jobshop_medium_8x5",
        jobs: [
          [[0, 2], [1, 3], [2, 2], [3, 1], [4, 2]],
          [[1, 1], [0, 4], [3, 2], [2, 3], [4, 1]],
          [[2, 3], [4, 2], [0, 1], [1, 2], [3, 3]],
          [[3, 2], [2, 1], [4, 3], [0, 2], [1, 1]],
          [[4, 1], [1, 2], [0, 3], [2, 1], [3, 2]],
          [[0, 3], [3, 2], [1, 1], [4, 2], [2, 3]],
          [[1, 2], [2, 2], [3, 3], [4, 1], [0, 2]],
          [[2, 1], [0, 2], [4, 3], [1, 2], [3, 1]]
        ],
        description: "Medium complexity: 8 jobs on 5 machines with full task sequences"
      }
    end
  end
end
