module RouteDailyReports
  class GenerateReportsJob < ApplicationJob
    queue_as :default

    def perform(date = Date.current)
      Rails.benchmark("Scheduling daily report generation jobs for all routes for date #{date}") do
        jobs = Route.order(:id).ids.map do |route_id|
          GenerateReportJob.new(route_id, date).set(priority: 2)
        end
        ActiveJob.perform_all_later(jobs)
      end
    end
  end
end
