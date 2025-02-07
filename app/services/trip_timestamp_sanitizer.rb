class TripTimestampSanitizer
  attr_reader :trips

  def self.process(trips)
    new(trips).process
  end

  def initialize(trips)
    @trips = trips
  end

  def process
    sanitized_trips = trips.dup
    sanitized_trips.each do |trip|
      trip_arrivals_sorted = trip.pluck(:created_at).sort
      trip.each_with_index do |trip_arrival, i|
        trip_arrival[:created_at] = trip_arrivals_sorted[i]
      end
    end
    sanitized_trips
  end
end
