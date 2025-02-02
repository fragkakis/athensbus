require "test_helper"

class SyncStopsJobTest < ActiveJob::TestCase
  test "perform" do
    assert_enqueued_with(job: SyncStopsBatchJob, args: [ Stop.minimum(:id), Stop.maximum(:id) ]) do
      SyncStopsJob.perform_now(100)
    end
  end
end
