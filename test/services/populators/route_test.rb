require "test_helper"

module Populators
  class RouteTest < ActiveSupport::TestCase
    test "populate" do
      line = lines(:x97)
      Arrival.delete_all
      RoutesStop.delete_all
      Schedule.delete_all
      ::Route.delete_all

      expected_routes_response = [
        {
          "route_code": "5373",
          "route_id": "01",
          "route_descr": "\u0391\u0395\u03a1\u039f\u039b\u0399\u039c\u0395\u039d\u0391\u03a3 \u0391\u0398\u0397\u039d\u03a9\u039d - \u03a3\u03a4.\u0395\u039b\u039b\u0397\u039d\u0399\u039a\u039f [EXPRESS] ",
          "route_active": "1",
          "route_descr_eng": "AER\/NAS ATHINON - ST. ELLINIKO [EXPRESS]"
        }
      ].to_json
      stub_request(:get, "#{TELEMATICS_BASE_URL}/api/?act=getRoutesForLine&p1=1547").
        to_return(status: 200, body: expected_routes_response, headers: {})

      expected_stops_response = [
        {
          "StopCode": "10705",
          "StopID": "1010",
          "StopDescr": "\u039a\u03a4\u0399\u03a1\u0399\u039f \u0391\u039d\u0391\u03a7\u03a9\u03a1\u0397\u03a3\u0395\u03a9\u039d",
          "StopDescrEng": "AIR TERMINAL (ALL DEPARTURES)",
          "StopStreet": nil,
          "StopStreetEng": nil,
          "StopHeading": "223",
          "StopLat": "37.9368263",
          "StopLng": "23.9465442",
          "RouteStopOrder": "1",
          "StopType": "0",
          "StopAmea": "0"
        },
        {
          "StopCode": "440042",
          "StopID": "440042",
          "StopDescr": "\u0395\u039c\u03a0\/\u039a\u039f \u03a0\u0391\u03a1\u039a\u039f \u0391\u0395\u03a1\u039f\u0394\u03a1\u039f\u039c\u0399\u039f\u03a5",
          "StopDescrEng": "EMP\/KO PARKO AERODROMIOY",
          "StopStreet": "\u0395\u03a3\u039f\u03a7\u0397 \u03a0\u03a1\u039f \u03a0\u0391\u03a1\u039a\u0399\u039d\u0393\u039a \u0399\u039a\u0395\u0391",
          "StopStreetEng": nil,
          "StopHeading": "223",
          "StopLat": "37.924078",
          "StopLng": "23.9314903",
          "RouteStopOrder": "2",
          "StopType": "0",
          "StopAmea": "1"
        }
      ].to_json
      stub_request(:get, "#{TELEMATICS_BASE_URL}/api/?act=webGetStops&p1=5373").
        to_return(status: 200, body: expected_stops_response, headers: {})

      assert_difference("::Route.count") do
        assert_difference("::Stop.count", 2) do
          Populators::Route.populate(line)
        end
      end

      route = ::Route.last
      assert_equal "5373", route.code
      assert_equal "01", route.route_id
      assert_equal "\u0391\u0395\u03a1\u039f\u039b\u0399\u039c\u0395\u039d\u0391\u03a3 \u0391\u0398\u0397\u039d\u03a9\u039d - \u03a3\u03a4.\u0395\u039b\u039b\u0397\u039d\u0399\u039a\u039f [EXPRESS] ", route.description
      assert_equal "AER/NAS ATHINON - ST. ELLINIKO [EXPRESS]", route.description_en
      assert route.active

      stop1 = Stop.last(2).first
      assert_equal "10705", stop1.code
      assert_equal "1010", stop1.stop_id
      assert_equal "\u039a\u03a4\u0399\u03a1\u0399\u039f \u0391\u039d\u0391\u03a7\u03a9\u03a1\u0397\u03a3\u0395\u03a9\u039d", stop1.description
      assert_equal "AIR TERMINAL (ALL DEPARTURES)", stop1.description_en
      assert_nil stop1.street
      assert_nil stop1.street_en
      assert_equal "223", stop1.heading
      assert_equal "37.9368263", stop1.lat
      assert_equal "23.9465442", stop1.lng
      assert_equal "0", stop1.stop_type
      assert_not stop1.amea

      stop2 = Stop.last
      assert_equal "440042", stop2.code
      assert_equal "440042", stop2.stop_id
      assert_equal "\u0395\u039c\u03a0/\u039a\u039f \u03a0\u0391\u03a1\u039a\u039f \u0391\u0395\u03a1\u039f\u0394\u03a1\u039f\u039c\u0399\u039f\u03a5", stop2.description
      assert_equal "EMP/KO PARKO AERODROMIOY", stop2.description_en
      assert_equal "\u0395\u03a3\u039f\u03a7\u0397 \u03a0\u03a1\u039f \u03a0\u0391\u03a1\u039a\u0399\u039d\u0393\u039a \u0399\u039a\u0395\u0391", stop2.street
      assert_nil stop2.street_en
      assert_equal "223", stop2.heading
      assert_equal "37.924078", stop2.lat
      assert_equal "23.9314903", stop2.lng
      assert_equal "0", stop2.stop_type
      assert stop2.amea
    end

    test "populate with existing route is a noop" do
      line = lines(:x97)

      expected_routes_response = [
        {
          "route_code": "5373",
          "route_id": "01",
          "route_descr": "\u0391\u0395\u03a1\u039f\u039b\u0399\u039c\u0395\u039d\u0391\u03a3 \u0391\u0398\u0397\u039d\u03a9\u039d - \u03a3\u03a4.\u0395\u039b\u039b\u0397\u039d\u0399\u039a\u039f [EXPRESS] ",
          "route_active": "1",
          "route_descr_eng": "AER\/NAS ATHINON - ST. ELLINIKO [EXPRESS]"
        }
      ].to_json
      stub_request(:get, "#{TELEMATICS_BASE_URL}/api/?act=getRoutesForLine&p1=1547").
        to_return(status: 200, body: expected_routes_response, headers: {})

      expected_stops_response = [
        {
          "StopCode": "10705",
          "StopID": "1010",
          "StopDescr": "\u039a\u03a4\u0399\u03a1\u0399\u039f \u0391\u039d\u0391\u03a7\u03a9\u03a1\u0397\u03a3\u0395\u03a9\u039d",
          "StopDescrEng": "AIR TERMINAL (ALL DEPARTURES)",
          "StopStreet": nil,
          "StopStreetEng": nil,
          "StopHeading": "223",
          "StopLat": "37.9368263",
          "StopLng": "23.9465442",
          "RouteStopOrder": "1",
          "StopType": "0",
          "StopAmea": "0"
        },
        {
          "StopCode": "440042",
          "StopID": "440042",
          "StopDescr": "\u0395\u039c\u03a0\/\u039a\u039f \u03a0\u0391\u03a1\u039a\u039f \u0391\u0395\u03a1\u039f\u0394\u03a1\u039f\u039c\u0399\u039f\u03a5",
          "StopDescrEng": "EMP\/KO PARKO AERODROMIOY",
          "StopStreet": "\u0395\u03a3\u039f\u03a7\u0397 \u03a0\u03a1\u039f \u03a0\u0391\u03a1\u039a\u0399\u039d\u0393\u039a \u0399\u039a\u0395\u0391",
          "StopStreetEng": nil,
          "StopHeading": "223",
          "StopLat": "37.924078",
          "StopLng": "23.9314903",
          "RouteStopOrder": "2",
          "StopType": "0",
          "StopAmea": "1"
        }
      ].to_json
      stub_request(:get, "#{TELEMATICS_BASE_URL}/api/?act=webGetStops&p1=5373").
        to_return(status: 200, body: expected_stops_response, headers: {})

      assert_no_difference("::Route.count") do
        assert_difference("::Stop.count", 2) do
          Populators::Route.populate(line)
        end
      end
    end
  end
end
