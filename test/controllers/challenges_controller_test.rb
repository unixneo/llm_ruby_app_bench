require "test_helper"

class ChallengesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @challenge = Challenge.create!(name: "Traveling Salesman Problem")
    create_attempt("brute-force-v1")
    create_attempt("held-karp-v1")
  end

  test "root shows algorithm agnostic challenge index" do
    get root_url

    assert_response :success
    assert_includes response.body, "LLM Ruby Algorithm Error Benchmark"
    assert_includes response.body, "Passing tests != research correctness"
    assert_includes response.body, "Traveling Salesman Problem"
    assert_includes response.body, "7 fixtures"
    assert_includes response.body, "2 algorithms"
    assert_includes response.body, "2 attempts"
    assert_includes response.body, "Knapsack Problem"
    assert_includes response.body, "Graph Coloring"
    assert_includes response.body, "Coming Soon"
  end

  test "challenge show redirects tsp challenge to attempts index" do
    get challenge_url(@challenge)

    assert_redirected_to attempts_url
  end

  test "attempts index is scoped under tsp path" do
    assert_equal "/tsp/attempts", attempts_path
  end

  private

  def create_attempt(algorithm_version)
    Attempt.create!(
      prompt_id: "P0001",
      challenge: @challenge,
      fixture_name: "fixture-#{algorithm_version}",
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
