class SyncStopsBatchJob < ApplicationJob
  queue_as :default

  def perform(min_stop_id, max_stop_id)
    Rails.logger.info("Syncing stops with ids between #{min_stop_id} and #{max_stop_id}")
    threads = []
    Stop.where("id BETWEEN ? and ?", min_stop_id, max_stop_id).each do |stop|
      threads << Thread.new do
        StopSyncer.process(stop)
      end
    end
    threads.each(&:join)
    Rails.logger.info("Finished syncing stops with ids between #{min_stop_id} and #{max_stop_id}")
  end
end
