class Arrival < ApplicationRecord
  belongs_to :route
  belongs_to :stop
  belongs_to :vehicle

  def stop_order
    route.routes_stops.find_by(stop_id: stop_id).order
  end
end
