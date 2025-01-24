require "test_helper"

class SyncStopsBatchJobTest < ActiveSupport::TestCase
  test "perform" do
    StopSyncer.expects(:process).times(Stop.count)

    SyncStopsBatchJob.perform_now(1, Stop.maximum(:id))
  end
end
