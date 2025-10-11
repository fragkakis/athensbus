module RouteDailyReports
  class GenerateReportJob < ApplicationJob
    queue_as :default

    def perform(route_id, date)
      Rails.benchmark("Generating daily report for route #{route_id} for date #{date}") do
        route = Route.find(route_id)
        Creator.process(route, date)
      end
    end
  end
end
