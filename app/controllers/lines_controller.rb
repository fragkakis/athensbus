class LinesController < ApplicationController
  def index
    # if params[:date].present?
    #   date = Date.parse(params[:date])
    #   line_ids = Arrival.
    #     where("arrivals.created_at between ? and ?", date.beginning_of_day, date.end_of_day).
    #     joins(:route).pluck(Arel.sql("distinct routes.line_id"))
    #   lines = Line.where(id: line_ids).order(:line_id)
    # else
    #   lines = Line.all.order(:line_id)
    # end
    # respond_to do |format|
    #   format.json { render json: lines.map { |line| {id: line.id, line_id: line.line_id, description: line.description } }.to_json }
    # end
  end
end
