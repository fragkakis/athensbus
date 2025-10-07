class TripsCalculator
  attr_reader :arrivals, :route
  def self.process(route, arrivals)
    new(route, arrivals).process
  end

  def initialize(route, arrivals)
    @arrivals = arrivals
    @route = route
  end

  def process
    stop_count = route.stops.size
    ignored_stop_number = (stop_count * 0.3).ceil
    puts "ignoring #{ignored_stop_number}"
    # "trim" the outermost stops, which tend to be the more problematic
    considered_stops = route.stops[(ignored_stop_number)..(stop_count - 1 - ignored_stop_number)]
    considered_stop_ids = considered_stops.map(&:id)
    considered_arrivals = arrivals.select{ |a| considered_stop_ids.include?(a.stop_id) }
    considered_arrivals.size / considered_stops.size
  end
end