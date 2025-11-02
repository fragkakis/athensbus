require "test_helper"

class DailyVehicleCountCalculatorTest < ActiveSupport::TestCase

  def setup
    @route = routes(:x97_route)
    @stop = stops(:stop1)
    Arrival.delete_all
    DailyVehicleCount.delete_all
  end

  test "counts distinct vehicles for a given date" do
    date = Date.current
    vehicle1 = vehicles(:v1)

    Arrival.create!(route: @route, stop: @stop, vehicle: vehicle1,
      created_at: date.beginning_of_day + 10.hours)

    assert_changes("DailyVehicleCount.count") do
      DailyVehicleCountCalculator.process(date)
    end

    daily_vehicle_count = DailyVehicleCount.last
    assert_equal date, daily_vehicle_count.date
    assert_equal 1, daily_vehicle_count.vehicle_count
  end

  test "counts multiple distinct vehicles for a given date" do
    date = Date.current
    vehicle1 = vehicles(:v1)
    vehicle2 = Vehicle.create!(code: "v2")

    Arrival.create!(route: @route, stop: @stop, vehicle: vehicle1,
      created_at: date.beginning_of_day + 10.hours)
    Arrival.create!(route: @route, stop: @stop, vehicle: vehicle2,
      created_at: date.beginning_of_day + 11.hours)

    assert_changes("DailyVehicleCount.count") do
      DailyVehicleCountCalculator.process(date)
    end

    daily_vehicle_count = DailyVehicleCount.last
    assert_equal date, daily_vehicle_count.date
    assert_equal 2, daily_vehicle_count.vehicle_count
  end

  test "does not count duplicate vehicles" do
    date = Date.current
    vehicle1 = vehicles(:v1)

    Arrival.create!(route: @route, stop: @stop, vehicle: vehicle1,
      created_at: date.beginning_of_day + 10.hours)
    Arrival.create!(route: @route, stop: @stop, vehicle: vehicle1,
      created_at: date.beginning_of_day + 11.hours)
    Arrival.create!(route: @route, stop: @stop, vehicle: vehicle1,
      created_at: date.beginning_of_day + 12.hours)

    assert_changes("DailyVehicleCount.count") do
      DailyVehicleCountCalculator.process(date)
    end

    daily_vehicle_count = DailyVehicleCount.last
    assert_equal date, daily_vehicle_count.date
    assert_equal 1, daily_vehicle_count.vehicle_count
  end

  test "only counts vehicles from the specified date" do
    today = Date.current
    yesterday = Date.yesterday
    vehicle1 = vehicles(:v1)

    Arrival.create!(route: @route, stop: @stop, vehicle: vehicle1,
      created_at: today.beginning_of_day + 10.hours)
    Arrival.create!(route: @route, stop: @stop, vehicle: vehicle1,
      created_at: yesterday.beginning_of_day + 10.hours)

    assert_changes("DailyVehicleCount.count") do
      DailyVehicleCountCalculator.process(today)
    end

    daily_vehicle_count = DailyVehicleCount.last
    assert_equal today, daily_vehicle_count.date
    assert_equal 1, daily_vehicle_count.vehicle_count
  end

  test "creates zero count when no arrivals exist for the date" do
    date = Date.current

    DailyVehicleCountCalculator.process(date)

    daily_count = DailyVehicleCount.find_by(date: date)
    assert_equal 0, daily_count.vehicle_count
  end

  test "upserts existing record" do
    date = Date.current
    vehicle1 = vehicles(:v1)
    vehicle2 = Vehicle.create!(code: "v2")

    Arrival.create!(route: @route, stop: @stop, vehicle: vehicle1,
      created_at: date.beginning_of_day + 10.hours)

    assert_changes("DailyVehicleCount.count") do
      DailyVehicleCountCalculator.process(date)
    end

    daily_vehicle_count = DailyVehicleCount.last
    assert_equal date, daily_vehicle_count.date
    assert_equal 1, daily_vehicle_count.vehicle_count

    Arrival.create!(route: @route, stop: @stop, vehicle: vehicle2,
      created_at: date.beginning_of_day + 11.hours)

    assert_no_changes("DailyVehicleCount.count") do
      DailyVehicleCountCalculator.process(date)
    end

    daily_vehicle_count.reload
    assert_equal 2, daily_vehicle_count.vehicle_count
  end

end
