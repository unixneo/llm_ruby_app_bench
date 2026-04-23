require "test_helper"

class ChallengesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @challenge = Challenge.create!(name: "Traveling Salesman Problem")
    @vrp_challenge = Challenge.create!(name: "Vehicle Routing Problem")
    @assignment_challenge = Challenge.create!(name: "Assignment Problem")
    @job_shop_challenge = Challenge.create!(name: "Job Shop Scheduling Problem")
    @moon_phase_challenge = Challenge.create!(name: "Moon Phase Calculations")
    @n_queens_challenge = Challenge.create!(name: "N-Queens Problem")
    @sat_challenge = Challenge.create!(name: "SAT Solver (Boolean Satisfiability)")
    @min_cost_flow_challenge = Challenge.create!(name: "Minimum Cost Flow Problem")
    @max_flow_challenge = Challenge.create!(name: "Max Flow Problem")
    create_attempt(@challenge, "fixture-brute-force-v1", "brute-force-v1")
    create_attempt(@challenge, "fixture-held-karp-v1", "held-karp-v1")
    create_attempt(@vrp_challenge, "vrp_small_5", "clarke-wright-savings-v1")
    create_attempt(@assignment_challenge, "assignment_tiny_3x3", "hungarian-v1")
    create_attempt(@job_shop_challenge, "jobshop_tiny_3x3", "branch-and-bound-v1")
    create_attempt(@moon_phase_challenge, "moon_phase_first_quarter_2024_05", "meeus-v1")
    create_attempt(@n_queens_challenge, "nqueens_8", "backtracking-v1")
    create_attempt(@sat_challenge, "sat_trivial_sat_2", "dpll-v1")
    create_attempt(@min_cost_flow_challenge, "mincostflow_simple_4", "successive-shortest-path-v1")
    create_attempt(@max_flow_challenge, "maxflow_simple_4", "edmonds-karp-v1")
  end

  test "root shows algorithm agnostic challenge index" do
    get root_url

    assert_response :success
    assert_includes response.body, "Ruby Algorithm Benchmark v0.1.2"
    refute_includes response.body, "LLM Ruby Algorithm Error Benchmark v0.1.2"
    assert_includes response.body, "Passing tests != research correctness"
    assert_includes response.body, "Traveling Salesman Problem"
    refute_includes response.body, "NP-hard optimization problem"
    refute_includes response.body, "decision version is NP-complete"
    refute_includes response.body, "sequencing, routing, dispatch, and tour planning"
    assert_includes response.body, "7 fixtures"
    assert_includes response.body, "2 algorithms"
    assert_includes response.body, "2 attempts"
    assert_includes response.body, "Vehicle Routing Problem"
    refute_includes response.body, "generalizes TSP by adding vehicles, capacity, and assignment-to-route decisions"
    refute_includes response.body, "logistics, delivery, service fleets, warehouse dispatch"
    assert_includes response.body, "5 fixtures"
    assert_includes response.body, "1 algorithm"
    assert_includes response.body, "1 attempt"
    assert_includes response.body, "Assignment Problem"
    assert_includes response.body, "Exact Hungarian candidate results"
    refute_includes response.body, "Polynomial-time linear assignment problem"
    refute_includes response.body, "worker-task matching, resource allocation, scheduling"
    assert_includes response.body, "Job Shop Scheduling Problem"
    assert_includes response.body, "Exact branch-and-bound candidate schedules"
    assert_includes response.body, "Moon Phase Calculations"
    assert_includes response.body, "Meeus-style native Ruby phase calculations"
    assert_includes response.body, "N-Queens Problem"
    assert_includes response.body, "Exact native Ruby backtracking counts"
    assert_includes response.body, "SAT Solver (Boolean Satisfiability)"
    assert_includes response.body, "Exact native Ruby DPLL satisfiability checks"
    assert_includes response.body, "Minimum Cost Flow Problem"
    assert_includes response.body, "Successive-shortest-path candidate results"
    assert_includes response.body, "Max Flow Problem"
    assert_includes response.body, "Exact Edmonds-Karp candidate flows"
    refute_includes response.body, "Polynomial-time network flow problem"
    refute_includes response.body, "throughput, bottlenecks, routing capacity"
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

  test "challenge show redirects job shop challenge to job shop attempts index" do
    get challenge_url(@job_shop_challenge)

    assert_redirected_to job_shop_attempts_url
  end

  test "challenge show redirects moon phase challenge to moon phase attempts index" do
    get challenge_url(@moon_phase_challenge)

    assert_redirected_to moon_phase_attempts_url
  end

  test "challenge show redirects n-queens challenge to n-queens attempts index" do
    get challenge_url(@n_queens_challenge)

    assert_redirected_to n_queens_attempts_url
  end

  test "challenge show redirects sat challenge to sat attempts index" do
    get challenge_url(@sat_challenge)

    assert_redirected_to sat_attempts_url
  end

  test "challenge show redirects max flow challenge to max flow attempts index" do
    get challenge_url(@max_flow_challenge)

    assert_redirected_to max_flow_attempts_url
  end

  test "challenge show redirects min cost flow challenge to min cost flow attempts index" do
    get challenge_url(@min_cost_flow_challenge)

    assert_redirected_to min_cost_flow_attempts_url
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

  test "job shop attempts index is scoped under job shop path" do
    assert_equal "/job_shop/attempts", job_shop_attempts_path
  end

  test "moon phase attempts index is scoped under moon phase path" do
    assert_equal "/moon_phase/attempts", moon_phase_attempts_path
  end

  test "n-queens attempts index is scoped under n-queens path" do
    assert_equal "/n_queens/attempts", n_queens_attempts_path
  end

  test "sat attempts index is scoped under sat path" do
    assert_equal "/sat/attempts", sat_attempts_path
  end

  test "max flow attempts index is scoped under max flow path" do
    assert_equal "/max_flow/attempts", max_flow_attempts_path
  end

  test "min cost flow attempts index is scoped under min cost flow path" do
    assert_equal "/min_cost_flow/attempts", min_cost_flow_attempts_path
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
