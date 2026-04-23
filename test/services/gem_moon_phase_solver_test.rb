require "test_helper"

class GemMoonPhaseSolverTest < ActiveSupport::TestCase
  test "solves daily fixture with astronoby reference" do
    problem = MoonPhaseProblem.new(
      name: "moon_phase_first_quarter_2024_05",
      fixture_type: "daily",
      observation_date: Date.new(2024, 5, 15),
      expected_illuminated_fraction: 0.502129,
      expected_phase_fraction: 0.24366,
      expected_phase_name: "first_quarter"
    )

    result = GemMoonPhaseSolver.new(problem).solve

    assert_in_delta 0.502129, result.illuminated_fraction, 0.001
    assert_in_delta 0.24366, result.phase_fraction, 0.001
    assert result.ephemeris_required
  end

  test "solves monthly event fixture without ephemeris requirement" do
    problem = MoonPhaseProblem.new(
      name: "moon_phase_events_2025_03",
      fixture_type: "events",
      year: 2025,
      month: 3,
      expected_events: [{ phase: "new_moon", time: "2025-03-29T10:57:45Z" }]
    )

    result = GemMoonPhaseSolver.new(problem).solve

    assert_equal 4, result.major_events.length
    refute result.ephemeris_required
  end
end
