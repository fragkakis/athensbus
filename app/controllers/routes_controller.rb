class RoutesController < ApplicationController
  def stats
    @route = Route.find_by!(code: params[:code])
  end

end
