class StopSyncer
  attr_reader :stop

  def self.process(stop)
    new(stop).process
  end

  def initialize(stop)
    @stop = stop
  end

  def process
    Rails.logger.info("Syncing stop with id: #{stop.id}")
    pending_arrivals = stop.pending_arrivals
    previous_pending_arrivals = stop.previous_pending_arrivals

    # only create arrivals if syncing wasn't too long ago
    if stop.updated_at > 10.minutes.ago
      previous_pending_arrivals.each do |previous_pending_arrival|
        next if pending_arrivals.any? { |arrival| arrival["veh_code"] == previous_pending_arrival["veh_code"] }

        # vehicle has arrived
        route = Route.find_by(code: previous_pending_arrival["route_code"])
        if route.nil?
          Rails.logger.error(">>>>> Route with code #{previous_pending_arrival["route_code"]} not found")
        end
        Arrival.create!(stop: stop,
                        route: route,
                        vehicle: Vehicle.find_or_create_by!(code: previous_pending_arrival["veh_code"])
        )
      end
    end

    stop.update!(previous_pending_arrivals: pending_arrivals)
    Rails.logger.info("Synced stop with id: #{stop.id}")
  end
end
