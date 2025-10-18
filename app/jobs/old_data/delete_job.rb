module OldData
  class DeleteJob < ActiveJob::Base

    DATA_RETENTION_DAYS = 10
    def perform
      deletion_threshold = DATA_RETENTION_DAYS.days.ago.beginning_of_day
      Schedule.where("date < ?", (DATA_RETENTION_DAYS).days.ago).delete_all
      Arrival.where("created_at < ?", deletion_threshold).delete_all
    end
  end
end