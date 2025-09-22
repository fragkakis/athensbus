class SyncStopsJob < ApplicationJob
  queue_as :default

  def perform(batch_size)
    Rails.benchmark("Scheduling all batches of stops") do
      jobs = Stop.ids.sort.each_slice(batch_size).map do |stops_batch|
        SyncStopsBatchJob.new(stops_batch.first, stops_batch.last).set(priority: 1)
      end
      ActiveJob.perform_all_later(jobs)
    end
  end
end
