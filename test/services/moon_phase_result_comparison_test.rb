require "test_helper"

class MoonPhaseResultComparisonTest < ActiveSupport::TestCase
  test "marks daily results feasible when within tolerance" do
    fixture_hash = MoonPhaseFixtures.first_quarter_2024_05
    problem = MoonPhaseProblem.new(
      name: fixture_hash.fetch(:name),
      fixture_type: fixture_hash.fetch(:fixture_type),
      observation_date: fixture_hash.fetch(:observation_date),
      expected_illuminated_fraction: fixture_hash.fetch(:expected_illuminated_fraction),
      expected_phase_fraction: fixture_hash.fetch(:expected_phase_fraction),
      expected_phase_name: fixture_hash.fetch(:expected_phase_name)
    )
    candidate = MoonPhaseCalculator.new(problem.observation_date).solve
    reference = GemMoonPhaseSolver.new(problem).solve

    comparison = MoonPhaseResultComparison.compare(problem, candidate, reference)

    assert_equal "feasible", comparison.fetch(:status)
    assert comparison.fetch(:difference) < 0.02
  end

  test "marks event results feasible when within time tolerance" do
    fixture_hash = MoonPhaseFixtures.events_2025_03
    problem = MoonPhaseProblem.new(
      name: fixture_hash.fetch(:name),
      fixture_type: fixture_hash.fetch(:fixture_type),
      year: fixture_hash.fetch(:year),
      month: fixture_hash.fetch(:month),
      expected_events: fixture_hash.fetch(:expected_events)
    )
    candidate = MoonPhaseResult.new(
      fixture_type: "events",
      illuminated_fraction: nil,
      phase_fraction: nil,
      phase_name: nil,
      major_events: MoonPhaseEventFinder.new(problem.year, problem.month).major_events,
      source: "meeus",
      reference_version: nil,
      ephemeris_required: false
    )
    reference = GemMoonPhaseSolver.new(problem).solve

    comparison = MoonPhaseResultComparison.compare(problem, candidate, reference)

    assert_equal "feasible", comparison.fetch(:status)
    assert comparison.fetch(:max_event_offset_minutes) < 60
  end
end
