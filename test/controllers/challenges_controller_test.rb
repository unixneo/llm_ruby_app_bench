require "test_helper"

class ChallengesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @challenge = Challenge.create!(name: "Traveling Salesman Problem")
    @vrp_challenge = Challenge.create!(name: "Vehicle Routing Problem")
    @assignment_challenge = Challenge.create!(name: "Assignment Problem")
    @max_flow_challenge = Challenge.create!(name: "Max Flow Problem")
    create_attempt(@challenge, "fixture-brute-force-v1", "brute-force-v1")
    create_attempt(@challenge, "fixture-held-karp-v1", "held-karp-v1")
    create_attempt(@vrp_challenge, "vrp_small_5", "clarke-wright-savings-v1")
    create_attempt(@assignment_challenge, "assignment_tiny_3x3", "hungarian-v1")
    create_attempt(@max_flow_challenge, "maxflow_simple_4", "edmonds-karp-v1")
  end

  test "root shows algorithm agnostic challenge index" do
    get root_url

    assert_response :success
    assert_includes response.body, "Ruby Algorithm Benchmark v0.1.0"
    refute_includes response.body, "LLM Ruby Algorithm Error Benchmark v0.1.0"
    assert_includes response.body, "Passing tests != research correctness"
    assert_includes response.body, "Traveling Salesman Problem"
    assert_includes response.body, "7 fixtures"
    assert_includes response.body, "2 algorithms"
    assert_includes response.body, "2 attempts"
    assert_includes response.body, "Vehicle Routing Problem"
    assert_includes response.body, "5 fixtures"
    assert_includes response.body, "1 algorithm"
    assert_includes response.body, "1 attempt"
    assert_includes response.body, "Assignment Problem"
    assert_includes response.body, "Exact Hungarian candidate results"
    assert_includes response.body, "Max Flow Problem"
    assert_includes response.body, "Exact Edmonds-Karp candidate flows"
    refute_includes response.body, "Knapsack Problem"
    refute_includes response.body, "Graph Coloring"
    refute_includes response.body, "Shortest Path Algorithms"
    refute_includes response.body, "Pathfinding and weighted graph comparisons."
    refute_includes response.body, "Pending Verification"
    refute_includes response.body, "Coming Soon"
  end

  test "challenge show redirects tsp challenge to attempts index" do
    get challenge_url(@challenge)

    assert_redirected_to attempts_url
  end

  test "challenge show redirects vrp challenge to vrp attempts index" do
    get challenge_url(@vrp_challenge)

    assert_redirected_to vrp_attempts_url
  end

  test "challenge show redirects assignment challenge to assignment attempts index" do
    get challenge_url(@assignment_challenge)

    assert_redirected_to assignment_attempts_url
  end

  test "challenge show redirects max flow challenge to max flow attempts index" do
    get challenge_url(@max_flow_challenge)

    assert_redirected_to max_flow_attempts_url
  end

  test "attempts index is scoped under tsp path" do
    assert_equal "/tsp/attempts", attempts_path
  end

  test "vrp attempts index is scoped under vrp path" do
    assert_equal "/vrp/attempts", vrp_attempts_path
  end

  test "assignment attempts index is scoped under assignment path" do
    assert_equal "/assignment/attempts", assignment_attempts_path
  end

  test "max flow attempts index is scoped under max flow path" do
    assert_equal "/max_flow/attempts", max_flow_attempts_path
  end

  private

  def create_attempt(challenge, fixture_name, algorithm_version)
    Attempt.create!(
      prompt_id: "P0001",
      challenge: challenge,
      fixture_name: fixture_name,
      algorithm_version: algorithm_version,
      reference_version: "or-tools-guided-local-search-v1",
      candidate_result: JSON.pretty_generate(result_hash),
      reference_result: JSON.pretty_generate(result_hash),
      status: "exact_match",
      difference: 0.0
    )
  end

  def result_hash
    {
      tour: [0, 1, 0],
      length: 2.0,
      source: "held-karp",
      objective_value: 2.0,
      scale: 1,
      reference_version: "or-tools-guided-local-search-v1"
    }
  end
end
