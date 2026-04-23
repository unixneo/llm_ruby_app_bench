require "test_helper"

class MoonPhaseFullEventFinderTest < ActiveSupport::TestCase
  test "finds may 2024 events within two minutes of astronoby reference" do
    events = MoonPhaseFullEventFinder.new(2024, 5).major_events

    assert_equal 5, events.length
    assert_equal :last_quarter, events.first.fetch(:phase)
    assert_in_delta Time.utc(2024, 5, 23, 13, 53, 12).to_i, events[3].fetch(:time).to_i, 120
  end
end
