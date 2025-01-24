require "test_helper"

class StopSyncerTest < ActiveSupport::TestCase
  test "process with same pending arrivals" do
    stop = stops(:stop1)
    new_pending_arrivals = [
      { "line_code" => "x97", "route_code" => "4099", "veh_code" => "v1_code", "btime2" => "10" },
      { "line_code" => "x97", "route_code" => "4099", "veh_code" => "v2_code", "btime2" => "72" }
    ]
    stop.expects(:pending_arrivals).returns(new_pending_arrivals)

    assert_no_difference -> { Arrival.count } do
      StopSyncer.process(stop)
    end

    assert_equal new_pending_arrivals, stop.reload.previous_pending_arrivals
  end

  test "process with one arrival" do
    stop = stops(:stop1)
    new_pending_arrivals = [
      { "line_code" => "x97", "route_code" => "4099", "veh_code" => "v2_code", "btime2" => "72" },
      { "line_code" => "x97", "route_code" => "4099", "veh_code" => "v2_code", "btime2" => "81" }
    ]
    stop.expects(:pending_arrivals).returns(new_pending_arrivals)

    assert_difference -> { Arrival.count } do
      StopSyncer.process(stop)
    end

    arrival = Arrival.last
    assert_equal stop.code, arrival.stop.code
    assert_equal "4099", arrival.route.code
    assert_equal "v1_code", arrival.vehicle.code

    assert_equal new_pending_arrivals, stop.reload.previous_pending_arrivals
  end

  test "process with one arrival when syncing was too long ago" do
    stop = stops(:stop1)
    stop.update_columns(updated_at: 20.minutes.ago)
    new_pending_arrivals = [
      { "line_code" => "x97", "route_code" => "4099", "veh_code" => "v2_code", "btime2" => "72" },
      { "line_code" => "x97", "route_code" => "4099", "veh_code" => "v2_code", "btime2" => "81" }
    ]
    stop.expects(:pending_arrivals).returns(new_pending_arrivals)

    assert_no_difference -> { Arrival.count } do
      StopSyncer.process(stop)
    end

    assert_equal new_pending_arrivals, stop.reload.previous_pending_arrivals
  end
end
