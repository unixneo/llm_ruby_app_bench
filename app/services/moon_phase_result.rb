require "time"

class MoonPhaseResult
  attr_reader :fixture_type,
              :illuminated_fraction,
              :phase_fraction,
              :phase_name,
              :major_events,
              :source,
              :reference_version,
              :ephemeris_required

  def initialize(fixture_type:, illuminated_fraction:, phase_fraction:, phase_name:, major_events:, source:, reference_version:, ephemeris_required:)
    @fixture_type = fixture_type
    @illuminated_fraction = illuminated_fraction
    @phase_fraction = phase_fraction
    @phase_name = phase_name
    @major_events = major_events
    @source = source
    @reference_version = reference_version
    @ephemeris_required = ephemeris_required
  end

  def to_h
    {
      fixture_type: fixture_type,
      illuminated_fraction: illuminated_fraction,
      phase_fraction: phase_fraction,
      phase_name: phase_name,
      major_events: major_events.map do |event|
        {
          phase: event.fetch(:phase).to_s,
          time: event.fetch(:time).utc.iso8601
        }
      end,
      source: source,
      reference_version: reference_version,
      ephemeris_required: ephemeris_required
    }
  end
end
