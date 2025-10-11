module RouteDailyReports
  class Creator

    attr_reader :date, :route

    def self.process(route, date = Date.current)
      new(route, date).process
    end

    def initialize(route, date = Date.current)
      @route = route
      @date = date
    end

    def process
      arrivals = route.arrivals.at_date(date)
      executed_trips = TripsCalculator.process(route, arrivals)
      route_daily_report = route.route_daily_reports.find_by(date: date)
      if route_daily_report
        route_daily_report.update_columns(executed_trips: executed_trips.size)
      else
        route.route_daily_reports.create!(date: date, executed_trips: executed_trips.size)
      end
    end
  end
end