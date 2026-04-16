require "test_helper"

class AttemptsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @challenge = Challenge.create!(name: "Traveling Salesman Problem")
    @brute_force_attempt = create_attempt(
      fixture_name: "octagon_8",
      algorithm_version: "brute-force-v1",
      candidate_source: "brute-force",
      candidate_tour: [0, 1, 2, 3, 4, 5, 6, 7, 0],
      reference_tour: [0, 7, 6, 5, 4, 3, 2, 1, 0],
      status: "different_optimal",
      difference: 0.0
    )
    @held_karp_attempt = create_attempt(
      fixture_name: "random_20",
      algorithm_version: "held-karp-v1",
      candidate_source: "held-karp",
      candidate_tour: [0, 2, 1, 0],
      reference_tour: [0, 1, 2, 0],
      status: "different_optimal",
      difference: 0.0
    )
    @world_city_attempt = create_attempt(
      fixture_name: "world_cities_13",
      algorithm_version: "held-karp-v1",
      candidate_source: "held-karp",
      candidate_tour: [0, 9, 0],
      reference_tour: [0, 9, 0],
      status: "exact_match",
      difference: 0.0
    )
  end

  test "shows attempts index" do
    get attempts_url

    assert_response :success
    assert_includes response.body, @brute_force_attempt.fixture_name
    assert_includes response.body, "attempt-card"
    assert_includes response.body, "Different route"
    assert_includes response.body, "Algorithm Versions"
    assert_includes response.body, @brute_force_attempt.algorithm_version
    assert_includes response.body, @brute_force_attempt.reference_version
  end

  test "filters attempts by algorithm version" do
    get attempts_url(algorithm_version: "held-karp-v1")

    assert_response :success
    assert_includes response.body, "random_20"
    refute_includes response.body, "octagon_8"
  end

  test "shows single attempt and interpretation form" do
    get attempt_url(@brute_force_attempt)

    assert_response :success
    assert_includes response.body, "Candidate Result"
    assert_includes response.body, "Gem Reference Result"
    assert_includes response.body, "Different route"
    assert_includes response.body, "brute-force-v1"
    assert_includes response.body, "or-tools-guided-local-search-v1"
    assert_includes response.body, "[0, 1, 2, 3, 4, 5, 6, 7, 0]"
    assert_includes response.body, "[0, 7, 6, 5, 4, 3, 2, 1, 0]"
    assert_includes response.body, "brute-force"
    assert_includes response.body, "objective_value"
    assert_includes response.body, "scale"
  end

  test "shows computed system status separately from pi classification" do
    get attempt_url(@brute_force_attempt)

    assert_response :success
    assert_includes response.body, "System Status"
    assert_includes response.body, %(data-status="different_optimal")
    assert_includes response.body, "different_optimal"
    assert_includes response.body, "badge-warning"
    assert_includes response.body, "PI Classification"
    assert_includes response.body, "Choose PI classification"
  end

  test "shows held karp result with reference result" do
    get attempt_url(@held_karp_attempt)

    assert_response :success
    assert_includes response.body, "held-karp"
    assert_includes response.body, "Candidate Tour"
    assert_includes response.body, "Gem Reference Result"
    assert_includes response.body, "or-tools"
  end

  test "shows city names for world city tours" do
    get attempt_url(@world_city_attempt)

    assert_response :success
    assert_includes response.body, "Tokyo -&gt; Osaka -&gt; Tokyo"
  end

  private

  def create_attempt(fixture_name:, algorithm_version:, candidate_source:, candidate_tour:, reference_tour:, status:, difference:)
    Attempt.create!(
      prompt_id: "P0001",
      challenge: @challenge,
      fixture_name: fixture_name,
      algorithm_version: algorithm_version,
      reference_version: "or-tools-guided-local-search-v1",
      candidate_result: JSON.pretty_generate(result_hash(candidate_tour, candidate_source)),
      reference_result: JSON.pretty_generate(result_hash(reference_tour, "or-tools")),
      status: status,
      difference: difference
    )
  end

  def result_hash(tour, source)
    {
      tour: tour,
      length: 4.0,
      source: source,
      objective_value: 4.0,
      scale: 1,
      reference_version: "or-tools-guided-local-search-v1"
    }
  end
end
