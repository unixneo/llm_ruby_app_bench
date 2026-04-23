require "test_helper"

class MoonPhaseAttemptsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @challenge = Challenge.create!(name: "Moon Phase Calculations")
    @daily_attempt = Attempt.create!(
      prompt_id: "P0025",
      challenge: @challenge,
      fixture_name: "moon_phase_first_quarter_2024_05",
      algorithm_version: "meeus-v1",
      reference_version: "astronoby-v0.9.0",
      candidate_result: JSON.pretty_generate(daily_result_hash("meeus")),
      reference_result: JSON.pretty_generate(daily_result_hash("astronoby")),
      status: "feasible",
      difference: 0.0007
    )
    @event_attempt = Attempt.create!(
      prompt_id: "P0025",
      challenge: @challenge,
      fixture_name: "moon_phase_events_2024_05",
      algorithm_version: "meeus-v1",
      reference_version: "astronoby-v0.9.0",
      candidate_result: JSON.pretty_generate(event_result_hash("meeus")),
      reference_result: JSON.pretty_generate(event_result_hash("astronoby")),
      status: "feasible",
      difference: 1.166666666667
    )
    Attempt.create!(
      prompt_id: "P0026",
      challenge: @challenge,
      fixture_name: "moon_phase_first_quarter_2024_05",
      algorithm_version: "meeus-full-corrections-v1",
      reference_version: "astronoby-v0.9.0",
      candidate_result: JSON.pretty_generate(daily_result_hash("meeus-full-corrections")),
      reference_result: JSON.pretty_generate(daily_result_hash("astronoby")),
      status: "feasible",
      difference: 0.00012
    )
  end

  test "shows moon phase attempts index under scoped path" do
    get moon_phase_attempts_url

    assert_response :success
    assert_includes response.body, "Moon Phase Attempts"
    assert_includes response.body, "moon_phase_first_quarter_2024_05"
    assert_includes response.body, "moon_phase_events_2024_05"
    assert_includes response.body, "Astronomy"
    assert_includes response.body, "Max Fraction Difference"
    assert_includes response.body, "Max Event Offset (minutes)"
    assert_includes response.body, "meeus-full-corrections-v1"
  end

  test "shows moon phase attempt detail with scoped interpretation form" do
    get moon_phase_attempt_url(@daily_attempt)

    assert_response :success
    assert_includes response.body, "Astronoby"
    assert_includes response.body, "Max Fraction Difference"
    assert_includes response.body, "/moon_phase/attempts/#{@daily_attempt.id}/interpretations"
  end

  test "shows event offset label for moon phase event fixture" do
    get moon_phase_attempt_url(@event_attempt)

    assert_response :success
    assert_includes response.body, "Max Event Offset (minutes)"
  end

  private

  def daily_result_hash(source)
    {
      fixture_type: "daily",
      illuminated_fraction: 0.502129,
      phase_fraction: 0.24366,
      phase_name: "first_quarter",
      major_events: [],
      source: source,
      reference_version: "astronoby-v0.9.0",
      ephemeris_required: source == "astronoby"
    }
  end

  def event_result_hash(source)
    {
      fixture_type: "events",
      illuminated_fraction: nil,
      phase_fraction: nil,
      phase_name: nil,
      major_events: [
        { phase: "last_quarter", time: "2024-05-01T11:27:15Z" },
        { phase: "new_moon", time: "2024-05-08T03:21:56Z" },
        { phase: "first_quarter", time: "2024-05-15T11:48:02Z" },
        { phase: "full_moon", time: "2024-05-23T13:53:12Z" },
        { phase: "last_quarter", time: "2024-05-30T17:12:42Z" }
      ],
      source: source,
      reference_version: "astronoby-v0.9.0",
      ephemeris_required: false
    }
  end
end
