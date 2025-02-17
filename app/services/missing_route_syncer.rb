class MissingRouteSyncer
  attr_reader :route_code, :stop_code

  def self.process(route_code, stop_code)
    new(route_code, stop_code).process
  end

  def initialize(route_code, stop_code)
    @route_code = route_code
    @stop_code = stop_code
  end

  def process
    stop = Stop.find_by(code: stop_code)
    stop.get_routes.each do |route|
      next if Route.find_by(code: route["RouteCode"]).exists?

      line = Line.find_by(code: route["LineCode"])

      ::Populators::Route.populate(line)
    end
  end
end
