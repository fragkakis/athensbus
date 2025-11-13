module Schedules
  module Athens
    class BaseScheduleSyncer
      attr_reader :line

      def self.process(line)
        new(line).process
      end

      def initialize(line)
        @line = line
      end

      def process
        raise NotImplementedError
      end

      protected

      def upsert_schedule(route, type, departure_times)
        schedule = route.schedules.find_by(type: type, date: Date.current)
        if schedule
          schedule.update_columns(departure_times: departure_times)
        else
          route.schedules.create!(type: type, date: Date.current, departure_times: departure_times)
        end
      end

      private

      def come_routes
        @come_routes ||= line.routes.select(&:come?)
      end

      def go_routes
        @go_routes ||= line.routes.select(&:go?)
      end

      def extract_departure_times_for_go(schedule)
        extract_departure_times(schedule, "sde_start1")
      end

      def extract_departure_times_for_come(schedule)
        extract_departure_times(schedule, "sde_start2")
      end

      def extract_departure_times(schedule, departure_time_key)
        schedule
          .select{ |entry| entry[departure_time_key].present?}
          .map { |entry| DateTime.parse(entry[departure_time_key]).strftime("%k:%M").strip }
          .uniq
      end
    end
  end
end
