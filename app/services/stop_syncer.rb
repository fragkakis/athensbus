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
    last_sync_pending_arrivals = stop.last_sync_pending_arrivals
    last_synced_at = stop.last_synced_at

    # only create arrivals if syncing wasn't too long ago
    if stop.updated_at > 10.minutes.ago
      last_sync_pending_arrivals.each do |past_pending_arrival|
        next if pending_arrivals.any? { |arrival| arrival["veh_code"] == past_pending_arrival["veh_code"] }

        # vehicle has arrived
        route = Route.find_by(code: past_pending_arrival["route_code"])
        if route.nil?
          Rails.logger.error(">>>>> Route with code #{past_pending_arrival["route_code"]} not found")
        end
        arrival_timestamp = [ last_synced_at + past_pending_arrival["btime2"].to_i.minutes, Time.now ].min
        Arrival.create!(stop: stop,
                        route: route,
                        vehicle: Vehicle.find_or_create_by!(code: past_pending_arrival["veh_code"],
                        created_at: arrival_timestamp)
        )
      end
    end

    stop.update!(last_sync_pending_arrivals: pending_arrivals, last_synced_at: Time.current)
    Rails.logger.info("Synced stop with id: #{stop.id}")
  end
end
