require "test_helper"

class TripTimestampSanitizerTest < ActiveSupport::TestCase
  test "process" do
    ts1 = 60.minutes.ago
    ts2 = 59.minutes.ago
    ts3 = 58.minutes.ago
    trips = [
      [
        { veh_code: "1", created_at: ts3 },
        { veh_code: "1", created_at: ts2 },
        { veh_code: "1", created_at: ts1 }
      ]
    ]

    expected = [
      [
        { veh_code: "1", created_at: ts1 },
        { veh_code: "1", created_at: ts2 },
        { veh_code: "1", created_at: ts3 }
      ]
    ]

    assert_equal expected, TripTimestampSanitizer.process(trips)
  end
end
