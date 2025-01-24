require "test_helper"

class SyncStopsJobTest < ActiveSupport::TestCase
  test "perform" do
    SyncStopsBatchJob.expects(:perform_later).with(Stop.minimum(:id), Stop.maximum(:id))

    SyncStopsJob.perform_now(100)
  end
end
