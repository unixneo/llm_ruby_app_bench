require "time"

class MoonPhaseResultComparison
  def self.compare(problem, candidate_result, reference_result)
    new(problem).compare(candidate_result, reference_result)
  end

  def initialize(problem)
    @problem = problem
  end

  def compare(candidate_result, reference_result)
    candidate_validation = MoonPhaseSolutionValidator.validate(@problem, candidate_result)
    reference_validation = MoonPhaseSolutionValidator.validate(@problem, reference_result)

    comparison_metrics =
      if @problem.daily_fixture?
        compare_daily(candidate_result, reference_result)
      else
        compare_events(candidate_result, reference_result)
      end

    {
      status: status(candidate_validation, reference_validation, comparison_metrics.fetch(:within_tolerance)),
      difference: comparison_metrics.fetch(:difference),
      candidate_errors: candidate_validation.fetch(:errors),
      reference_errors: reference_validation.fetch(:errors)
    }.merge(comparison_metrics.except(:within_tolerance))
  end

  private

  def compare_daily(candidate_result, reference_result)
    illuminated_difference = (candidate_result.illuminated_fraction - reference_result.illuminated_fraction).abs
    phase_difference = (candidate_result.phase_fraction - reference_result.phase_fraction).abs
    within_tolerance =
      illuminated_difference <= MoonPhaseSolutionValidator::FRACTION_TOLERANCE &&
      phase_difference <= MoonPhaseSolutionValidator::FRACTION_TOLERANCE

    {
      difference: [illuminated_difference, phase_difference].max,
      illuminated_difference: illuminated_difference,
      phase_difference: phase_difference,
      within_tolerance: within_tolerance
    }
  end

  def compare_events(candidate_result, reference_result)
    candidate_events = normalized_events(candidate_result.major_events)
    reference_events = normalized_events(reference_result.major_events)

    offsets = candidate_events.zip(reference_events).filter_map do |candidate, reference|
      next nil if candidate.nil? || reference.nil?

      ((candidate.fetch(:time) - reference.fetch(:time)).abs / 60.0)
    end

    max_offset = offsets.max.to_f

    {
      difference: max_offset,
      max_event_offset_minutes: max_offset,
      within_tolerance: max_offset <= MoonPhaseSolutionValidator::EVENT_TIME_TOLERANCE_MINUTES
    }
  end

  def normalized_events(events)
    events.map do |event|
      {
        phase: event.fetch(:phase, event["phase"]).to_s,
        time: event.fetch(:time, event["time"]).is_a?(Time) ? event.fetch(:time, event["time"]).utc : Time.iso8601(event.fetch(:time, event["time"]).to_s).utc
      }
    end
  end

  def status(candidate_validation, reference_validation, within_tolerance)
    return "infeasible" unless candidate_validation.fetch(:valid)
    return "reference_failed" unless reference_validation.fetch(:valid)

    within_tolerance ? "feasible" : "length_mismatch"
  end
end
