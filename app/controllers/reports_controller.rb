class ReportsController < ApplicationController

  def index

  end

  def coverage
    @routes = Route.all.includes(:line)
  end
end
