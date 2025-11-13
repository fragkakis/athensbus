class SyncSchedulesJob < ApplicationJob
  queue_as :default

  def perform
    Rails.benchmark("Syncing all schedules") do
      jobs = []
      Line.ids.sort.each_with_index do |line_id, i|
        if athens?
          jobs << Schedules::Athens::SyncDailyScheduleJob.new(line_id).set(priority: 2, wait_until: i.seconds.from_now)
          jobs << Schedules::Athens::SyncNormalScheduleJob.new(line_id).set(priority: 2, wait_until: i.seconds.from_now)
        end
      end
      ActiveJob.perform_all_later(jobs)
    end
  end
end
