class RoutesController < ApplicationController
  def index
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

    if params[:line_code].present? && date.present?
      @line = Line.find_by(code: params[:line_code])
      @route = @line.routes.first
      arrivals = @route.arrivals.
        where("created_at between ? and ?", date.beginning_of_day, date.end_of_day).
        includes(:vehicle, :stop)
      trips = TripExtractor.process(@route, arrivals)
      TripTimestampSanitizer.process(trips)
      @data = transform_to_data(trips)
      @all_stops = @route.stops.map.with_index(1) { |stop, index| { name: stop.description, position: index } }
    end
  end

  private

  def date
    return unless params[:date].present?
    @date ||= Date.parse(params[:date])
  end

  def transform_to_data(trips)
    data = []
    trips.each_with_index do |trip, i|
      trip.each.each_with_index do |trip_arrival, j|
        first_stop = @route.stops.first
        is_last_arrival = (j == trip.length - 1)
        data << {
          vehicle: "#{trip_arrival[:veh_code]}-#{i}",
          speed: is_last_arrival ? "last" : "normal",
          schedule: "weekday",
          direction: "S",
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
