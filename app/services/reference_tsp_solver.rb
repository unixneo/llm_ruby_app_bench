class ReferenceTspSolver
  Result = Data.define(:tour, :length, :source) do
    def to_h
      {
        tour: tour,
        length: length,
        source: source
      }
    end
  end

  def solve(problem_or_fixture, fixture = nil)
    fixture ||= problem_or_fixture

    Result.new(
      tour: fixture.fetch(:optimal_tour),
      length: fixture.fetch(:optimal_length).to_f,
      source: "manual_fixture"
    )
  end
end
