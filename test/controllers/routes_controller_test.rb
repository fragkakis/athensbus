require "test_helper"

class RoutesControllerTest < ActionDispatch::IntegrationTest
  test "show" do
    get route_url(code: "4099")

    assert_response :ok
  end
end
