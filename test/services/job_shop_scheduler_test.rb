require "test_helper"

class JobShopSchedulerTest < ActiveSupport::TestCase
  test "solves tiny 3x3 fixture exactly" do
    fixture = JobShopFixtures.tiny_3x3
    result = JobShopScheduler.new(fixture.fetch(:jobs)).solve

    assert_equal 11, result.optimal_makespan
    assert_equal JobShopScheduler::SOURCE, result.source
    assert JobShopScheduleValidator.validate(fixture.fetch(:jobs), result.scheduled_tasks, result.optimal_makespan).fetch(:valid)
  end

  test "matches reference on all fixtures" do
    JobShopFixtures.all.each do |fixture|
      candidate = JobShopScheduler.new(fixture.fetch(:jobs)).solve
      reference = GemJobShopScheduler.new(fixture.fetch(:jobs)).solve

      assert_equal reference.optimal_makespan, candidate.optimal_makespan, "#{fixture.fetch(:name)} should match reference makespan"
      assert JobShopScheduleValidator.validate(
        fixture.fetch(:jobs),
        candidate.scheduled_tasks,
        candidate.optimal_makespan
      ).fetch(:valid)
    end
  end
end
