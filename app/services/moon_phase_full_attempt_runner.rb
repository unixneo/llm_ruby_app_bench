class MoonPhaseFullAttemptRunner
  PROMPT_ID = "P0026"
  CHALLENGE_NAME = "Moon Phase Calculations"
  ALGORITHM_VERSION = "meeus-full-corrections-v1"

  def initialize(candidate_solver_class: MoonPhaseFullCalculator, event_finder_class: MoonPhaseFullEventFinder, reference_solver_class: GemMoonPhaseSolver)
    @candidate_solver_class = candidate_solver_class
    @event_finder_class = event_finder_class
    @reference_solver_class = reference_solver_class
  end

  def run_all
    MoonPhaseFixtures.seed!

    challenge = Challenge.find_or_create_by!(name: CHALLENGE_NAME) do |record|
      record.description = "Moon phase benchmark with native Meeus-style Ruby candidate and astronoby reference."
    end

    MoonPhaseProblem.order(:name).map do |problem|
      run_single(challenge, problem)
    end
  end

  def run_single(challenge, problem)
    candidate = candidate_result_for(problem)
    reference = @reference_solver_class.new(problem).solve
    comparison = MoonPhaseFullResultComparison.compare(problem, candidate, reference)

    Attempt.find_or_create_by!(
      prompt_id: PROMPT_ID,
      challenge: challenge,
      fixture_name: problem.name,
      algorithm_version: ALGORITHM_VERSION,
      reference_version: reference.reference_version
    ) do |attempt|
      attempt.candidate_result = JSON.pretty_generate(candidate.to_h.merge(problem_metadata(problem, comparison.fetch(:candidate_errors))))
      attempt.reference_result = JSON.pretty_generate(reference.to_h.merge(problem_metadata(problem, comparison.fetch(:reference_errors))))
      attempt.status = comparison.fetch(:status)
      attempt.difference = comparison.fetch(:difference)
    end
  end

  private

  def candidate_result_for(problem)
    if problem.daily_fixture?
      @candidate_solver_class.new(problem.observation_date).solve
    else
      MoonPhaseResult.new(
        fixture_type: "events",
        illuminated_fraction: nil,
        phase_fraction: nil,
        phase_name: nil,
        major_events: @event_finder_class.new(problem.year, problem.month).major_events,
        source: "meeus-full-corrections",
        reference_version: nil,
        ephemeris_required: false
      )
    end
  end

  def problem_metadata(problem, validation_errors)
    {
      fixture_type: problem.fixture_type,
      observation_date: problem.observation_date&.iso8601,
      year: problem.year,
      month: problem.month,
      validation_errors: validation_errors
    }
  end
end
