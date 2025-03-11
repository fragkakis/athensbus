require "test_helper"

class RoutesControllerTest < ActionDispatch::IntegrationTest
  test "index" do
    line = lines(:x97)
    get routes_url(date: Date.current, line_code: line.code)

    assert_response :ok
  end
end
