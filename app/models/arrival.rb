class Arrival < ApplicationRecord
  belongs_to :route
  belongs_to :stop
  belongs_to :vehicle

  def self.at_date(date)
    where("created_at between ? and ?", date.beginning_of_day, date.end_of_day)
  end

  def self.today
    at_date(Date.current)
  end

  def self.yesterday
    at_date(Date.yesterday)
  end

  def stop_order
    route.routes_stops.find_by(stop_id: stop_id).order
  end
end
