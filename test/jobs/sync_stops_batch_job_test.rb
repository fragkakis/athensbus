require "test_helper"

class SyncStopsBatchJobTest < ActiveJob::TestCase
  test "perform" do
    assert_enqueued_jobs Stop.count, only: SyncStopJob do
      SyncStopsBatchJob.perform_now(1, Stop.maximum(:id))
    end
  end
end
