require "test_helper"

module Populators
  class LineTest < ActiveSupport::TestCase
    test "populate_all" do
      response = [
        {
          "LineCode": "1151",
          "LineID": "021",
          "LineDescr": "\u03a0\u039b\u0391\u03a4\u0395\u0399\u0391 \u039a\u0391\u039d\u0399\u0393\u0393\u039f\u03a3 - \u0393\u039a\u03a5\u0396H (\u039a\u03a5\u039a\u039b\u0399\u039a\u0397)",
          "LineDescrEng": "PLATEIA KANIGKOS - GKIZI"
        },
        {
          "LineCode": "1574",
          "LineID": "021",
          "LineDescr": "\u03a0\u039b\u0391\u03a4\u0395\u0399\u0391 \u039a\u0391\u039d\u0399\u0393\u0393\u039f\u03a3 - \u0393\u039a\u03a5\u0396H (\u0391\u03a0\u039f \u0393\u039a\u03a5\u0396\u0397)",
          "LineDescrEng": "PLATEIA KANIGKOS - GKIZI (FROM GKIZI TO PLATEIA KANIGKOS)"
        }
      ].to_json

      stub_request(:get, "#{TELEMATICS_BASE_URL}/api/?act=webGetLines").
        to_return(status: 200, body: response, headers: {})

      ::Populators::Route.expects(:populate).twice

      assert_difference("::Line.count", 2) do
        Populators::Line.populate_all
      end

      line1 = ::Line.last(2).first
      assert_equal "1151", line1.code
      assert_equal "021", line1.line_id
      assert_equal "\u03a0\u039b\u0391\u03a4\u0395\u0399\u0391 \u039a\u0391\u039d\u0399\u0393\u0393\u039f\u03a3 - \u0393\u039a\u03a5\u0396H (\u039a\u03a5\u039a\u039b\u0399\u039a\u0397)", line1.description
      assert_equal "PLATEIA KANIGKOS - GKIZI", line1.description_en

      line2 = ::Line.last
      assert_equal "1574", line2.code
      assert_equal "021", line2.line_id
      assert_equal "\u03a0\u039b\u0391\u03a4\u0395\u0399\u0391 \u039a\u0391\u039d\u0399\u0393\u0393\u039f\u03a3 - \u0393\u039a\u03a5\u0396H (\u0391\u03a0\u039f \u0393\u039a\u03a5\u0396\u0397)", line2.description
      assert_equal "PLATEIA KANIGKOS - GKIZI (FROM GKIZI TO PLATEIA KANIGKOS)", line2.description_en
    end

    test "populate" do
      line_payload = {
        "LineCode": "1151",
        "LineID": "021",
        "LineDescr": "\u03a0\u039b\u0391\u03a4\u0395\u0399\u0391 \u039a\u0391\u039d\u0399\u0393\u0393\u039f\u03a3 - \u0393\u039a\u03a5\u0396H (\u039a\u03a5\u039a\u039b\u0399\u039a\u0397)",
        "LineDescrEng": "PLATEIA KANIGKOS - GKIZI"
      }.stringify_keys
      ::Populators::Route.expects(:populate)

      assert_difference("::Line.count") do
        Populators::Line.populate(line_payload)
      end

      line = ::Line.last
      assert_equal "1151", line.code
      assert_equal "021", line.line_id
      assert_equal "\u03a0\u039b\u0391\u03a4\u0395\u0399\u0391 \u039a\u0391\u039d\u0399\u0393\u0393\u039f\u03a3 - \u0393\u039a\u03a5\u0396H (\u039a\u03a5\u039a\u039b\u0399\u039a\u0397)", line.description
      assert_equal "PLATEIA KANIGKOS - GKIZI", line.description_en
    end

  end
end
