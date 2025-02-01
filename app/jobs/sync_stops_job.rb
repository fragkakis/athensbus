class SyncStopsJob < ApplicationJob
  queue_as :default

  def perform(batch_size)
    Rails.benchmark("Scheduling all batches of stops") do
      Stop.ids.sort.each_slice(batch_size).with_index do |stops_batch, i|
        SyncStopsBatchJob.set(priority: 1).perform_later(stops_batch.first, stops_batch.last)
      end
    end
  end
end
