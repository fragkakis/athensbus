class RoutesController < ApplicationController
  def history
    @route = Route.find_by!(route_id: params[:route_id])
  end

end
