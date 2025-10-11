require "test_helper"

module RouteDailyReports
  class TripExtractorTest < ActiveSupport::TestCase
    test "process" do
      route = routes(:x93_route_1)

      TripsCalculator.expects(:process).returns(mock("mock_trips", size: 10))

      assert_changes("RouteDailyReport.count") do
        Creator.process(route, Date.current)
      end

      route_daily_report = RouteDailyReport.last
      assert_equal 10, route_daily_report.executed_trips
      assert_equal route.id, route_daily_report.route_id
      assert_equal Date.current, route_daily_report.date
    end

    test "process with existing route daily report" do
      route = routes(:x93_route_1)
      route_daily_report = route.route_daily_reports.create!(date: Date.current, executed_trips: 10)

      assert_no_changes("RouteDailyReport.count") do
        Creator.process(route, Date.current)
      end

      route_daily_report.reload
      assert_equal 0, route_daily_report.executed_trips

    end
  end
end
