require "time"

class MoonPhaseSolutionValidator
  FRACTION_TOLERANCE = 0.02
  EVENT_TIME_TOLERANCE_MINUTES = 60.0
  REQUIRED_PRIMARY_PHASES = %w[new_moon first_quarter full_moon last_quarter].freeze

  def self.validate(problem, result)
    new(problem).validate(result)
  end

  def initialize(problem)
    @problem = problem
  end

  def validate(result)
    @problem.daily_fixture? ? validate_daily(result) : validate_events(result)
  end

  private

  def validate_daily(result)
    errors = []
    illum = result.illuminated_fraction
    phase = result.phase_fraction

    errors << "Illuminated fraction must be numeric" unless illum.is_a?(Numeric)
    errors << "Phase fraction must be numeric" unless phase.is_a?(Numeric)

    if illum.is_a?(Numeric)
      errors << "Illuminated fraction out of range" unless illum.between?(0.0, 1.0)
    end

    if phase.is_a?(Numeric)
      errors << "Phase fraction out of range" unless phase.between?(0.0, 1.0)
    end

    if result.phase_name != MoonPhaseCalculator.new(@problem.observation_date).phase_name
      errors << "Phase name inconsistent with phase fraction"
    end

    {
      valid: errors.empty?,
      errors: errors
    }
  end

  def validate_events(result)
    errors = []
    events = normalize_events(result.major_events)

    unless events.is_a?(Array) && events.any?
      return { valid: false, errors: ["Major events must be a non-empty array"] }
    end

    expected_count = @problem.expected_events.length
    errors << "Event count mismatch" unless events.length == expected_count

    phases_present = events.map { |event| event.fetch(:phase) }
    REQUIRED_PRIMARY_PHASES.each do |phase|
      errors << "Missing #{phase}" unless phases_present.include?(phase)
    end

    events.each_cons(2) do |first, second|
      errors << "Events must be chronological" if second.fetch(:time) < first.fetch(:time)
    end

    {
      valid: errors.empty?,
      errors: errors
    }
  end

  def normalize_events(events)
    return events unless events.is_a?(Array)

    events.map do |event|
      {
        phase: event.fetch(:phase, event["phase"]).to_s,
        time: parse_time(event.fetch(:time, event["time"]))
      }
    end
  end

  def parse_time(value)
    value.is_a?(Time) ? value.utc : Time.iso8601(value.to_s).utc
  end
end
