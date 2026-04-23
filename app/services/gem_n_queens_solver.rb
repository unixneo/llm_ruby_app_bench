require "n_queens"

class GemNQueensSolver
  REFERENCE_VERSION = "n_queens-v1.0.0"

  Result = Data.define(:n, :count, :solutions, :method, :duration, :source, :reference_version) do
    def to_h
      {
        n: n,
        count: count,
        solutions: solutions,
        method: method,
        duration: duration,
        source: source,
        reference_version: reference_version
      }
    end
  end

  def initialize(n)
    @n = n
  end

  def solve
    result = NQueens::Solver.new(@n).solve

    Result.new(
      n: @n,
      count: result.count,
      solutions: @n <= 10 ? result.solutions : nil,
      method: result.method,
      duration: result.duration,
      source: "n_queens",
      reference_version: REFERENCE_VERSION
    )
  end
end

