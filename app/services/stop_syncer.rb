class StopSyncer
  attr_reader :stop

  def self.process(stop)
    new(stop).process
  end

  def initialize(stop)
    @stop = stop
  end

  def process
    pending_arrivals = stop.pending_arrivals
    previous_pending_arrivals = stop.previous_pending_arrivals

    previous_pending_arrivals.each do |previous_pending_arrival|
      next if pending_arrivals.any? { |arrival| arrival["veh_code"] == previous_pending_arrival["veh_code"] }

      # vehicle has arrived
      Arrival.create!(stop: stop,
                      route: Route.find_by(code: previous_pending_arrival["route_code"]),
                      vehicle: Vehicle.find_by(code: previous_pending_arrival["veh_code"])
      )
    end
    stop.update!(previous_pending_arrivals: pending_arrivals)
  end
end
