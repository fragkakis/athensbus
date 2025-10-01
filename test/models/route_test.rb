require "test_helper"

class RouteTest < ActiveSupport::TestCase
  test "direction" do
    route1 = routes(:x93_route_1)
    assert_equal "come", route1.direction

    route2 = routes(:x93_route_2)
    assert_equal "go", route2.direction

    route2.update_columns(description: "ΜΑΡΟΥΣΙ - Ν. ΙΩΝΙΑ - ΠΟΛΥΤΕΧΝΕΙΟ [ΕΝΑΛΛΑΚΤΙΚΗ ΛΟΓΩ ΑΓΩΝΑ - ΟΑΚΑ]")
    route2.line.update_columns(description: "ΠΟΛΥΤΕΧΝΕΙΟ - Ν. ΙΩΝΙΑ - ΜΑΡΟΥΣΙ (ΕΝΑΛΛΑΚΤΙΚΗ ΛΟΓΩ ΑΓΩΝΑ-ΟΑΚΑ)")
    assert_equal "go", route2.direction
  end
end
