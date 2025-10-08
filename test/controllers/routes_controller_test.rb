require "test_helper"

class RoutesControllerTest < ActionDispatch::IntegrationTest
  test "index" do
    route = routes(:x97_route)
    get route_stats_url(route.route_id)

    assert_response :ok
  end
end
