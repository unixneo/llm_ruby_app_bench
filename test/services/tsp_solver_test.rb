require "test_helper"

# Set SKIP_HELD_KARP=1 or SKIP_HELD_KARP=true to skip expensive exact solver tests.
# By default, all Held-Karp tests run.
class TspSolverTest < ActiveSupport::TestCase
  test "returns numeric tour length" do
    result = TspSolver.new.solve(TspFixtures.problem_for(TspFixtures.square_4))

    assert_kind_of Numeric, result.length
  end

  test "returns metadata fields matching reference result structure" do
    result = TspSolver.new.solve(TspFixtures.problem_for(TspFixtures.square_4))

    assert_equal [:tour, :length, :source, :objective_value, :scale], result.to_h.keys
    assert_equal "brute-force", result.source
    assert_equal result.length, result.objective_value
    assert_equal 1, result.scale
  end

  test "held karp returns metadata fields matching reference result structure" do
    skip_held_karp_if_requested

    result = TspSolver.new(algorithm: :held_karp).solve(TspFixtures.problem_for(TspFixtures.square_4))

    assert_equal [:tour, :length, :source, :objective_value, :scale], result.to_h.keys
    assert_equal "held-karp", result.source
    assert_equal result.length, result.objective_value
    assert_equal 1, result.scale
  end

  test "returns valid complete tour visiting each city once" do
    fixture = TspFixtures.hexagon_6
    result = TspSolver.new.solve(TspFixtures.problem_for(fixture))
    visit_order = result.tour[0...-1]

    assert_equal result.tour.first, result.tour.last
    assert_equal fixture.fetch(:cities).length, visit_order.length
    assert_equal (0...fixture.fetch(:cities).length).to_a, visit_order.sort
  end

  test "candidate result matches manual reference fixtures" do
    candidate_solver = TspSolver.new
    reference_solver = ReferenceTspSolver.new

    [TspFixtures.square_4, TspFixtures.hexagon_6, TspFixtures.octagon_8].each do |fixture|
      candidate = candidate_solver.solve(TspFixtures.problem_for(fixture))
      reference = reference_solver.solve(fixture)

      assert_in_delta reference.length, candidate.length, 1e-9, "#{fixture.fetch(:name)} length mismatch"
    end
  end

  test "auto uses held karp for random ten city fixture" do
    skip_held_karp_if_requested

    result = TspSolver.new.solve(TspFixtures.problem_for(TspFixtures.random_10))

    assert_equal "held-karp", result.source
    assert_equal 11, result.tour.length
    assert_equal result.tour.first, result.tour.last
    assert_kind_of Numeric, result.length
    assert result.length.positive?
  end

  test "auto uses held karp for random twenty city fixture" do
    skip_held_karp_if_requested

    result = TspSolver.new.solve(TspFixtures.problem_for(TspFixtures.random_20))

    assert_equal "held-karp", result.source
    assert_equal 21, result.tour.length
    assert_equal result.tour.first, result.tour.last
    assert_kind_of Numeric, result.length
    assert result.length.positive?
  end

  test "keeps nearest neighbor available as explicit algorithm" do
    result = TspSolver.new(algorithm: :nearest_neighbor).solve(TspFixtures.problem_for(TspFixtures.random_20))

    assert_equal "nearest-neighbor", result.source
    assert_equal 21, result.tour.length
  end

  test "solves world city fixture with held karp" do
    skip_held_karp_if_requested

    result = TspSolver.new(algorithm: :held_karp).solve(TspFixtures.problem_for(TspFixtures.world_cities_13))

    assert_equal "held-karp", result.source
    assert_equal 14, result.tour.length
    assert_equal result.tour.first, result.tour.last
    assert_kind_of Numeric, result.length
    assert result.length.positive?
  end

  test "keeps brute force for eight city fixture" do
    result = TspSolver.new.solve(TspFixtures.problem_for(TspFixtures.octagon_8))

    assert_equal "brute-force", result.source
  end

  test "held karp matches brute force on eight city fixture" do
    skip_held_karp_if_requested

    problem = TspFixtures.problem_for(TspFixtures.octagon_8)
    brute_force = TspSolver.new(algorithm: :brute_force).solve(problem)
    held_karp = TspSolver.new(algorithm: :held_karp).solve(problem)

    assert_in_delta brute_force.length, held_karp.length, 1e-9
  end

  test "haversine distance uses kilometers" do
    distance = TspProblem.haversine_distance(35.6762, 139.6503, 34.6937, 135.5023)

    assert_in_delta 397.0, distance, 5.0
  end
end
