require "test_helper"

class TripCalculatorTest < ActiveSupport::TestCase
  test "process" do

    v = vehicles(:v1)
    r = routes(:x97_route)
    r.arrivals.delete_all

    now = Time.current
    arrivals_data = 10.times.flat_map do |i|
      r.stops.map do |s|
        { stop_id: s.id, route_id: r.id, vehicle_id: v.id, created_at: now, updated_at: now }
      end
    end

    Arrival.insert_all!(arrivals_data)

    arrivals = r.reload.arrivals

    expected = {Date.current.to_s => 10}
    assert_equal expected, TripsCalculator.process(r, arrivals)
  end
end

