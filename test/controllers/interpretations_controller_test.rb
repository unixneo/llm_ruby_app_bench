require "test_helper"

class InterpretationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @attempt = TspAttemptRunner.new.run_all.first
  end

  test "creates PI interpretation" do
    assert_difference("Interpretation.count", 1) do
      post attempt_interpretations_url(@attempt), params: {
        interpretation: {
          classification: "correct_match",
          notes: "Candidate and manual reference lengths match."
        }
      }
    end

    assert_redirected_to attempt_url(@attempt)
  end
end
