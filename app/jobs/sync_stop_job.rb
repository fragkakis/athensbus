class SyncStopJob < ApplicationJob
  queue_as :default
  retry_on RestClient::Exceptions::OpenTimeout

  def perform(stop_id)
    Rails.benchmark("Syncing of stop #{stop_id}") do
      stop = Stop.find(stop_id)
      StopSyncer.process(stop)
    end
  end
end
