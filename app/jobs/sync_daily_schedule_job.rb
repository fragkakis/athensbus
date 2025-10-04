class SyncDailyScheduleJob < ApplicationJob
  queue_as :default
  retry_on RestClient::Exceptions::OpenTimeout

  def perform(line_id)
    Rails.benchmark("Syncing schedule for line #{line_id}") do
      line = Line.find(line_id)
      DailyScheduleSyncer.process(line)
    end
  end
end
