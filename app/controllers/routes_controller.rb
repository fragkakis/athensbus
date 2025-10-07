class RoutesController < ApplicationController
  def stats
    @route = Route.find_by!(route_id: params[:route_id])
    @arrivals = @route.arrivals.includes(:stop)
    @trip_count_by_date = TripsCalculator.process(@route, @arrivals)
  end

end
