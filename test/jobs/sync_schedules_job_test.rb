require "test_helper"

class SyncSchedulesJobTest < ActiveJob::TestCase
  test "enqueues SyncDailyScheduleJob and SyncNormalScheduleJob for each line when athens" do
    SyncSchedulesJob.any_instance.stubs(:athens?).returns(true)

    line_ids = Line.ids.sort
    expected_job_count = line_ids.count * 2 # 2 jobs per line

    assert_enqueued_jobs expected_job_count do
      SyncSchedulesJob.perform_now
    end

    # Verify the correct jobs were enqueued for each line
    line_ids.each do |line_id|
      assert_enqueued_with(job: Schedules::Athens::SyncDailyScheduleJob, args: [line_id])
      assert_enqueued_with(job: Schedules::Athens::SyncNormalScheduleJob, args: [line_id])
    end
  end

  test "does not enqueue jobs when not athens" do
    SyncSchedulesJob.any_instance.stubs(:athens?).returns(false)

    assert_no_enqueued_jobs do
      SyncSchedulesJob.perform_now
    end
  end
end
