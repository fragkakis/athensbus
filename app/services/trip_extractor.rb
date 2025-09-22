class TripExtractor
  attr_reader :route, :arrivals

  def self.process(route, arrivals)
    new(route, arrivals).process
  end

  def initialize(route, arrivals)
    @route = route
    @arrivals = arrivals
    @stop_positions = @route.routes_stops.pluck(:stop_id, :order).to_h
  end

  def process
    trips = []
    arrivals_by_vehicle.each do |veh_code, veh_arrivals|
      trips += extract_vehicle_trips(veh_arrivals)
    end
    trips
  end

  private

  def extract_vehicle_trips(veh_arrivals)
    veh_arrivals_by_created_at = veh_arrivals.sort_by(&:created_at)

    trips = []
    trip = []
    current_last_arrival = nil

    loop do
      next_arrival, veh_arrivals_by_created_at = get_next_arrival(current_last_arrival, veh_arrivals_by_created_at)
      if next_arrival.present?
        trip << {
          veh_code: next_arrival.vehicle.code,
          stop_description: next_arrival.stop.description,
          stop_lat: next_arrival.stop.lat,
          stop_lng: next_arrival.stop.lng,
          created_at: next_arrival.created_at,
          stop_position: @stop_positions[next_arrival.stop_id]
        }
        if veh_arrivals_by_created_at.empty?
          trips << trip
          break
        else
          # Will look for another arrival for the same vehicle
          current_last_arrival = next_arrival
        end
      else
        trips << trip
        if veh_arrivals_by_created_at.empty?
          break
        else
          # Will look for another arrival for another vehicle
          trip = []
          current_last_arrival = nil
        end
      end
    end
    trips
  end

  def get_next_arrival(last_arrival, remaining_arrivals_by_created_at)
    raise "Should not be empty" if remaining_arrivals_by_created_at.empty?

    if last_arrival.present?
      last_arrival_stop_order = stop_id_to_stop_order[last_arrival.stop_id]
      expected_next_arrival_stop_order = last_arrival_stop_order + 1
      next_arrival = remaining_arrivals_by_created_at.find do |arrival|
        stop_id_to_stop_order[arrival.stop_id] == expected_next_arrival_stop_order &&
          (arrival.created_at - last_arrival.created_at).abs < 25.minutes
      end
      if next_arrival.present?
        [ next_arrival, remaining_arrivals_by_created_at - [ next_arrival ] ]
      else
        [ nil, remaining_arrivals_by_created_at ]
      end
    else
      next_arrival = remaining_arrivals_by_created_at.first
      # is it really the first one?
      real_next_arrival = remaining_arrivals_by_created_at.find do |arrival|
        stop_id_to_stop_order[arrival.stop_id] < stop_id_to_stop_order[next_arrival.stop_id] &&
          (arrival.created_at - next_arrival.created_at) > 5.minutes
      end
      if real_next_arrival.present?
        [ real_next_arrival, remaining_arrivals_by_created_at - [ real_next_arrival ] ]
      else
        [ next_arrival, remaining_arrivals_by_created_at - [ next_arrival ] ]
      end
    end
  end

  def arrivals_by_vehicle
    @arrivals_by_vehicle ||= arrivals.group_by { |a| a.vehicle.code }
  end

  def stop_id_to_stop_order
    @stop_id_to_stop_order ||= route.routes_stops.pluck(:stop_id, :order).to_h
  end

  def stop_order_to_stop_id
    @stop_id_to_stop_order = stop_id_to_stop_order.invert
  end
end
