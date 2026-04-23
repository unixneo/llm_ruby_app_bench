require "test_helper"

class MoonPhaseEventFinderTest < ActiveSupport::TestCase
  test "finds may 2024 events close to astronoby reference" do
    events = MoonPhaseEventFinder.new(2024, 5).major_events

    assert_equal 5, events.length
    assert_equal :last_quarter, events.first.fetch(:phase)
    assert_in_delta Time.utc(2024, 5, 23, 13, 53, 12).to_i, events[3].fetch(:time).to_i, 3600
  end
end
