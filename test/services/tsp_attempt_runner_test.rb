require "test_helper"

class TspAttemptRunnerTest < ActiveSupport::TestCase
  FakeReferenceResult = Data.define(:tour, :length, :source, :reference_version) do
    def to_h
      {
        tour: tour,
        length: length,
        source: source,
        objective_value: length,
        scale: 1,
        reference_version: reference_version
      }
    end
  end

  FakeReferenceSolver = Class.new do
    def solve(problem, fixture = nil)
      tour = reference_tour(problem, fixture)

      FakeReferenceResult.new(
        tour: tour,
        length: reference_length(problem, fixture, tour),
        source: "or-tools",
        reference_version: "or-tools-guided-local-search-v1"
      )
    end

    private

    def reference_tour(problem, fixture)
      return [0, 7, 6, 5, 4, 3, 2, 1, 0] if fixture&.fetch(:name) == "octagon_8"

      (0...problem.city_count).to_a + [0]
    end

    def reference_length(problem, fixture, tour)
      fixture&.fetch(:optimal_length, nil) || tour.each_cons(2).sum { |from_index, to_index| problem.distance(from_index, to_index) }
    end
  end

  test "stores candidate and reference results for every P0001 fixture" do
    attempts = runner.run_all

    assert_equal 12, attempts.length

    attempts.each do |attempt|
      assert_equal "P0001", attempt.prompt_id
      assert_includes ["brute-force-v1", "nearest-neighbor-v1", "held-karp-v1"], attempt.algorithm_version
      assert attempt.candidate_result_data.key?("length")
      assert attempt.reference_result_data.fetch("length")
      assert_equal "or-tools-guided-local-search-v1", attempt.reference_version
      assert_equal attempt.reference_version, attempt.reference_result_data.fetch("reference_version")
      assert_equal "or-tools", attempt.reference_result_data.fetch("source")
      assert_includes ["brute-force", "nearest-neighbor", "held-karp"], attempt.candidate_result_data.fetch("source")
      assert_includes ["exact_match", "different_optimal", "length_mismatch", "candidate_failed"], attempt.status
    end
  end

  test "stores different optimal when length matches but route sequence differs" do
    attempt = runner.run_all.find { |record| record.fixture_name == "octagon_8" }

    assert_equal "different_optimal", attempt.status
    assert_equal "brute-force-v1", attempt.algorithm_version
    refute_equal attempt.candidate_tour, attempt.reference_tour
  end

  test "stores held karp candidate results for all fixtures" do
    attempts = runner.run_all

    TspFixtures.all.each do |fixture|
      attempt = attempts.find do |record|
        record.fixture_name == fixture.fetch(:name) && record.algorithm_version == "held-karp-v1"
      end

      assert_equal "held-karp", attempt.candidate_result_data.fetch("source")
      assert attempt.candidate_result_data.fetch("tour")
      assert attempt.candidate_result_data.fetch("length")
      assert attempt.reference_result_data.fetch("tour")
      assert attempt.reference_result_data.fetch("length")
    end
  end

  test "stores three world city algorithm attempts" do
    attempts = runner.run_all.select { |attempt| attempt.fixture_name == "world_cities_13" }

    assert_equal ["brute-force-v1", "held-karp-v1", "nearest-neighbor-v1"], attempts.map(&:algorithm_version).sort

    brute_force = attempts.find { |attempt| attempt.algorithm_version == "brute-force-v1" }
    nearest_neighbor = attempts.find { |attempt| attempt.algorithm_version == "nearest-neighbor-v1" }
    held_karp = attempts.find { |attempt| attempt.algorithm_version == "held-karp-v1" }

    assert_equal "candidate_failed", brute_force.status
    assert_equal "brute-force solver supports n<=8", brute_force.candidate_result_data.fetch("error").fetch("message")
    assert_equal "nearest-neighbor", nearest_neighbor.candidate_result_data.fetch("source")
    assert_equal "held-karp", held_karp.candidate_result_data.fetch("source")
    assert nearest_neighbor.candidate_result_data.fetch("length").positive?
    assert held_karp.candidate_result_data.fetch("length").positive?
  end

  test "world city fixture keeps city names for display" do
    attempt = runner.run_all.find do |record|
      record.fixture_name == "world_cities_13" && record.algorithm_version == "held-karp-v1"
    end

    assert_includes attempt.candidate_tour_display, "Tokyo"
    assert_includes attempt.candidate_tour_display, " -> "
  end

  test "preserves explicit nearest neighbor version when held karp records are added" do
    nearest_neighbor_attempts = TspAttemptRunner.new(
      candidate_solvers: [TspSolver.new(algorithm: :nearest_neighbor)],
      reference_solver: FakeReferenceSolver.new
    ).run_all

    assert nearest_neighbor_attempts.any? { |attempt| attempt.algorithm_version == "nearest-neighbor-v1" }

    runner.run_all

    assert_equal 7, Attempt.where(algorithm_version: "nearest-neighbor-v1").count
    assert_equal 7, Attempt.where(algorithm_version: "held-karp-v1").count
  end

  test "rerunning preserves existing versioned attempts" do
    first_run = runner.run_all
    ids = first_run.map(&:id).sort
    updated_at_values = first_run.to_h { |attempt| [attempt.id, attempt.updated_at] }

    second_run = runner.run_all

    assert_equal ids, second_run.map(&:id).sort
    assert_equal 12, Attempt.count
    second_run.each do |attempt|
      assert_equal updated_at_values.fetch(attempt.id), attempt.updated_at
    end
  end

  test "creates new attempts when reference version changes" do
    legacy_solver = Class.new do
      Result = Data.define(:tour, :length, :source, :reference_version) do
        def to_h
          {
            tour: tour,
            length: length,
            source: source,
            objective_value: length,
            scale: 1,
            reference_version: reference_version
          }
        end
      end

      def solve(problem, _fixture = nil)
        Result.new(
          tour: (0...problem.city_count).to_a + [0],
          length: 1.0,
          source: "or-tools",
          reference_version: "or-tools-path-cheapest-arc-v1"
        )
      end
    end

    TspAttemptRunner.new(reference_solver: legacy_solver.new).run_all
    runner.run_all

    assert_equal 24, Attempt.count
    assert_equal 12, Attempt.where(reference_version: "or-tools-path-cheapest-arc-v1").count
    assert_equal 12, Attempt.where(reference_version: "or-tools-guided-local-search-v1").count
  end

  private

  def runner(**options)
    TspAttemptRunner.new(**{ reference_solver: FakeReferenceSolver.new }.merge(options))
  end
end
