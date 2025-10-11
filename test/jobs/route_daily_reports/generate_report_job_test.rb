require "test_helper"

module RouteDailyReports
  class GenerateReportJobTest < ActiveJob::TestCase

    test "perform" do
      route = routes(:x97_route)

      Creator.expects(:process).with(route, Date.current)

      GenerateReportJob.perform_now(route.id, Date.current)
    end
  end
end