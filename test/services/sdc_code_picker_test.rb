require "test_helper"

class SdcCodePickerTest < ActiveSupport::TestCase
  test "process" do

    response = [
      {
        "sdc_descr" => "ΧΕΙΜΕΡΙΝΟ ΚΑΘΗΜΕΡΙΝΗ",
        "sdc_descr_eng" => "WINTER DAILY",
        "sdc_code" => "54",
        "" => "0"
      },
      {
        "sdc_descr": "ΧΕΙΜΕΡΙΝΟ ΔΕΥΤΕΡΑ - ΠΕΜΠΤΗ",
        "sdc_descr"=> "ΧΕΙΜΕΡΙΝΟ ΔΕΥΤΕΡΑ - ΠΕΜΠΤΗ",
        "sdc_descr_eng"=> "WINTER MONDAY TO THURSDAY",
        "sdc_code"=> "113",
        ""=> "0"
      },
      {
        "sdc_descr"=> "ΧΕΙΜΕΡΙΝΟ ΠΑΡΑΣΚΕΥΗ",
        "sdc_descr_eng"=> "WINTER FRIDAY",
        "sdc_code"=> "58",
        ""=> "0"
      },
      {
        "sdc_descr"=> "ΧΕΙΜΕΡΙΝΟ ΣΑΒΒΑΤΟ",
        "sdc_descr_eng"=> "WINTER SATURDAY",
        "sdc_code"=> "59",
        ""=> "1"
      },
      {
        "sdc_descr"=> "ΧΕΙΜΕΡΙΝO ΚΥΡΙΑΚΗ",
        "sdc_descr_eng"=> "WINTER SUNDAY",
        "sdc_code"=> "60",
        ""=> "0"
      }
    ]

    stub_request(:get, "http://telematics.oasa.gr/api/?act=getScheduleDaysMasterline&p1=1547").
      to_return(status: 200, body: response.to_json, headers: {})

    line = lines(:x97)

    assert_sdc_code_for_day("113", :monday, line)
    assert_sdc_code_for_day("113", :tuesday, line)
    assert_sdc_code_for_day("113", :wednesday, line)
    assert_sdc_code_for_day("113", :thursday, line)
    assert_sdc_code_for_day("58", :friday, line)
    assert_sdc_code_for_day("59", :saturday, line)
    assert_sdc_code_for_day("60", :sunday, line)
  end

  private

  def assert_sdc_code_for_day(expected_code, day_of_week, line)
    travel_to(Date.today.next_occurring(day_of_week)) do
      assert_equal expected_code, SdcCodePicker.process(line)
    end
  end

end
