require "test_helper"

class ScheduleTest < ActiveSupport::TestCase
  test "daily scope" do
    daily_schedule = schedules(:x97_route_daily)
    assert_includes Schedule.daily, daily_schedule
  end

  test "normal scope" do
    normal_schedule = schedules(:x97_route_normal)
    assert_includes Schedule.normal, normal_schedule
  end
end
