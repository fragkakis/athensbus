require "test_helper"

module Schedules
  module Athens
    class NormalScheduleSyncerTest < ActiveSupport::TestCase

      test "sync" do
        SdcCodePicker.expects(:process).returns("foo_sdc_code")

        stub_request(:get, "#{TELEMATICS_BASE_URL}/api/?act=getSchedLines&p1=%CE%A793&p2=foo_sdc_code&p3=1521").
          to_return(status: 200, body: File.read(Rails.root.join("test/fixtures/files/daily_schedule.json")))

        line = lines(:x93)
        line.routes.each do |route|
          route.schedules.delete_all
        end

        assert_difference "Schedule.count", 2 do
          Schedules::Athens::NormalScheduleSyncer.process(line)
        end

        schedules = Schedule.last(2)

        go_route = routes(:x93_route_1)
        assert_equal go_route.id, schedules[0].route_id
        assert_equal Schedule::NORMAL, schedules[0].type
        expected_departure_times = ["4:15", "4:40", "5:00", "5:25", "5:50", "6:10", "6:25", "6:45", "6:55", "7:40", "8:00", "8:25", "8:45", "9:00", "9:45", "10:10", "10:25", "10:40", "11:00", "11:35", "11:55", "12:25", "12:55", "13:25", "13:30", "13:45", "14:00", "14:30", "15:15", "15:35", "15:50", "16:05", "16:20", "16:50", "17:45", "18:05", "18:25", "18:45", "19:05", "20:20", "20:40", "21:00", "21:15", "22:15", "22:40", "23:00", "23:20", "23:40", "0:00", "0:25", "0:45", "1:15", "1:45", "2:15", "2:45", "3:15", "3:45"]
        assert_equal expected_departure_times, schedules[0].departure_times

        come_route = routes(:x93_route_2)
        assert_equal come_route.id, schedules[1].route_id
        assert_equal Schedule::NORMAL, schedules[1].type
        expected_departure_times = ["5:00", "5:25", "5:50", "6:15", "6:40", "7:00", "7:20", "7:35", "7:50", "9:00", "9:20", "9:50", "10:15", "10:25", "10:45", "11:10", "11:50", "12:05", "12:20", "12:35", "12:50", "13:20", "14:05", "14:20", "14:30", "14:40", "14:55", "15:10", "15:40", "16:25", "16:45", "17:15", "17:30", "17:40", "17:55", "19:15", "19:35", "19:55", "20:15", "21:05", "21:35", "21:50", "22:10", "22:30", "23:20", "23:35", "23:50", "0:05", "0:25", "0:45", "1:10", "1:30", "2:00", "2:30", "3:00", "3:30", "4:00", "4:30"]
        assert_equal expected_departure_times, schedules[1].departure_times
      end
    end
  end
end
