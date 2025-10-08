class LinesController < ApplicationController
  before_action :set_lines

  def index
    if(params[:line_code])
      @line = Line.find_by!(code: params[:line_code])
      @route = params[:route_id] ?
                 @line.routes.find_by(route_id: params[:route_id]) :
                 @line.routes.first
      @date_min = Arrival.minimum(:created_at).to_date.to_s
      @date_max = Arrival.maximum(:created_at).to_date.to_s
      arrivals = @route.arrivals.
        at_date(date).
        includes(:vehicle, :stop)
      @trips = TripExtractor.process(@route, arrivals)
      TripTimestampSanitizer.process(@trips)
      @data = transform_to_data(@trips)
      @all_stops = @route.stops.map.with_index(1) { |stop, index| { name: stop.description, position: index } }

      @daily_schedule = @route.schedules.daily.find_by(date: date)&.departure_times || []
      @normal_schedule = @route.schedules.normal.find_by(date: date)&.departure_times || []
      @dropped_trips = @normal_schedule - @daily_schedule
      @executed_trips_count = TripsCalculator.process(@route, arrivals).values.first || 0
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("search_results", partial: "search_results"),
          turbo_stream.replace("route_select", partial: "route_select")
        ]
      end
      format.html
    end
  end

  private

  def set_lines
    # for the dropdown
    @lines = if date.present?
               line_ids = Arrival.
                 joins(:route).
                 where("arrivals.created_at between ? and ?", date.beginning_of_day, date.end_of_day).
                 pluck(Arel.sql("distinct routes.line_id"))
               Line.where(id: line_ids).order(:line_id)
             else
               Line.all.order("line_id")
             end
  end

  def date
    return Date.current unless params[:date].present?
    @date ||= Date.parse(params[:date])
  end

  def transform_to_data(trips)
    data = []
    trips.each_with_index do |trip, i|
      trip.each.each_with_index do |trip_arrival, j|
        data << {
          vehicle: "#{trip_arrival[:veh_code]}-#{i}",
          speed: "normal",
          stop: trip_arrival[:stop_description],
          distance: trip_arrival[:stop_position],
          zone: 1,
          time: trip_arrival[:created_at].strftime("%l:%M%P")
        }
      end
    end
    data
  end
end
