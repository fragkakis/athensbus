class SyncStopsBatchJob < ApplicationJob
  queue_as :default

  def perform(min_stop_id, max_stop_id)
    Rails.benchmark("Scheduling of ids between #{min_stop_id} and #{max_stop_id}") do
      Rails.logger.info("Syncing stops with ids between #{min_stop_id} and #{max_stop_id}")
      Stop.where("id between ? and ?", min_stop_id, max_stop_id).order(:id).ids.each do |stop_id|
        SyncStopJob.set(priority: 2).perform_later(stop_id)
      end
      Rails.logger.info("Finished syncing stops with ids between #{min_stop_id} and #{max_stop_id}")
    end
  end
end
