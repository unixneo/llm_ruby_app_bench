class AssignmentFixtures
  class << self
    def all
      [
        tiny_3x3,
        small_5x5,
        asymmetric_8x8,
        sparse_10x10,
        dense_15x15
      ]
    end

    def find(name)
      all.find { |fixture| fixture.fetch(:name) == name } || raise(KeyError, "unknown assignment fixture: #{name}")
    end

    def seed!
      all.each do |fixture|
        AssignmentProblem.find_or_create_by!(name: fixture.fetch(:name)) do |problem|
          problem.workers = fixture.fetch(:workers)
          problem.tasks = fixture.fetch(:tasks)
          problem.cost_matrix = fixture.fetch(:cost_matrix)
          problem.description = fixture.fetch(:description)
        end
      end
    end

    def tiny_3x3
      {
        name: "assignment_tiny_3x3",
        workers: 3,
        tasks: 3,
        cost_matrix: [
          [9, 2, 7],
          [6, 4, 3],
          [5, 8, 1]
        ],
        description: "Tiny 3x3 for manual verification"
      }
    end

    def small_5x5
      {
        name: "assignment_small_5x5",
        workers: 5,
        tasks: 5,
        cost_matrix: [
          [12, 18, 20, 17, 15],
          [19, 23, 21, 18, 19],
          [20, 15, 19, 22, 24],
          [14, 21, 25, 19, 16],
          [18, 17, 22, 20, 23]
        ],
        description: "Small symmetric-ish problem"
      }
    end

    def asymmetric_8x8
      {
        name: "assignment_asymmetric_8x8",
        workers: 8,
        tasks: 8,
        cost_matrix: [
          [82, 83, 69, 92, 52, 73, 48, 27],
          [77, 37, 49, 92, 11, 69, 87, 30],
          [11, 69, 5, 86, 21, 78, 58, 24],
          [13, 36, 16, 5, 28, 36, 24, 57],
          [42, 93, 37, 65, 17, 60, 87, 95],
          [81, 45, 91, 27, 24, 41, 15, 33],
          [89, 16, 23, 34, 45, 56, 67, 78],
          [12, 34, 56, 78, 90, 23, 45, 67]
        ],
        description: "Asymmetric costs with wide range"
      }
    end

    def sparse_10x10
      {
        name: "assignment_sparse_10x10",
        workers: 10,
        tasks: 10,
        cost_matrix: [
          [250, 400, 350, 400, 600, 240, 300, 280, 450, 500],
          [400, 600, 350, 150, 200, 450, 500, 380, 420, 480],
          [200, 100, 250, 320, 280, 170, 190, 220, 260, 300],
          [300, 200, 100, 220, 240, 280, 310, 290, 340, 360],
          [500, 450, 400, 180, 150, 380, 420, 440, 390, 410],
          [350, 280, 300, 250, 200, 120, 140, 160, 180, 200],
          [400, 380, 360, 340, 320, 300, 90, 110, 130, 150],
          [450, 430, 410, 390, 370, 350, 330, 80, 120, 140],
          [500, 480, 460, 440, 420, 400, 380, 360, 70, 100],
          [550, 530, 510, 490, 470, 450, 430, 410, 390, 60]
        ],
        description: "Sparse diagonal-pattern problem with low costs"
      }
    end

    def dense_15x15
      {
        name: "assignment_dense_15x15",
        workers: 15,
        tasks: 15,
        cost_matrix: [
          [23, 45, 67, 34, 56, 78, 12, 34, 56, 78, 90, 23, 45, 67, 89],
          [34, 56, 78, 90, 12, 34, 56, 78, 90, 12, 34, 56, 78, 90, 12],
          [45, 67, 89, 23, 45, 67, 89, 23, 45, 67, 89, 23, 45, 67, 89],
          [56, 78, 12, 34, 56, 78, 12, 34, 56, 78, 12, 34, 56, 78, 12],
          [67, 89, 23, 45, 67, 89, 23, 45, 67, 89, 23, 45, 67, 89, 23],
          [78, 12, 34, 56, 78, 12, 34, 56, 78, 12, 34, 56, 78, 12, 34],
          [89, 23, 45, 67, 89, 23, 45, 67, 89, 23, 45, 67, 89, 23, 45],
          [12, 34, 56, 78, 12, 34, 56, 78, 12, 34, 56, 78, 12, 34, 56],
          [23, 45, 67, 89, 23, 45, 67, 89, 23, 45, 67, 89, 23, 45, 67],
          [34, 56, 78, 12, 34, 56, 78, 12, 34, 56, 78, 12, 34, 56, 78],
          [45, 67, 89, 23, 45, 67, 89, 23, 45, 67, 89, 23, 45, 67, 89],
          [56, 78, 12, 34, 56, 78, 12, 34, 56, 78, 12, 34, 56, 78, 12],
          [67, 89, 23, 45, 67, 89, 23, 45, 67, 89, 23, 45, 67, 89, 23],
          [78, 12, 34, 56, 78, 12, 34, 56, 78, 12, 34, 56, 78, 12, 34],
          [89, 23, 45, 67, 89, 23, 45, 67, 89, 23, 45, 67, 89, 23, 45]
        ],
        description: "Dense 15x15 with all reasonable costs"
      }
    end
  end
end
