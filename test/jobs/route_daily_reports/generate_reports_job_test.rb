require "test_helper"

module RouteDailyReports
  class GenerateReportsJobTest < ActiveJob::TestCase

    test "perform" do

      assert_enqueued_jobs Route.count, only: GenerateReportJob do
        GenerateReportsJob.perform_now(Date.current)
      end

    end
  end
end