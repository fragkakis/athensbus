require "test_helper"

class TripExtractorTest < ActiveSupport::TestCase
  test "extract trips for single vehicle" do
    vehicle = Vehicle.new(code: "1")
    stop1 = Stop.create!(id: 1, description: "Stop 1")
    stop2 = Stop.create!(id: 2, description: "Stop 2")
    line = Line.create!(code: "A")
    route = Route.create!(code: "A", line: line)
    route.routes_stops.create!(stop: stop1, order: 1)
    route.routes_stops.create!(stop: stop2, order: 2)

    arrivals = [
      Arrival.new(vehicle: vehicle, stop: stop1, created_at: 60.minutes.ago),
      Arrival.new(vehicle: vehicle, stop: stop2, created_at: 59.minutes.ago)
    ]

    expected = [
      [
        { veh_code: "1", stop_description: "Stop 1", stop_lat: nil, stop_lng: nil, created_at: arrivals[0].created_at },
        { veh_code: "1", stop_description: "Stop 2", stop_lat: nil, stop_lng: nil, created_at: arrivals[1].created_at }
      ]
    ]
    assert_equal expected, TripExtractor.process(route, arrivals)
  end

  test "extract trips for single vehicle with arrivals way apart extracts different trips" do
    vehicle = Vehicle.new(code: "1")
    stop1 = Stop.create!(id: 1, description: "Stop 1")
    stop2 = Stop.create!(id: 2, description: "Stop 2")
    line = Line.create!(code: "A")
    route = Route.create!(code: "A", line: line)
    route.routes_stops.create!(stop: stop1, order: 1)
    route.routes_stops.create!(stop: stop2, order: 2)

    arrivals = [
      Arrival.new(vehicle: vehicle, stop: stop1, created_at: 5.hours.ago),
      Arrival.new(vehicle: vehicle, stop: stop2, created_at: 1.hour.ago)
    ]

    expected = [
      [ { veh_code: "1", stop_description: "Stop 1", stop_lat: nil, stop_lng: nil, created_at: arrivals[0].created_at } ],
      [ { veh_code: "1", stop_description: "Stop 2", stop_lat: nil, stop_lng: nil, created_at: arrivals[1].created_at } ]
    ]
    assert_equal expected, TripExtractor.process(route, arrivals)
  end

  test "extract trips for multiple vehicles" do
    vehicle1 = Vehicle.new(code: "1")
    vehicle2 = Vehicle.new(code: "2")
    stop1 = Stop.create!(id: 1, description: "Stop 1")
    stop2 = Stop.create!(id: 2, description: "Stop 2")
    line = Line.create!(code: "A")
    route = Route.create!(code: "A", line: line)
    route.routes_stops.create!(stop: stop1, order: 1)
    route.routes_stops.create!(stop: stop2, order: 2)

    arrivals = [
      Arrival.new(vehicle: vehicle1, stop: stop1, created_at: 60.minutes.ago),
      Arrival.new(vehicle: vehicle1, stop: stop2, created_at: 59.minutes.ago),
      Arrival.new(vehicle: vehicle2, stop: stop1, created_at: 60.minutes.ago),
      Arrival.new(vehicle: vehicle2, stop: stop2, created_at: 59.minutes.ago)
    ]

    expected = [
      [
        { veh_code: "1", stop_description: "Stop 1", stop_lat: nil, stop_lng: nil, created_at: arrivals[0].created_at },
        { veh_code: "1", stop_description: "Stop 2", stop_lat: nil, stop_lng: nil, created_at: arrivals[1].created_at }
      ],
      [
        { veh_code: "2", stop_description: "Stop 1", stop_lat: nil, stop_lng: nil, created_at: arrivals[2].created_at },
        { veh_code: "2", stop_description: "Stop 2", stop_lat: nil, stop_lng: nil, created_at: arrivals[3].created_at }
      ]
    ]
    assert_equal expected, TripExtractor.process(route, arrivals)
  end
end
