require "test_helper"

class LinesControllerTest < ActionDispatch::IntegrationTest
  test "index" do
    line = lines(:x93)
    get lines_url(date: Date.current, line_code: line.code)

    assert_response :ok
  end
end
