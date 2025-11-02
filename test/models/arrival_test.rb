require "test_helper"

class ArrivalTest < ActiveSupport::TestCase

  test "at_date returns arrivals created on specified date" do
    route = routes(:x97_route)
    stop = stops(:stop1)
    vehicle = vehicles(:v1)
    Arrival.delete_all

    arrival_today = Arrival.create!(route: route, stop: stop, vehicle: vehicle,
      created_at: Date.current.beginning_of_day + 10.hours)

    arrival_yesterday = Arrival.create!(route: route, stop: stop, vehicle: vehicle,
      created_at: Date.yesterday.beginning_of_day + 10.hours)

    assert_equal [arrival_today], Arrival.at_date(Date.current)
    assert_equal [arrival_yesterday], Arrival.at_date(Date.yesterday)
  end

  test "at_date returns all arrivals throughout the day" do
    route = routes(:x97_route)
    stop = stops(:stop1)
    vehicle = vehicles(:v1)
    Arrival.delete_all

    arrival_morning = Arrival.create!(route: route, stop: stop, vehicle: vehicle,
      created_at: Date.current.beginning_of_day + 1.minute)

    arrival_evening = Arrival.create!(route: route, stop: stop, vehicle: vehicle,
      created_at: Date.current.end_of_day - 1.minute)

    assert_equal [arrival_morning, arrival_evening].sort_by(&:created_at),
      Arrival.at_date(Date.current).sort_by(&:created_at)
  end

  test "stop_order returns the order of the stop in the route" do
    arrival = arrivals(:x97_route_stop1_v1_day1)

    assert_equal 1, arrival.stop_order
  end

  test "stop_order returns correct order for different stop in same route" do
    arrival = arrivals(:x97_route_stop2_v1_day1)

    assert_equal 2, arrival.stop_order
  end

  test "stop_order handles terminal stops correctly" do
    route = routes(:x97_route)
    stop = stops(:stop1)
    vehicle = vehicles(:v1)
    Arrival.delete_all
    
    arrival = Arrival.create!(route: route, stop: stop, vehicle: vehicle,
      created_at: Time.current)

    assert_equal 1, arrival.stop_order
  end
end
