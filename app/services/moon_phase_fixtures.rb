class MoonPhaseFixtures
  class << self
    def all
      [
        new_moon_2024_01,
        full_moon_2024_01,
        first_quarter_2024_05,
        events_2024_05,
        events_2025_03
      ]
    end

    def find(name)
      all.find { |fixture| fixture.fetch(:name) == name } || raise(KeyError, "unknown moon phase fixture: #{name}")
    end

    def seed!
      all.each do |fixture|
        MoonPhaseProblem.find_or_create_by!(name: fixture.fetch(:name)) do |problem|
          problem.fixture_type = fixture.fetch(:fixture_type)
          problem.observation_date = fixture[:observation_date]
          problem.year = fixture[:year]
          problem.month = fixture[:month]
          problem.expected_illuminated_fraction = fixture[:expected_illuminated_fraction]
          problem.expected_phase_fraction = fixture[:expected_phase_fraction]
          problem.expected_phase_name = fixture[:expected_phase_name]
          problem.expected_events = fixture[:expected_events]
          problem.description = fixture.fetch(:description)
        end
      end
    end

    def new_moon_2024_01
      {
        name: "moon_phase_new_moon_2024_01",
        fixture_type: "daily",
        observation_date: Date.new(2024, 1, 11),
        expected_illuminated_fraction: 0.001911,
        expected_phase_fraction: 0.010761,
        expected_phase_name: "new_moon",
        description: "Date near January 2024 new moon - low illuminated fraction expected"
      }
    end

    def full_moon_2024_01
      {
        name: "moon_phase_full_moon_2024_01",
        fixture_type: "daily",
        observation_date: Date.new(2024, 1, 25),
        expected_illuminated_fraction: 0.997632,
        expected_phase_fraction: 0.484846,
        expected_phase_name: "full_moon",
        description: "Date near January 2024 full moon - high illuminated fraction expected"
      }
    end

    def first_quarter_2024_05
      {
        name: "moon_phase_first_quarter_2024_05",
        fixture_type: "daily",
        observation_date: Date.new(2024, 5, 15),
        expected_illuminated_fraction: 0.502129,
        expected_phase_fraction: 0.24366,
        expected_phase_name: "first_quarter",
        description: "Date near May 2024 first quarter - moderate illuminated fraction expected"
      }
    end

    def events_2024_05
      {
        name: "moon_phase_events_2024_05",
        fixture_type: "events",
        year: 2024,
        month: 5,
        expected_events: [
          { phase: "last_quarter", time: "2024-05-01T11:27:15Z" },
          { phase: "new_moon", time: "2024-05-08T03:21:56Z" },
          { phase: "first_quarter", time: "2024-05-15T11:48:02Z" },
          { phase: "full_moon", time: "2024-05-23T13:53:12Z" },
          { phase: "last_quarter", time: "2024-05-30T17:12:42Z" }
        ],
        description: "All major phase events for May 2024 - verified against astronoby 0.9.0"
      }
    end

    def events_2025_03
      {
        name: "moon_phase_events_2025_03",
        fixture_type: "events",
        year: 2025,
        month: 3,
        expected_events: [
          { phase: "first_quarter", time: "2025-03-06T16:31:37Z" },
          { phase: "full_moon", time: "2025-03-14T06:54:38Z" },
          { phase: "last_quarter", time: "2025-03-22T11:29:37Z" },
          { phase: "new_moon", time: "2025-03-29T10:57:45Z" }
        ],
        description: "All major phase events for March 2025 - reference values from astronoby 0.9.0"
      }
    end
  end
end
