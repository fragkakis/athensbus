class SyncStopsBatchJob < ApplicationJob
  queue_as :default

  def perform(min_stop_id, max_stop_id)
    Rails.benchmark("Scheduling of ids between #{min_stop_id} and #{max_stop_id}") do
      Rails.logger.info("Syncing stops with ids between #{min_stop_id} and #{max_stop_id}")
      jobs = Stop.where("id between ? and ?", min_stop_id, max_stop_id).order(:id).ids.map do |stop_id|
        SyncStopJob.new(stop_id).set(priority: 2, wait: (stop_id % 300).seconds)
      end
      ActiveJob.perform_all_later(jobs)
      Rails.logger.info("Finished syncing stops with ids between #{min_stop_id} and #{max_stop_id}")
    end
  end
end
