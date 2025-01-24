class SyncStopsJob < ApplicationJob
  queue_as :default

  def perform(batch_size)
    Stop.ids.sort.each_slice(batch_size).with_index do |stops_batch, i|
      SyncStopsBatchJob.set(priority: 1, wait: (i*2).seconds).perform_later(stops_batch.first, stops_batch.last)
    end
  end
end
