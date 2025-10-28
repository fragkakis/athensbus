module OldData
  class DeleteJob < ActiveJob::Base

    DATA_RETENTION_DAYS = 30
    def perform
      deletion_threshold = DATA_RETENTION_DAYS.days.ago.beginning_of_day
      Arrival.where("created_at < ?", deletion_threshold).delete_all
    end
  end
end