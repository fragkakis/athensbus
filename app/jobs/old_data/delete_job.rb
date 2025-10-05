module OldData
  class DeleteJob < ActiveJob::Base

    DATA_RETENTION_DAYS = 30
    def perform
      Schedule.where("date < ?", DATA_RETENTION_DAYS.days.ago).delete_all
      Arrival.where("created_at < ?", DATA_RETENTION_DAYS.days.ago.beginning_of_day).delete_all
    end
  end
end