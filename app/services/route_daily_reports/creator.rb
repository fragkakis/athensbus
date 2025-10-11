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
      executed_trips_count = executed_trips.values.first || 0
      if route_daily_report
        route_daily_report.update_columns(executed_trips: executed_trips_count)
      else
        route.route_daily_reports.create!(date: date, executed_trips: executed_trips_count)
      end
    end
  end
end