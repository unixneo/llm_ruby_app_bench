require "test_helper"

class GemJobShopSchedulerTest < ActiveSupport::TestCase
  test "or tools cp sat solves tiny fixture" do
    fixture = JobShopFixtures.tiny_3x3
    result = GemJobShopScheduler.new(fixture.fetch(:jobs)).solve

    assert_equal "or-tools", result.source
    assert_equal GemJobShopScheduler::REFERENCE_VERSION, result.reference_version
    assert_equal 11, result.optimal_makespan
    assert_equal fixture.fetch(:jobs).sum(&:length), result.scheduled_tasks.length
  end
end
