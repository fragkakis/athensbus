class RoutesController < ApplicationController
  def show
    route = Route.find_by(code: params[:code])
    arrivals = route.arrivals.where("created_at > ?", 1.day.ago)
    arrivals_by_itinerary = arrivals.group_by(&:vehicle_id)
    stop_positions = route.routes_stops.pluck(:stop_id, :order).to_h

    @data = arrivals_by_itinerary.map do |vehicle_id, arrivals|
      {
        name: vehicle_id,
        data: arrivals
               .sort_by { |a| stop_positions[a.stop_id] }
               .map { |a| [ a.created_at.round(0), stop_positions[a.stop_id] ] }
      }
    end
  end
end
