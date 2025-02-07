class RoutesController < ApplicationController
  def show
    @route = Route.find_by(code: params[:code])
    arrivals = @route.arrivals.where("created_at between ? and ?", 3.days.ago, 2.day.ago)
    trips = TripExtractor.process(@route, arrivals)
    TripTimestampSanitizer.process(trips)
    @data = transform_to_data(trips)
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
