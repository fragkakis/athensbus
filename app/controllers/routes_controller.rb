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
      arrivals = @route.arrivals.where("created_at between ? and ?", date.beginning_of_day, date.end_of_day)
      trips = TripExtractor.process(@route, arrivals)
      TripTimestampSanitizer.process(trips)
      @data = transform_to_data(trips)
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
      trip.each.each do |trip_arrival|
        data << {
          train: "#{trip_arrival[:vehicle_code]} #{i}",
          speed: "normal",
          schedule: "weekday",
          direction: "S",
          station: trip_arrival[:stop_description],
          distance: ::Geocoder::Calculations.distance_between([ @route.stops.first.lat, @route.stops.first.lng ], [ trip_arrival[:stop_lat], trip_arrival[:stop_lng] ], units: :km),
          zone: 1,
          time: trip_arrival[:created_at].strftime("%l:%M%P")
        }
      end
    end
    data
  end
end
