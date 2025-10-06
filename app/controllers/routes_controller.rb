class RoutesController < ApplicationController
  def stats
    @route = Route.find_by!(route_id: params[:route_id])
  end

end
