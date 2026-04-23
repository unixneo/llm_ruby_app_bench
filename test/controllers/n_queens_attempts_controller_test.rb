require "test_helper"

class NQueensAttemptsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @challenge = Challenge.create!(name: "N-Queens Problem")
    @attempt = Attempt.create!(
      prompt_id: "P0027",
      challenge: @challenge,
      fixture_name: "nqueens_8",
      algorithm_version: "backtracking-v1",
      reference_version: GemNQueensSolver::REFERENCE_VERSION,
      candidate_result: JSON.pretty_generate(n_queens_result("backtracking")),
      reference_result: JSON.pretty_generate(n_queens_result("n_queens")),
      status: "exact_match",
      difference: 0.0
    )
  end

  test "shows n-queens attempts index under scoped path" do
    get n_queens_attempts_url

    assert_response :success
    assert_includes response.body, "N-Queens Attempts"
    assert_includes response.body, "nqueens_8"
    assert_includes response.body, "Count Difference"
    assert_includes response.body, "Combinatorics"
    assert_includes response.body, "NP-complete decision variant"
  end

  test "shows n-queens attempt details under scoped path" do
    get n_queens_attempt_url(@attempt)

    assert_response :success
    assert_includes response.body, "Candidate Result"
    assert_includes response.body, "Reference Result"
    assert_includes response.body, "n_queens"
    assert_includes response.body, "/n_queens/attempts/#{@attempt.id}/interpretations"
  end

  private

  def n_queens_result(source)
    {
      n: 8,
      count: 92,
      solutions: source == "backtracking" ? [[0, 4, 7, 5, 2, 6, 1, 3]] : [[0, 4, 7, 5, 2, 6, 1, 3]],
      method: "backtracking",
      duration: 0.123,
      source: source,
      known_count: 92,
      validation_errors: [],
      reference_version: GemNQueensSolver::REFERENCE_VERSION
    }
  end
end

