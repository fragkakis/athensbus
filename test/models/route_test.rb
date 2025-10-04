require "test_helper"

class RouteTest < ActiveSupport::TestCase
  test "come?" do
    route1 = routes(:x93_route_1)
    assert route1.come?

    route2 = routes(:x93_route_2)
    refute route2.come?

    route2.update_columns(description: "ΜΑΡΟΥΣΙ - Ν. ΙΩΝΙΑ - ΠΟΛΥΤΕΧΝΕΙΟ [ΕΝΑΛΛΑΚΤΙΚΗ ΛΟΓΩ ΑΓΩΝΑ - ΟΑΚΑ]")
    route2.line.update_columns(description: "ΠΟΛΥΤΕΧΝΕΙΟ - Ν. ΙΩΝΙΑ - ΜΑΡΟΥΣΙ (ΕΝΑΛΛΑΚΤΙΚΗ ΛΟΓΩ ΑΓΩΝΑ-ΟΑΚΑ)")
    refute route2.come?
  end

  test "go?" do
    route1 = routes(:x93_route_1)
    refute route1.go?

    route2 = routes(:x93_route_2)
    assert route2.go?

    route2.update_columns(description: "ΜΑΡΟΥΣΙ - Ν. ΙΩΝΙΑ - ΠΟΛΥΤΕΧΝΕΙΟ [ΕΝΑΛΛΑΚΤΙΚΗ ΛΟΓΩ ΑΓΩΝΑ - ΟΑΚΑ]")
    route2.line.update_columns(description: "ΠΟΛΥΤΕΧΝΕΙΟ - Ν. ΙΩΝΙΑ - ΜΑΡΟΥΣΙ (ΕΝΑΛΛΑΚΤΙΚΗ ΛΟΓΩ ΑΓΩΝΑ-ΟΑΚΑ)")
    assert route2.go?
  end
end
