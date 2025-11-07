require "test_helper"

class StopTest < ActiveSupport::TestCase
  test "pending_arrivals" do
    stop = stops(:stop1)

    expected = [
      { "line_code" => "x97", "route_code"=> "5373", "veh_code"=> "v1_code", "btime2"=> "12" },
      { "line_code"=> "x97", "route_code"=> "5373", "veh_code"=> "v2_code", "btime2"=> "75" }
    ]

    stub_request(:get, "#{TELEMATICS_BASE_URL}/api/?act=getStopArrivals&p1=stop1_code").
      to_return(status: 200, body: expected.to_json, headers: {})

    assert_equal expected, stop.pending_arrivals
  end

  test "pending_arrivals with empty body" do
    stop = stops(:stop1)

    stub_request(:get, "#{TELEMATICS_BASE_URL}/api/?act=getStopArrivals&p1=stop1_code").
      to_return(status: 200, body: "null", headers: {})

    expected = []
    assert_equal expected, stop.pending_arrivals
  end
end
