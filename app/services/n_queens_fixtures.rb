class NQueensFixtures
  class << self
    def all
      [
        nqueens_4,
        nqueens_6,
        nqueens_8,
        nqueens_10,
        nqueens_12
      ]
    end

    def find(name)
      all.find { |fixture| fixture.fetch(:name) == name } || raise(KeyError, "unknown n-queens fixture: #{name}")
    end

    def seed!
      all.each do |fixture|
        NQueensProblem.find_or_create_by!(name: fixture.fetch(:name)) do |problem|
          problem.n = fixture.fetch(:n)
          problem.description = fixture.fetch(:description)
        end
      end
    end

    def nqueens_4
      {
        name: "nqueens_4",
        n: 4,
        description: "4x4 board - 2 solutions, manually verifiable"
      }
    end

    def nqueens_6
      {
        name: "nqueens_6",
        n: 6,
        description: "6x6 board - 4 solutions"
      }
    end

    def nqueens_8
      {
        name: "nqueens_8",
        n: 8,
        description: "Classic 8-queens problem - 92 solutions"
      }
    end

    def nqueens_10
      {
        name: "nqueens_10",
        n: 10,
        description: "10x10 board - 724 solutions"
      }
    end

    def nqueens_12
      {
        name: "nqueens_12",
        n: 12,
        description: "12x12 board - 14200 solutions, tests performance"
      }
    end
  end
end

