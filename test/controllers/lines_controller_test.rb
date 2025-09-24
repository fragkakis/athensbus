require "test_helper"

class LinesControllerTest < ActionDispatch::IntegrationTest
  test "index" do
    line = lines(:x97)
    get lines_url(date: Date.current, line_id: line.line_id)

    assert_response :ok
  end
end
